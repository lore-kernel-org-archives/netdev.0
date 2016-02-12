From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCHv2 next 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Fri, 12 Feb 2016 14:24:00 -0800
Message-ID: <CAM_iQpVgSOs5F6L6n2MhFxxuHaZizm7xzmYTE6HyRJXP9O67cg@mail.gmail.com>
References: <1455118406-428-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36681 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbcBLWcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 17:32:01 -0500
Received: by mail-yw0-f173.google.com with SMTP id q190so76146575ywd.3
        for <netdev@vger.kernel.org>; Fri, 12 Feb 2016 14:32:01 -0800 (PST)
In-Reply-To: <1455118406-428-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 7:33 AM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
>
> Scrub skb before hitting the iptable hooks to ensure packets hit
> these hooks.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1: initial patch
> v2: resend
>
>  drivers/net/ipvlan/ipvlan_core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 8c48bb2a94ea..21c380f9ccd5 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -365,7 +365,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
>                 ip_rt_put(rt);
>                 goto err;
>         }
> -       skb_dst_drop(skb);
> +       skb_scrub_packet(skb, false);

Hmm, I am feeling we should set the xnet param to be true here when the ipvlan
device is in a different namespace with the physical one?


>         skb_dst_set(skb, &rt->dst);
>         err = ip_local_out(net, skb->sk, skb);
>         if (unlikely(net_xmit_eval(err)))
> @@ -403,7 +403,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
>                 dst_release(dst);
>                 goto err;
>         }
> -       skb_dst_drop(skb);
> +       skb_scrub_packet(skb, false);

Ditto.

Thanks!
