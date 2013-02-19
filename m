From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] ip_gre: remove an extra dst_release()
Date: Tue, 19 Feb 2013 14:36:26 -0800
Message-ID: <CALnjE+q-FwF9N2W_M96233OV7-WEgceYh9Z=CspQdzZRyB1_SQ@mail.gmail.com>
References: <1361312050.19353.169.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:54344 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932922Ab3BSWg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:36:29 -0500
Received: by mail-ye0-f197.google.com with SMTP id q9so9581160yen.8
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 14:36:28 -0800 (PST)
In-Reply-To: <1361312050.19353.169.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 2:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit 68c331631143 (v4 GRE: Add TCP segmentation offload for GRE)
> introduced a bug in error path.
>
> dst is attached to skb, so will be released when skb is freed.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>

Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/ipv4/ip_gre.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 31bc941..5ef4da7 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1006,10 +1006,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>
>                         if (skb_has_shared_frag(skb)) {
>                                 err = __skb_linearize(skb);
> -                               if (err) {
> -                                       ip_rt_put(rt);
> +                               if (err)
>                                         goto tx_error;
> -                               }
>                         }
>
>                         *ptr = 0;
>
>
