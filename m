From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH][IP] Make use of the inline function dst_metric_locked()
Date: Wed, 30 Apr 2008 12:10:40 +0800
Message-ID: <4817F140.7000302@cn.fujitsu.com>
References: <4817C8F5.7060101@gmail.com> <20080429.182443.154118887.davem@davemloft.net> <4817DF2B.1080701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59523 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbYD3EMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 00:12:41 -0400
In-Reply-To: <4817DF2B.1080701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Satoru SATOH said the following on 2008-4-30 10:53:
> # Resend it. I think it fixed.
> 
> I found some parts inline function dst_metric_locked should be used but
> not. The following patch fixes these.
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>
> 
>  include/net/ip.h |    2 +-
>  net/ipv4/route.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 6d7bcd5..3b40bc2 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -210,7 +210,7 @@ int ip_dont_fragment(struct sock *sk, struct
> dst_entry *dst)
>  {
>      return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||

Still not fixed.
Your mail client converted tab to blank space.

BTW, you need to send this patch to David and cc to netdev list.

>          (inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
> -         !(dst_metric(dst, RTAX_LOCK)&(1<<RTAX_MTU))));
> +         !(dst_metric_locked(dst, RTAX_MTU))));
>  }
> 
>  extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst,
> int more);
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ce25a13..2fd69b5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1607,7 +1607,7 @@ static void rt_set_nexthop(struct rtable *rt,
> struct fib_result *res, u32 itag)
>                 sizeof(rt->u.dst.metrics));
>          if (fi->fib_mtu == 0) {
>              rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
> -            if (rt->u.dst.metrics[RTAX_LOCK-1] & (1 << RTAX_MTU) &&
> +            if (dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
>                  rt->rt_gateway != rt->rt_dst &&
>                  rt->u.dst.dev->mtu > 576)
>                  rt->u.dst.metrics[RTAX_MTU-1] = 576;
> 

