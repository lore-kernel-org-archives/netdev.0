From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: ipv4: route: fixed a coding style issues net: ipv4:
 tcp: fixed a coding style issues
Date: Thu, 20 Dec 2012 13:07:34 +0100
Message-ID: <50D2FF86.3000603@6wind.com>
References: <1355990910-3688-1-git-send-email-hasko.stevo@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Hasko <hasko.stevo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:41213 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab2LTMMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 07:12:51 -0500
Received: by mail-we0-f169.google.com with SMTP id t49so1563955wey.28
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 04:12:49 -0800 (PST)
In-Reply-To: <1355990910-3688-1-git-send-email-hasko.stevo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/12/2012 09:08, Stefan Hasko a =C3=A9crit :
> Fix a coding style issues.
>
> Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
> ---
>   net/ipv4/route.c |  125 ++++++++++++++++++-------------
>   net/ipv4/tcp.c   |  218 +++++++++++++++++++++++++++++++------------=
-----------
>   2 files changed, 200 insertions(+), 143 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 844a9ef..fff7ce6 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -20,7 +20,7 @@
>    *		Alan Cox	:	Added BSD route gw semantics
>    *		Alan Cox	:	Super /proc >4K
>    *		Alan Cox	:	MTU in route table
> - *		Alan Cox	: 	MSS actually. Also added the window
> + *		Alan Cox	:	MSS actually. Also added the window
>    *					clamper.
>    *		Sam Lantinga	:	Fixed route matching in rt_del()
>    *		Alan Cox	:	Routing cache support.
> @@ -31,30 +31,35 @@
>    *	Miquel van Smoorenburg	:	BSD API fixes.
>    *	Miquel van Smoorenburg	:	Metrics.
>    *		Alan Cox	:	Use __u32 properly
> - *		Alan Cox	:	Aligned routing errors more closely with BSD
> + *		Alan Cox	:	Aligned routing errors more
> + *					closely with BSD
>    *					our system is still very different.
>    *		Alan Cox	:	Faster /proc handling
> - *	Alexey Kuznetsov	:	Massive rework to support tree based routing,
> + *	Alexey Kuznetsov	:	Massive rework to support
> + *					tree based routing,
>    *					routing caches and better behaviour.
>    *
>    *		Olaf Erb	:	irtt wasn't being copied right.
>    *		Bjorn Ekwall	:	Kerneld route support.
>    *		Alan Cox	:	Multicast fixed (I hope)
> - * 		Pavel Krauz	:	Limited broadcast fixed
> + *		Pavel Krauz	:	Limited broadcast fixed
>    *		Mike McLagan	:	Routing by source
>    *	Alexey Kuznetsov	:	End of old history. Split to fib.c and
>    *					route.c and rewritten from scratch.
>    *		Andi Kleen	:	Load-limit warning messages.
> - *	Vitaly E. Lavrov	:	Transparent proxy revived after year coma.
> + *	Vitaly E. Lavrov	:	Transparent proxy revived
> + *					after year coma.
>    *	Vitaly E. Lavrov	:	Race condition in ip_route_input_slow.
> - *	Tobias Ringstrom	:	Uninitialized res.type in ip_route_output_slow=
=2E
> + *	Tobias Ringstrom	:	Uninitialized res.type in
> + *					ip_route_output_slow.
>    *	Vladimir V. Ivanov	:	IP rule info (flowid) is really useful.
>    *		Marc Boucher	:	routing by fwmark
>    *	Robert Olsson		:	Added rt_cache statistics
>    *	Arnaldo C. Melo		:	Convert proc stuff to seq_file
> - *	Eric Dumazet		:	hashed spinlocks and rt_check_expire() fixes.
> - * 	Ilia Sotnikov		:	Ignore TOS on PMTUD and Redirect
> - * 	Ilia Sotnikov		:	Removed TOS from hash calculations
> + *	Eric Dumazet		:	hashed spinlocks and
> + *					rt_check_expire() fixes.
> + *	Ilia Sotnikov		:	Ignore TOS on PMTUD and Redirect
> + *	Ilia Sotnikov		:	Removed TOS from hash calculations
>    *
>    *		This program is free software; you can redistribute it and/or
>    *		modify it under the terms of the GNU General Public License
> @@ -65,7 +70,7 @@
>   #define pr_fmt(fmt) "IPv4: " fmt
>
>   #include <linux/module.h>
> -#include <asm/uaccess.h>
> +#include <linux/uaccess.h>
>   #include <linux/bitops.h>
>   #include <linux/types.h>
>   #include <linux/kernel.h>
> @@ -139,7 +144,8 @@ static unsigned int	 ipv4_default_advmss(const st=
ruct dst_entry *dst);
>   static unsigned int	 ipv4_mtu(const struct dst_entry *dst);
>   static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst=
);
>   static void		 ipv4_link_failure(struct sk_buff *skb);
> -static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *=
sk,
> +static void		 ip_rt_update_pmtu(struct dst_entry *dst,
> +					   struct sock *sk,
>   					   struct sk_buff *skb, u32 mtu);
>   static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk=
,
>   					struct sk_buff *skb);
> @@ -291,12 +297,17 @@ static int rt_cpu_seq_show(struct seq_file *seq=
, void *v)
>   	struct rt_cache_stat *st =3D v;
>
>   	if (v =3D=3D SEQ_START_TOKEN) {
> -		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_rout=
e in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_m=
c  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out=
_hlist_search\n");
> +		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc "
> +				"in_no_route in_brd in_martian_dst "
> +				"in_martian_src  out_hit out_slow_tot "
> +				"out_slow_mc  gc_total gc_ignored "
> +				"gc_goal_miss gc_dst_overflow in_hlist_search "
> +				"out_hlist_search\n");
checkpatch will warn you about this one, something like:
"WARNING: quoted string split across lines".
Not breaking such line ease to grep the pattern.

Nicolas
