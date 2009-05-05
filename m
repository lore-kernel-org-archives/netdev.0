From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bond + tc regression ?
Date: Tue, 05 May 2009 18:31:47 +0200
Message-ID: <4A0069F3.5030607@cosmosbay.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40143 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbZEEQbx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 12:31:53 -0400
In-Reply-To: <1241538358.27647.9.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko a =E9crit :
> Hi,
>=20
> I have a traffic policing setup running on Linux, serving about 800 m=
bps
> of traffic. Due to the traffic growth I decided to employ network
> interface bonding to scale over a single GigE.
>=20
> The Sun X4150 server has 2xIntel E5450 QuadCore CPUs and a total of f=
our
> built-in e1000e interfaces, which I grouped into two bond interfaces.
>=20
> With kernel 2.6.23.1, everything works fine, but the system locked up
> after a few days.
>=20
> With kernel 2.6.28.7/2.6.29.1, I get 10-20% packet loss. I get packet=
 loss as
> soon as I put a classful qdisc, even prio, without even having any
> classes or filters. TC prio statistics report lots of drops, around 1=
0k
> per sec. With exactly the same setup on 2.6.23, the number of drops i=
s
> only 50 per sec.
>=20
> On both kernels, the system is running with at least 70% idle CPU.
> The network interrupts are distributed accross the cores.

You should not distribute interrupts, but bound a NIC to one CPU
>=20
> I thought it was a e1000e driver issue, but tweaking e1000e ring buff=
ers
> didn't help. I tried using e1000 on 2.6.28 by adding necessary PCI ID=
s,
> I tried running on a different server with bnx cards, I tried disabli=
ng
> NO_HZ and HRTICK, but still I have the same problem.
>=20
> However, if I don't utilize bond, but just apply rules on normal ethX
> interfaces, there is no packet loss with 2.6.28/29.=20
>=20
> So, the problem appears only when I use 2.6.28/29 + bond + classful t=
c
> combination.=20
>=20
> Any ideas ?
>=20

Yes, we need much more information :)
Is it a forwarding setup only ?

cat /proc/interrupts
cat /proc/net/bonding/bond0
cat /proc/net/bonding/bond1
tc -s -d qdisc
mpstat -P ALL 10
ifconfig -a

and so on ...


