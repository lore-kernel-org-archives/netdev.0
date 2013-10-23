From: Wolfgang Walter <linux@stwm.de>
Subject: Fwd: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 19:01:57 +0200
Message-ID: <1572280.6B6hWj6GJJ@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49523 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392Ab3JWRB7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 13:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 23. Oktober 2013, 09:17:30 schrieben Sie:
> On Wed, 2013-10-23 at 17:57 +0200, Wolfgang Walter wrote:
> > Am Mittwoch, 23. Oktober 2013, 05:00:01 schrieb Eric Dumazet:
> > > On Wed, 2013-10-23 at 13:33 +0200, Wolfgang Walter wrote:
> > > > I don't know what this value actually means. But on 3.4.x it is=
 much
> > > > higher. On a machine with 512MB ram it is 32768, on a machine w=
ith 1GB
> > > > ram it is 262144 and with 16GB ram it is 4194304.
> > >=20
> > > Such huge values should not be needed. We should have at most one=
 dst
> > > per packet in flight.
> > >=20
> > > On a loaded router, a NIC not using BQL could queue around 16,000
> > > packets.
> > >=20
> > > Of course, Qdisc layers could also store a lot of packets, but us=
ing the
> > > default pfifo_fast is only adding 1000 packets per interface.
> > >=20
> > > I guess using 65536 as the default value should be safe and reaso=
nable
> > >=20
> > > Have you tried using 32768 or 65536 ?
> >=20
> > I use 32768 on routers with 512MB. They usually have around 50
> > ipsec-tunnels and only about 10 interfaces including vlan-interface=
s.
> >=20
> > On larger ones I set the bigger values from 3.4.x. That one with 16=
GB has
> > about 2000 ipsec-tunnels. It has about 80 interfaces (inlcuding vla=
n-
> > interfaces). Physically it has 8 interfaces with together about 30
> > hardware- queues.
>=20
> offlist
>=20
> OK, but you do not have the idea of actual number of entries ?
>=20
> If you use SLAB, you probably can try "grep dst /proc/slabinfo"

Ah, ok. I use SLUB, but SLABINFO=3Dy.

Without much traffic it is:

# grep dst /proc/slabinfo
xfrm_dst_cache      4435   4608    448   36    4 : tunables    0    0  =
  0 :=20
slabdata    128    128      0

on the big one.=20

I can recompile the kernels with SLAB instead of SLUB if SLAB gives mor=
e=20
usefull infos.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
