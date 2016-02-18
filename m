From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next v3 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Thu, 18 Feb 2016 09:55:40 -0800
Message-ID: <CAM_iQpXUv1s1xw9g9uox25fYrRXpTjFLE5_OwUYE_tCZAoGF3w@mail.gmail.com>
References: <1455767550-16896-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35071 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426666AbcBRRzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 12:55:40 -0500
Received: by mail-yw0-f169.google.com with SMTP id g127so47029388ywf.2
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 09:55:40 -0800 (PST)
In-Reply-To: <1455767550-16896-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 7:52 PM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
>
> Scrub skb before hitting the iptable hooks to ensure packets hit
> these hooks in master's namespace.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/ipvlan/ipvlan_core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 8c48bb2a94ea..a1f87ec316cf 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>                 ip_rt_put(rt);
>                 goto err;
>         }
> -       skb_dst_drop(skb);
> +       skb_scrub_packet(skb, true);
>         skb_dst_set(skb, &rt->dst);
>         err = ip_local_out(net, skb->sk, skb);
>         if (unlikely(net_xmit_eval(err)))
> @@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
>                 dst_release(dst);
>                 goto err;
>         }
> -       skb_dst_drop(skb);
> +       skb_scrub_packet(skb, true);

At least this patch is still same with the previous version. Or am I
missing anything?
