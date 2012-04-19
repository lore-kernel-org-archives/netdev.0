From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix compile error of leaking kmemleak.h header
Date: Thu, 19 Apr 2012 06:22:08 +0200
Message-ID: <1334809328.2395.0.camel@edumazet-glaptop>
References: <4F8F8F1A.6020000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, majianpeng@gmail.com,
	NetDev <netdev@vger.kernel.org>,
	davidshan <davidshan@tencent.com>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43675 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab2DSEWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 00:22:12 -0400
Received: by wejx9 with SMTP id x9so5142150wej.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 21:22:11 -0700 (PDT)
In-Reply-To: <4F8F8F1A.6020000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 12:05 +0800, Shan Wei wrote:
> From: Shan Wei <davidshan@tencent.com>
>=20
> net/core/sysctl_net_core.c: In function =E2=80=98sysctl_core_init=E2=80=
=99:
> net/core/sysctl_net_core.c:259: error: implicit declaration of functi=
on =E2=80=98kmemleak_not_leak=E2=80=99
>=20
> with same error in net/ipv4/route.c
>=20
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  net/core/sysctl_net_core.c |    1 +
>  net/ipv4/route.c           |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index cee5991..247c69b 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -14,6 +14,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/init.h>
>  #include <linux/slab.h>
> +#include <linux/kmemleak.h>
> =20
>  #include <net/ip.h>
>  #include <net/sock.h>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index bcd4744..a1c115d 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -109,6 +109,7 @@
>  #include <net/rtnetlink.h>
>  #ifdef CONFIG_SYSCTL
>  #include <linux/sysctl.h>
> +#include <linux/kmemleak.h>
>  #endif
>  #include <net/secure_seq.h>
> =20

yep, SLAB doesnt include it like SLUB

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
