From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 4/5] fou: enable LCO in FOU and GUE
Date: Thu, 7 Jan 2016 10:51:35 -0800
Message-ID: <CALx6S36K+bXH+U5eGys3aKvxfHOtDAkZEQc1pPgDCiDGdXTw2g@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9CAC.6070906@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37884 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcAGSvg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 13:51:36 -0500
Received: by mail-ig0-f172.google.com with SMTP id h5so20392449igh.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 10:51:35 -0800 (PST)
In-Reply-To: <568E9CAC.6070906@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 9:13 AM, Edward Cree <ecree@solarflare.com> wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  net/ipv4/fou.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index e0fcbbb..2b0002f 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -773,7 +773,6 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
>         uh->dest = e->dport;
>         uh->source = sport;
>         uh->len = htons(skb->len);
> -       uh->check = 0;
>         udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
>                      fl4->saddr, fl4->daddr, skb->len);
>
> @@ -787,7 +786,7 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>         int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
>         __be16 sport;
>
> -       skb = iptunnel_handle_offloads(skb, csum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);

It might good to have another iptunnel_handle_offloads (lifke
iptunnel_handle_offloads_nocsum) function that doesn't have csum
parameter for readability.

>
>         if (IS_ERR(skb))
>                 return PTR_ERR(skb);
> @@ -821,7 +820,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>
>         optlen += need_priv ? GUE_LEN_PRIV : 0;
>
> -       skb = iptunnel_handle_offloads(skb, csum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);
>
>         if (IS_ERR(skb))
>                 return PTR_ERR(skb);
>
> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
