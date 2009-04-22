From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: udp ping pong measurements from 2.6.22 to .30 with various cpu
 affinities
Date: Wed, 22 Apr 2009 23:02:27 +0200
Message-ID: <49EF85E3.8060703@cosmosbay.com>
References: <alpine.DEB.1.10.0904221604480.18138@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47932 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbZDVVDS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:03:18 -0400
In-Reply-To: <alpine.DEB.1.10.0904221604480.18138@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Here are the results of udp ping pong tests. Tests were done with bet=
ween
> two machines. The first box was running a 2.6.22 kernel with the nic =
IRQ
> and udpping pinned to processor 4.
>=20
> The second box ran the various kernel versions. NIC irq pinned to cpu=
 4.
> Then the pinning of udpping (see gentwo.org/ll) was varied
>=20
> 1. Pinned to the same processor (cpu4)
> 2. Pinned to a processor that shares the L2 cache (cpu5)
> 3. Pinned to a processor not sharing L2 (cpu6)

Here on my dev machine, cpu0, cpu2, cpu4, cpu6 are on physical CPU 0
and cpu1, cpu3, cpu5, cpu7 on physical CPU 1

egrep "processor|core id|physical" /proc/cpuinfo
processor       : 0
physical id     : 0
core id         : 0

processor       : 1
physical id     : 1
core id         : 0

processor       : 2
physical id     : 0
core id         : 2

processor       : 3
physical id     : 1
core id         : 2

processor       : 4
physical id     : 0
core id         : 1

processor       : 5
physical id     : 1
core id         : 1

processor       : 6
physical id     : 0
core id         : 3

processor       : 7
physical id     : 1
core id         : 3

Check /proc/cpuinfo, and check it doesnt change between kernel version.


>=20
> Results follow (a nice diagram is available from
> http://gentwo.org/results/udpping-tests-2.pdf

Nice graphs, but lack of documentation of test conditions.

>=20
> Observations:
> - Pinning to the same cpu yields almost 8 usecs vs. another cpu shari=
ng
>   the same L2.
> - Strangely the cpu not sharing the l2 is better than a cpu with the =
same
>   L2.

When I see strange results like that, I ask to myself :=20
Is the problem located at the looked-at system, or at the observer ?

> - Regression with cpu on the same cpu as the interrupt is about 1.5 u=
secs
> - Improvement with cpu on the same l2 cache is improved.
> - Regression of 1 usec if cpu is not sharing l2.
>=20
> Hmmm... This could all be a scheduling problem. If the processes are =
not
> placed where the IRQ occurs then there will be a significant disadvan=
tage.
>=20

We already pointed it was probably scheduling. Since ICMP pings dont us=
e
processes and no regression here. Patching kernel to implement udpping
at softirq level should be quite easy if you really want to check UDP s=
tack.

Last network improvements focused on scalability more than latencies.
(multi-flows, not single flow !)


