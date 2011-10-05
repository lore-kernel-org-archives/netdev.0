From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Wed, 05 Oct 2011 10:53:52 +0200
Message-ID: <1317804832.2473.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <6.2.5.6.2.20111005025227.03a9d9f0@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, Christoph Lameter <cl@gentwo.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>,
	Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: starlight@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111005025227.03a9d9f0@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 05 octobre 2011 =C3=A0 02:58 -0400, starlight@binnacle.cx a
=C3=A9crit :
> Final note:
>=20
> I had captured latency measurements for
> two of the three kernels.  Just ran
> 2.6.18(rhel5) and the results are
> stunning.  The older kernel is much,
> much better then the newer kernel.
>=20
> Average latency is three times better
> and the standard deviation is six
> time better.  As in 300% and 600%.
>=20
> Latency here is the time it takes
> a packet to travel from the kernel
> (where it is timestamped) till it
> reaches the final consumption point
> in the application.
>=20
> Makes me think that the old kernel
> is better at keeping caches hot and
> scheduling woken threads on the same
> cores as the threads that triggered
> them.
>=20

Note :

Your results are from a combination of a user application and kernel
default strategies.

On other combinations, results can be completely different.

A wakeup strategy is somewhat tricky :=20

- Should we affine or not.
- Should we queue the wakeup on a remote CPU, to keep scheduler data ho=
t
in a single cpu cache.
- Should we use RPS/RFS to queue the packet to another CPU before  even
handling it in our stack, to keep network data hot in a single cpu
cache. (check Documentation/networking/scaling.txt)

At least, with recent kernels, we have many available choices to tune a
workload.
