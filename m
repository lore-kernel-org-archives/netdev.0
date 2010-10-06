From: =?UTF-8?B?Q2h1bmctWWloIFdhbmcgKOeOi+W0h+aHvyk=?=
	<cywang@google.com>
Subject: Re: [PATCH] net: Fix sk_dst_check() to reset the obsolete dst_entry
 of a socket.
Date: Wed, 6 Oct 2010 00:47:47 -0700
Message-ID: <AANLkTikx+GadeYfg5rZNxsEig-0Af97ER7V94fjaVc+U@mail.gmail.com>
References: <AANLkTikkv4htP1f=KFwSaa8=K6LicDN0eusXctow-Efb@mail.gmail.com> <20101006.003541.71128466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:37262 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246Ab0JFHsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 03:48:13 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o967mCRm007562
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 00:48:12 -0700
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by kpbe14.cbf.corp.google.com with ESMTP id o967mAFv018019
	for <netdev@vger.kernel.org>; Wed, 6 Oct 2010 00:48:11 -0700
Received: by qwk4 with SMTP id 4so6150851qwk.18
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 00:48:10 -0700 (PDT)
In-Reply-To: <20101006.003541.71128466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fact, that is what I intent to change originally. However, consider
Timo's issue, I intent to submit this patch instead.

On Wed, Oct 6, 2010 at 12:35 AM, David Miller <davem@davemloft.net> wro=
te:
>
> This should have been fixed by:
>
> --------------------
> commit ae2688d59b5f861dc70a091d003773975d2ae7fb
> Author: Jianzhao Wang <jianzhao.wang@6wind.com>
> Date: =A0 Wed Sep 8 14:35:43 2010 -0700
>
> =A0 =A0net: blackhole route should always be recalculated
>
> =A0 =A0Blackhole routes are used when xfrm_lookup() returns -EREMOTE =
(error
> =A0 =A0triggered by IKE for example), hence this kind of route is alw=
ays
> =A0 =A0temporary and so we should check if a better route exists for =
next
> =A0 =A0packets.
> =A0 =A0Bug has been introduced by commit d11a4dc18bf41719c9f0d7ed494d=
295dd2973b92.
>
> =A0 =A0Signed-off-by: Jianzhao Wang <jianzhao.wang@6wind.com>
> =A0 =A0Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3f56b6e..6298f75 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2738,6 +2738,11 @@ slow_output:
> =A0}
> =A0EXPORT_SYMBOL_GPL(__ip_route_output_key);
>
> +static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *=
dst, u32 cookie)
> +{
> + =A0 =A0 =A0 return NULL;
> +}
> +
> =A0static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u=
32 mtu)
> =A0{
> =A0}
> @@ -2746,7 +2751,7 @@ static struct dst_ops ipv4_dst_blackhole_ops =3D=
 {
> =A0 =A0 =A0 =A0.family =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D =A0 =A0 =A0=
 AF_INET,
> =A0 =A0 =A0 =A0.protocol =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D =A0 =A0 =A0 =
cpu_to_be16(ETH_P_IP),
> =A0 =A0 =A0 =A0.destroy =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D =A0 =A0 =A0=
 ipv4_dst_destroy,
> - =A0 =A0 =A0 .check =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D =A0 =A0 =A0=
 ipv4_dst_check,
> + =A0 =A0 =A0 .check =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D =A0 =A0 =A0=
 ipv4_blackhole_dst_check,
> =A0 =A0 =A0 =A0.update_pmtu =A0 =A0 =A0 =A0 =A0 =A0=3D =A0 =A0 =A0 ip=
v4_rt_blackhole_update_pmtu,
> =A0 =A0 =A0 =A0.entries =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D =A0 =A0 =A0=
 ATOMIC_INIT(0),
> =A0};
>
