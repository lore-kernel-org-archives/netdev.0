From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC, PATCH 2.6.29.1] Ethernet V2.0 Configuration Testing Protocol
Date: Fri, 24 Apr 2009 09:36:14 +0200
Message-ID: <49F16BEE.2040902@cosmosbay.com>
References: <20090423221015.48b79b04.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>
To: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37592 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbZDXHgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 03:36:25 -0400
In-Reply-To: <20090423221015.48b79b04.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith a =E9crit :
> Hi,
>=20
> I'm hoping my attached implementation of the Ethernet V2.0 Configurat=
ion
> Testing Protocol could be reviewed, with eventual goal of inclusion i=
n
> the kernel.
>=20
> Ethernet V2.0 Configuration Testing Protocol (ECTP) is an old Etherne=
t
> testing protocol, specified in section 8 of the original Ethernet V2.=
0
> specification. It provides request/reply "ping" style testing at
> the Ethernet layer, testing of a path via a list of devices (i.e. a
> strict source route), and identification of ECTP capable devices via
> broadcast or multicast ECTP requests.
>=20
> I've had a go at implementing it for a number of reasons:
>=20
> o  My day job involves running networks, and eventually you start to
> wonder what is going on inside the devices you use. I think having a =
go
> at implementing something is a good way to learn.
>=20
> o  It's a very simple protocol (a single frame format), so it could b=
e
> a good starting point for people who'd like to understand more about
> how networking works in the Linux kernel. I've tried to make the
> implementation easy for people to follow what it is doing.
>=20
> o  It's actually quite useful - every now and then people in networki=
ng
> say, "wouldn't it be great if there was an Ethernet ping which didn't
> require IP to work". Recent Ethernet OAM standards provide that, but
> they're a lot more complicated to implement than ECTP, and I needed
> something simple to start with :-)
>=20
> o  It might finally make Linux completely compliant with the Ethernet
> V2.0 specification which says that the protocol is required!
>=20
> I've also put together a testing utility. I need to put a bit more
> polish on it, and find somewhere to host it, which I'll do in the nex=
t
> few days. Here are a couple of examples of it's use:
>=20
> o  a unicast ECTP "ping"
>=20
> [root@opy ectpping]# ./ectpping -i tap0 52:54:00:12:34:56
> ECTPPING 52:54:00:12:34:56 (qa64-eth0) using tap0
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D0 time=3D0.0=
00346 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D1 time=3D0.0=
00209 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D2 time=3D0.0=
00203 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D3 time=3D0.0=
00187 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D4 time=3D0.0=
00210 sec
> ^C
> ---- 52:54:00:12:34:56 (qa64-eth0) ECTPPING Statistics ----
> 5 packets transmitted, 5 packets received, 0.000000% packet loss
> round-trip (sec)  min/avg/max/total =3D 0.000187/0.000231/0.000346/0.=
001155
>=20
>=20
> o  a multicast ECTP "ping"
>=20
> [root@opy ectpping]# ./ectpping -i tap0
> ECTPPING cf:00:00:00:00:00 (loopback-assist) using tap0
> 106 bytes from 52:54:00:12:34:57 (qa64-eth1): ectp_seq=3D0 time=3D0.0=
18630 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D0 time=3D0.0=
56334 sec
> 106 bytes from 52:54:00:12:34:58 (qa64-eth2): ectp_seq=3D0 time=3D0.0=
56656 sec
> 106 bytes from 52:54:00:12:34:58 (qa64-eth2): ectp_seq=3D1 time=3D0.0=
20351 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D1 time=3D0.0=
24241 sec
> 106 bytes from 52:54:00:12:34:57 (qa64-eth1): ectp_seq=3D1 time=3D0.0=
31350 sec
> 106 bytes from 52:54:00:12:34:58 (qa64-eth2): ectp_seq=3D2 time=3D0.0=
49382 sec
> 106 bytes from 52:54:00:12:34:57 (qa64-eth1): ectp_seq=3D2 time=3D0.0=
67358 sec
> 106 bytes from 52:54:00:12:34:56 (qa64-eth0): ectp_seq=3D2 time=3D0.0=
74230 sec
> ^C
> ---- cf:00:00:00:00:00 (loopback-assist) ECTPPING Statistics ----
> 3 packets transmitted, 9 packets received, 3.00 times packet increase
> round-trip (sec)  min/avg/max/total =3D 0.018630/0.044281/0.074230/0.=
398532
>=20
> While I'm finishing off the utility, I thought I'd post the kernel
> source to get it out there for people to have a look at. I'd really
> appreciate any suggestions for improvement, or any pointers to where
> I've done the wrong thing or had any miss understandings. The patch i=
s
> against 2.6.29.1.
>=20
> Thanks very much,
> Mark.
>=20
> (please CC me, as I'm not on the mailing list)
>=20

Hello Mark

I am trying to find how ETCP could be useful :)

Could bonding use ETCP as a third way to validate a slave is operationa=
l ?

=46irst way is mii-mon (link presence to next hop)
  -> Very lazy since we can be connected to a switch that lost all conn=
ectivity to other equipments.

Second way is arp_ping (list of 1 to 16 IP addresses)
  -> broadcast messages.
   If many hosts are on [V]LAN, and small arp_interval, this can genera=
te extra trafic.

Third way : ETCP messages sent to given MAC address ?
  (Unicast messages, and no VLAN troubles...)
 I presume most routers support ETCP?

Is ectpping needing your kernel patches, or can it work with current ke=
rnel ?
If not too large, you could post its source on this list.

Thank you

