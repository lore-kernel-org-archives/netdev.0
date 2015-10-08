From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v3 2/2] tipc: remove invalid ip_rt_put
Date: Thu, 8 Oct 2015 18:25:55 +0200
Message-ID: <20151008182555.3e5db855@griffin>
References: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
	<1444320530-28706-2-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35229 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933014AbbJHQZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 12:25:59 -0400
In-Reply-To: <1444320530-28706-2-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Oct 2015 18:08:50 +0200, Andreas Schultz wrote:
> udp_tunnel_xmit_skb() will free the skb and release the rt->dst
> reference in the error case. There is no need (and it would actully
> trigger a warning) when we did.
> This problem was not visible before, as udp_tunnel_xmit_skb() would
> never return a value < 0

You're missing s-o-b.

> ---
>  net/tipc/udp_media.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
> index c170d31..de8e110 100644
> --- a/net/tipc/udp_media.c
> +++ b/net/tipc/udp_media.c
> @@ -181,10 +181,6 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
>  					  dst->ipv4.s_addr, 0, ttl, 0,
>  					  src->udp_port, dst->udp_port,
>  					  false, true);
> -		if (err < 0) {
> -			ip_rt_put(rt);
> -			goto tx_error;
> -		}
>  #if IS_ENABLED(CONFIG_IPV6)
>  	} else {
>  		struct dst_entry *ndst;

Not sure what the intended return value of struct tipc_media->send_msg
is but it seems to be completely ignored anyway.

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
