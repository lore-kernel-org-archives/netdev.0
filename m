From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 14:44:29 +0200
Message-ID: <1285850669.2615.426.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
	 <1285796721.5211.156.camel@edumazet-laptop>
	 <20100930062419.GD86786@beaver.vrungel.ru>
	 <1285828432.5211.812.camel@edumazet-laptop>
	 <20100930122321.GA1575@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47882 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab0I3Moi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 08:44:38 -0400
In-Reply-To: <20100930122321.GA1575@beaver.vrungel.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 16:23 +0400, Alexey Vlasov a =C3=A9cr=
it :
> On Thu, Sep 30, 2010 at 08:33:52AM +0200, Eric Dumazet wrote:
> > Le jeudi 30 septembre 2010 ?? 10:24 +0400, Alexey Vlasov a ??crit :
> > > Here I found some dude with the same problem:
> > > http://lkml.org/lkml/2010/7/9/340
> > >=20
> >=20
> > In your opinion its the same problem.
> >=20
> > But the description you gave is completely different.
> >=20
> > You have time skew only when activating a particular iptables rule.
> =20
> Well I put interrups from NIC, namely tx/rx query, to different
> processors and got normal pings by adding LOG rule.
>=20
> I also found that overruns is constantly growing, I don't know if the=
se are connected.
> RX packets:2831439546 errors:0 dropped:134726 overruns:947671733 fram=
e:0
> TX packets:2880849825 errors:0 dropped:0 overruns:0 carrier:0
>=20
> Rather strange that only one processor was involved, even in top was
> clear that ksoftirqd eats the first processor up to 100%.=20
>=20

OK, because only CPU0 gets interrupts of all queues.

> Here goes the typical distribution of interrups on new servers:
>            CPU0    CPU1    CPU2    CPU3 ... CPU23
> 752:         11       0       0       0 ...     0 PCI-MSI-edge eth0
> 753: 2799366721       0       0       0 ...     0 PCI-MSI-edge eth0-r=
x3
> 754: 2821840553       0       0       0 ...     0 PCI-MSI-edge eth0-r=
x2
> 755: 2786117044       0       0       0 ...     0 PCI-MSI-edge eth0-r=
x1
> 756: 2896099336       0       0       0 ...     0 PCI-MSI-edge eth0-r=
x0
> 757: 1808404680       0       0       0 ...     0 PCI-MSI-edge eth0-t=
x3
> 758: 1797855130       0       0       0 ...     0 PCI-MSI-edge eth0-t=
x2
> 759: 1807222032       0       0       0 ...     0 PCI-MSI-edge eth0-t=
x1
> 760: 1820309360       0       0       0 ...     0 PCI-MSI-edge eth0-t=
x0
>=20

echo 01 >/proc/irq/*/eth0-rx0/../smp_affinity
echo 02 >/proc/irq/*/eth0-rx1/../smp_affinity
echo 04 >/proc/irq/*/eth0-rx2/../smp_affinity
echo 08 >/proc/irq/*/eth0-rx3/../smp_affinity


cat /proc/irq/*/eth0-rx0/../smp_affinity
cat /proc/irq/*/eth0-rx1/../smp_affinity
cat /proc/irq/*/eth0-rx2/../smp_affinity
cat /proc/irq/*/eth0-rx3/../smp_affinity



> On the old ones:
>            CPU0       CPU1       CPU2  ...      CPU8
> 502:  522320256  522384039  522327386  ... 522380267 PCI-MSI-edge eth=
0
>=20

What network driver is it (newbox), was it (old box) ?

If you switch to 2.6.35, you can use RPS to dispatch packets to several
cpu, in the case interrupt affinity could not be changed (all interrupt=
s
still handled by CPU0)



