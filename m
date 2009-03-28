From: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Subject: Re: 3c59x: shared interrupt problem
Date: Sat, 28 Mar 2009 15:17:47 +0100
Message-ID: <20090328141747.261030@gmx.net>
References: <20090309224253.135220@gmx.net>
 <20090327075937.GA17119@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34252 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754656AbZC1ORu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2009 10:17:50 -0400
In-Reply-To: <20090327075937.GA17119@bayes.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original-Nachricht --------
> Datum: Fri, 27 Mar 2009 08:59:37 +0100
> Von: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> An: Gerhard Pircher <gerhard_pircher@gmx.net>
> CC: netdev@vger.kernel.org
> Betreff: Re: 3c59x: shared interrupt problem

> On Mon, Mar 09, 2009 at 11:42:53PM +0100, Gerhard Pircher wrote:
> >=20
> > Kernel log:
> > Badness at net/sched/sch_generic.c:226
> > NIP: c0250118 LR: c0250118 CTR: c0013020
> > REGS: efffde90 TRAP: 0700   Not tainted  (2.6.29-rc6)
> > MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 42024024  XER: 00000000
> > TASK =3D c03915a0[0] 'swapper' THREAD: c03b2000
> > GPR00: c0250118 efffdf40 c03915a0 00000035 00008a62 ffffffff ffffff=
ff 00000000=20
> > GPR08: 00000000 c03c0000 00008a62 c0393104 22024042 00000000 0ffd59=
00 0080044c=20
> > GPR16: 00000001 ffffffff 00000000 007ffc00 0ffd3158 0f0689b0 0ffff2=
20 007ffbc0=20
> > GPR24: 00000000 00000000 0000000a 00000004 efffc000 c024ffb0 000001=
00 ef847000=20
> > NIP [c0250118] dev_watchdog+0x168/0x244
> > LR [c0250118] dev_watchdog+0x168/0x244
> > Call Trace:
> > [efffdf40] [c0250118] dev_watchdog+0x168/0x244 (unreliable)
> > [efffdfa0] [c002f564] run_timer_softirq+0x12c/0x1b4
> > [efffdfd0] [c002ab0c] __do_softirq+0x6c/0x108
> > [efffdff0] [c0011ef0] call_do_softirq+0x14/0x24
> > [c03b3e90] [c0006c30] do_softirq+0x64/0x88
> > [c03b3eb0] [c002a968] irq_exit+0x38/0x7c
> > [c03b3ec0] [c000f634] timer_interrupt+0x138/0x150
> > [c03b3ee0] [c0012bd4] ret_from_except+0x0/0x14
> > --- Exception: 901 at cpu_idle+0xa4/0xec
> >     LR =3D cpu_idle+0x98/0xec
> > [c03b3fa0] [c0009f38] cpu_idle+0x4c/0xec (unreliable)
> > [c03b3fb0] [c0297214] __got2_end+0x58/0x68
> > [c03b3fc0] [c03637e4] start_kernel+0x28c/0x2a0
> > [c03b3ff0] [0000380c] 0x380c
> > Instruction dump:
> > 80099d6c 2f800000 40be0038 38810008 7fe3fb78 38a00040 4bfee811 7fe4=
fb78=20
> > 7c651b78 3c60c034 3863f264 4bdd6005 <0fe00000> 38000001 3d20c03c 90=
099d6c=20
> > eth0: transmit timed out, tx_status 00 status e601.
> >   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
> > eth0: Interrupt posted but not delivered -- IRQ blocked by another =
device?
> >   Flags; bus-master 1, dirty 16(0) current 16(0)
> >   Transmit list 00000000 vs. f101a200.
> >   0: @f101a200  length 80000156 status 00010156
> >   1: @f101a2a0  length 80000156 status 00010156
> >   2: @f101a340  length 80000156 status 00010156
> >   3: @f101a3e0  length 80000156 status 00010156
> >   4: @f101a480  length 80000156 status 00010156
> >   5: @f101a520  length 80000156 status 00010156
> >   6: @f101a5c0  length 80000156 status 00010156
> >   7: @f101a660  length 80000156 status 00010156
> >   8: @f101a700  length 8000003c status 0001003c
> >   9: @f101a7a0  length 8000003c status 0001003c
> >   10: @f101a840  length 8000003c status 0001003c
> >   11: @f101a8e0  length 8000003c status 0001003c
> >   12: @f101a980  length 8000003c status 0001003c
> >   13: @f101aa20  length 8000003c status 0001003c
> >   14: @f101aac0  length 80000036 status 80010036
> >   15: @f101ab60  length 800000f5 status 8c0100f5
> > eth0: Resetting the Tx ring pointer.
> >=20
>=20
> Do you see these messages always when your network hangs and does the
> network recover after such a hang? Could you please send the output o=
f
> 'tc -s qdisc show' after a network hang?
IIRC I only got this message once during shutdown. Normally only
"IRQ 7 nobody cared" messages with a stacktrace of the interrupt
handlers are printed out with newer kernels (>=3D2.6.26) (see the
screenshots I made). Older kernels don't print out any messages
at all. Also the network never recovers after a bad interrupt is
reported in /proc/interrupts.
I'm far away from my machine for the next three weeks, so I can't
send you the output until then.
So far I could narrow down the problem to kernel versions v2.6.19
till 2.6.23-rc9. Bisecting is getting harder now, because either
arch/ppc doesn't work anymore for PPC32 or my platform patches for
arch/powerpc do not apply.

regards,

Gerhard
--=20
--
-- Dipl. Ing. (FH) Gerhard Pircher
-- E-mail : gerhard_pircher@gmx.net
--

Neu: GMX FreeDSL Komplettanschluss mit DSL 6.000 Flatrate + Telefonansc=
hluss f=FCr nur 17,95 Euro/mtl.!* http://dsl.gmx.de/?ac=3DOM.AD.PD003K1=
1308T4569a
