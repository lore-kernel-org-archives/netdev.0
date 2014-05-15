From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: randconfig build error with next-20140515, in drivers/net/ethernet/mellanox/mlx4/eq.c
Date: Thu, 15 May 2014 17:10:44 +0300
Message-ID: <5374CAE4.2080305@mellanox.com>
References: <CA+r1Zhg2eT=MxzTmrv=mrhRMRgmFQx3FETLSf42-gGQUxqLOaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuval Atias <yuvala@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:33260 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752107AbaEOOLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 10:11:15 -0400
In-Reply-To: <CA+r1Zhg2eT=MxzTmrv=mrhRMRgmFQx3FETLSf42-gGQUxqLOaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/05/2014 16:48, Jim Davis wrote:
> Building with the attached random configuration file,
>
> drivers/net/ethernet/mellanox/mlx4/eq.c:58:29: error: field =91notify=
=92
> has incomplete type
>    struct irq_affinity_notify notify;
>                               ^
> In file included from include/linux/interrupt.h:5:0,
>                   from drivers/net/ethernet/mellanox/mlx4/eq.c:34:
> drivers/net/ethernet/mellanox/mlx4/eq.c: In function =91mlx4_irq_noti=
fier_notify=92:
> include/linux/kernel.h:834:48: warning: initialization from
> incompatible pointer type [enabled by default]
>    const typeof( ((type *)0)->member ) *__mptr =3D (ptr); \
>                                                  ^
> drivers/net/ethernet/mellanox/mlx4/eq.c:1094:30: note: in expansion o=
f
> macro =91container_of=92
>    struct mlx4_irq_notify *n =3D container_of(notify,
>                                ^
> include/linux/kernel.h:834:48: warning: (near initialization for =91n=
=92)
> [enabled by default]
>    const typeof( ((type *)0)->member ) *__mptr =3D (ptr); \
>                                                  ^
> drivers/net/ethernet/mellanox/mlx4/eq.c:1094:30: note: in expansion o=
f
> macro =91container_of=92
>    struct mlx4_irq_notify *n =3D container_of(notify,
>                                ^
> drivers/net/ethernet/mellanox/mlx4/eq.c:1104:24: error: dereferencing
> pointer to incomplete type
>     if (cq->irq =3D=3D notify->irq)
>                          ^
> In file included from include/linux/interrupt.h:5:0,
>                   from drivers/net/ethernet/mellanox/mlx4/eq.c:34:
> drivers/net/ethernet/mellanox/mlx4/eq.c: In function
> =91mlx4_release_irq_notifier=92:
> include/linux/kernel.h:834:48: warning: initialization from
> incompatible pointer type [enabled by default]
>    const typeof( ((type *)0)->member ) *__mptr =3D (ptr); \
>                                                  ^
> drivers/net/ethernet/mellanox/mlx4/eq.c:1111:30: note: in expansion o=
f
> macro =91container_of=92
>    struct mlx4_irq_notify *n =3D container_of(ref, struct mlx4_irq_no=
tify,
>                                ^
> include/linux/kernel.h:834:48: warning: (near initialization for =91n=
=92)
> [enabled by default]
>    const typeof( ((type *)0)->member ) *__mptr =3D (ptr); \
>                                                  ^
> drivers/net/ethernet/mellanox/mlx4/eq.c:1111:30: note: in expansion o=
f
> macro =91container_of=92
>    struct mlx4_irq_notify *n =3D container_of(ref, struct mlx4_irq_no=
tify,
>                                ^
> drivers/net/ethernet/mellanox/mlx4/eq.c: In function =91mlx4_assign_i=
rq_notifier=92:
> drivers/net/ethernet/mellanox/mlx4/eq.c:1133:2: error: implicit
> declaration of function =91irq_set_affinity_notifier=92
> [-Werror=3Dimplicit-function-declaration]
>    err =3D irq_set_affinity_notifier(irq, &irq_notifier->notify);
>    ^
> cc1: some warnings being treated as errors

I can see the problem, irq_set_affinity_notifier isn't defined when CON=
=46IG_SMP isn't set, I am copying here the developer and he would work =
on a fix.

Or.
