From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net] ip_tunnels: Use skb-len to PMTU check.
Date: Sun, 30 Jun 2013 10:50:03 +0300
Message-ID: <20130630105003.0932fcd7@vostro>
References: <1372570818-15651-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:63114 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3F3Htv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 03:49:51 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so1453447eek.7
        for <netdev@vger.kernel.org>; Sun, 30 Jun 2013 00:49:50 -0700 (PDT)
In-Reply-To: <1372570818-15651-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Jun 2013 22:40:18 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> In path mtu check, ip header total length works for gre device
> but not for gre-tap device.  Use skb len which is consistent
> for all tunneling types.  This also fixes bug introduced by
> commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).
> 
> Reported-by: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_tunnel.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 7fa8f08..4e9f530 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -595,7 +595,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
> net_device *dev, 
>  		if (!skb_is_gso(skb) &&
>  		    (inner_iph->frag_off&htons(IP_DF)) &&
> -		     mtu < ntohs(inner_iph->tot_len)) {
> +		     mtu < skb->len) {
>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu)); ip_rt_put(rt);
>  			goto tx_error;

I think icmp_send's mtu parameter should be adjusted too. Since it's
sent to the inner flow, but the mtu now is disregarding the possible
tunnel headers.

- Timo
