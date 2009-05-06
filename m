From: Ingo Molnar <mingo@elte.hu>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 10:03:35 +0200
Message-ID: <20090506080335.GA8098@elte.hu>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com> <4A008A72.6030607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladimir Ivashchenko <hazard@francoudi.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:33142 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756695AbZEFIDk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 04:03:40 -0400
Content-Disposition: inline
In-Reply-To: <4A008A72.6030607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Vladimir Ivashchenko a =E9crit :
> >>> On both kernels, the system is running with at least 70% idle CPU=
=2E
> >>> The network interrupts are distributed accross the cores.
> >> You should not distribute interrupts, but bound a NIC to one CPU
> >=20
> > Kernels 2.6.28 and 2.6.29 do this by default, so I thought its corr=
ect.
> > The defaults are wrong?
>=20
> Yes they are, at least for forwarding setups.
>=20
> >=20
> > I have tried with IRQs bound to one CPU per NIC. Same result.
>=20
> Did you check "grep eth /proc/interrupts" that your affinities setup=20
> were indeed taken into account ?
>=20
> You should use same CPU for eth0 and eth2 (bond0),
>=20
> and another CPU for eth1 and eth3 (bond1)
>=20
> check how your cpus are setup=20
>=20
> egrep 'physical id|core id|processor' /proc/cpuinfo
>=20
> Because you might play and find best combo
>=20
>=20
> If you use 2.6.29, apply following patch to get better system account=
ing,
> to check if your cpu are saturated or not by hard/soft irqs
>=20
> --- linux-2.6.29/kernel/sched.c.orig    2009-05-05 20:46:49.000000000=
 +0200
> +++ linux-2.6.29/kernel/sched.c 2009-05-05 20:47:19.000000000 +0200
> @@ -4290,7 +4290,7 @@
>=20
>         if (user_tick)
>                 account_user_time(p, one_jiffy, one_jiffy_scaled);
> -       else if (p !=3D rq->idle)
> +       else if ((p !=3D rq->idle) || (irq_count() !=3D HARDIRQ_OFFSE=
T))
>                 account_system_time(p, HARDIRQ_OFFSET, one_jiffy,
>                                     one_jiffy_scaled);
>         else

Note, your scheduler fix is upstream now in Linus's tree, as:

  f5f293a: sched: account system time properly

"git cherry-pick f5f293a" will apply it to a .29 basis.

	Ingo
