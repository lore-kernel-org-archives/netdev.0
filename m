From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Thu, 10 Sep 2009 23:37:07 +0200
Message-ID: <4AA97183.3030008@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43718 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbZIJVhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 17:37:39 -0400
In-Reply-To: <4AA963A4.5080509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Something must be wrong with program or whatever...
>=20
> On the receiver I did this to trace the latency messages only
>=20
> # tcpdump -i eth0 not host 239.0.192.2 and port 9002 -n
>=20
> 22:28:07.223300 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 3=
2
> 22:28:07.223403 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 3=
2
>=20
> 22:28:08.223301 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 3=
2
> 22:28:08.223416 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 3=
2
>=20
> 22:28:09.223380 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 3=
2
> 22:28:09.223494 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 3=
2
>=20
> 22:28:10.223481 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 3=
2
> 22:28:10.223597 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 3=
2
>=20
> 22:28:11.223581 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 3=
2
> 22:28:11.223678 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 3=
2
>=20
>=20
> See how the answer is *very* slow ? Something like > 100 us ?
>=20

Never mind, this is OK, after proper irq affinity and tweaks on receive=
r :
(I should do same on other machine as well...)

(echo 1 >/proc/irq/default_smp_affinity) before up-ing bnx2 NIC

echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

and idle=3Dmwait  (or hpet and C2/C3 states are used on this machine an=
d=20
wakeups are slow)

# tcpdump -i eth0 not host 239.0.192.2 and port 9002 -n
23:25:02.137143 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
23:25:02.137212 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

23:25:03.137204 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
23:25:03.137288 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

23:25:04.137276 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
23:25:04.137355 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32


I presume powersaving improvements in last kernels are against
latencies goals...

