From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V6 2/2] net/mlx4_en: Use affinity hint
Date: Sun, 01 Jun 2014 21:37:11 -0700
Message-ID: <1401683831.3645.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401029247-15196-1-git-send-email-amirv@mellanox.com>
	 <1401029247-15196-3-git-send-email-amirv@mellanox.com>
	 <1401682610.3645.166.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>, linux-kernel@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:64091 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaFBEhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:37:15 -0400
In-Reply-To: <1401682610.3645.166.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-01 at 21:16 -0700, Eric Dumazet wrote:
> On Sun, 2014-05-25 at 17:47 +0300, Amir Vadai wrote:
> > From: Yuval Atias <yuvala@mellanox.com>
> >=20
> > The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user s=
pace
> > daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
> > Irqbalancer can use this hint to balance the irqs between the
> > cpus indicated by the mask.
> >=20
> > We wish the HCA to preferentially map the IRQs it uses to numa core=
s
> > close to it.  To accomplish this, we use cpumask_set_cpu_local_firs=
t(), that
> > sets the affinity hint according the following policy:
> > First it maps IRQs to =E2=80=9Cclose=E2=80=9D numa cores.  If these=
 are exhausted, the
> > remaining IRQs are mapped to =E2=80=9Cfar=E2=80=9D numa cores.
> >=20
> > Signed-off-by: Yuval Atias <yuvala@mellanox.com>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
>=20
>   CC [M]  drivers/net/ethernet/mellanox/mlx4/en_netdev.o
> drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function =E2=80=98=
mlx4_en_init_affinity_hint=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1546:23: error: incomp=
atible types when assigning to type =E2=80=98cpumask_var_t=E2=80=99 fro=
m type =E2=80=98void *=E2=80=99
> drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function =E2=80=98=
mlx4_en_free_affinity_hint=E2=80=99:
> drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1553:41: error: incomp=
atible types when assigning to type =E2=80=98cpumask_var_t=E2=80=99 fro=
m type =E2=80=98void *=E2=80=99


And :

ERROR: "cpumask_set_cpu_local_first" [drivers/net/ethernet/mellanox/mlx=
4/mlx4_en.ko] undefined!


$ git grep -n cpumask_set_cpu_local_first
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1542:    if (cpumask_set=
_cpu_local_first(ring_idx, numa_node,
include/linux/cpumask.h:260:int cpumask_set_cpu_local_first(int i, int =
numa_node, cpumask_t *dstp);
lib/cpumask.c:168: * cpumask_set_cpu_local_first - set i'th cpu with lo=
cal numa cpu's first
lib/cpumask.c:182:int cpumask_set_cpu_local_first(int i, int numa_node,=
 cpumask_t *dstp)
lib/cpumask.c:228:EXPORT_SYMBOL(cpumask_set_cpu_local_first);

=46ixes are needed if CONFIG_CPUMASK_OFFSTACK is not used.
=09
$ grep CONFIG_CPUMASK_OFFSTACK .config
$ echo $?
1
