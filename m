From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: ipv6: using source address from wrong interface
Date: Fri, 27 Feb 2015 12:14:40 -0500
Message-ID: <1425057280.20456.105.camel@interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/eiz1AwBHdU7iYqzit+N"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52848 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbbB0RUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 12:20:07 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YROa4-0005gT-Gd
	for netdev@vger.kernel.org; Fri, 27 Feb 2015 18:20:04 +0100
Received: from d67-193-232-12.home3.cgocable.net ([67.193.232.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:20:04 +0100
Received: from brian by d67-193-232-12.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:20:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/eiz1AwBHdU7iYqzit+N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

I have a situation here on a Linux 3.10.36 OpenWRT router where I have
two IPv6 interfaces:

6in4-henet Link encap:IPv6-in-IPv4 =20
          inet6 addr: 2001:613:1c:28f::2/64 Scope:Global
          inet6 addr: fe80::587b:2005/128 Scope:Link
          UP POINTOPOINT RUNNING NOARP  MTU:1280  Metric:1
          RX packets:98181547 errors:0 dropped:0 overruns:0 frame:0
          TX packets:52168025 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:113677566440 (105.8 GiB)  TX bytes:5441656803 (5.0 GiB)

6to4-foo6 Link encap:IPv6-in-IPv4 =20
          inet6 addr: ::88.123.32.5/128 Scope:Compat
          inet6 addr: 2002:587b:2005::1/16 Scope:Global
          UP RUNNING NOARP  MTU:1280  Metric:1
          RX packets:54095 errors:6 dropped:0 overruns:0 frame:0
          TX packets:107525 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:7650028 (7.2 MiB)  TX bytes:11379920 (10.8 MiB)

The LAN interface on the other side of the router is:

br-lan    Link encap:Ethernet  HWaddr C0:A0:BB:ED:38:D1 =20
          inet addr:10.75.22.253  Bcast:10.75.22.255  Mask:255.255.255.0
          inet6 addr: 2001:613:1d:28f::1/64 Scope:Global
          inet6 addr: fe80::c2a0:bbff:feed:38d1/64 Scope:Link
          inet6 addr: 2002:587b:2005::1/60 Scope:Global
          inet6 addr: fd31:aeb1:48df::1/60 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:867428811 errors:0 dropped:0 overruns:0 frame:0
          TX packets:693644720 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:429976183525 (400.4 GiB)  TX bytes:749419207609 (697.9 G=
iB)

But when the router needs to generate an ICMP6 "packet too big" message
back to the sender, the wrong interface's address is being used as the
source address.  Witness tcpdump on the 6in4-henet interface:

11:52:00.206228 IP6 2001:613:1d:28f:224:d7ff:fe7b:1f24.55548 > 2001:8d8:100=
1:27f:2736:6506:2744:808.443: Flags [S], seq 3466582922, win 28800, options=
 [mss 1440,sackOK,TS val 4004937347 ecr 0,nop,wscale 7], length 0
11:52:00.310829 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [S.], seq 250830792, ack 3466582923, wi=
n 14400, options [mss 1440,nop,wscale 7], length 0
11:52:00.314706 IP6 2001:613:1d:28f:224:d7ff:fe7b:1f24.55548 > 2001:8d8:100=
1:27f:2736:6506:2744:808.443: Flags [.], ack 1, win 225, length 0
11:52:00.449646 IP6 2001:613:1d:28f:224:d7ff:fe7b:1f24.55548 > 2001:8d8:100=
1:27f:2736:6506:2744:808.443: Flags [P.], seq 1:107, ack 1, win 225, length=
 106
11:52:00.551007 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], ack 107, win 113, length 0
11:52:00.662576 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 1:1421, ack 107, win 113, leng=
th 1420
11:52:00.662867 IP6 2002:587b:2005::1 > 2001:8d8:1001:27f:2736:6506:2744:80=
8: ICMP6, packet too big, mtu 1280, length 1240
11:52:00.663178 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 1421:2841, ack 107, win 113, l=
ength 1420
11:52:00.663380 IP6 2002:587b:2005::1 > 2001:8d8:1001:27f:2736:6506:2744:80=
8: ICMP6, packet too big, mtu 1280, length 1240
11:52:00.663508 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 2841:4261, ack 107, win 113, l=
ength 1420
11:52:00.663689 IP6 2002:587b:2005::1 > 2001:8d8:1001:27f:2736:6506:2744:80=
8: ICMP6, packet too big, mtu 1280, length 1240
11:52:00.663793 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 4261:4321, ack 107, win 113, l=
ength 60
11:52:00.667654 IP6 2001:613:1d:28f:224:d7ff:fe7b:1f24.55548 > 2001:8d8:100=
1:27f:2736:6506:2744:808.443: Flags [.], ack 1, win 234, length 0
11:52:01.382115 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 1:1421, ack 107, win 113, leng=
th 1420
11:52:01.382349 IP6 2002:587b:2005::1 > 2001:8d8:1001:27f:2736:6506:2744:80=
8: ICMP6, packet too big, mtu 1280, length 1240
11:52:02.826238 IP6 2001:8d8:1001:27f:2736:6506:2744:808.443 > 2001:613:1d:=
28f:224:d7ff:fe7b:1f24.55548: Flags [.], seq 1:1421, ack 107, win 113, leng=
th 1420
11:52:02.826471 IP6 2002:587b:2005::1 > 2001:8d8:1001:27f:2736:6506:2744:80=
8: ICMP6, packet too big, mtu 1280, length 1240

Notice that interface 6in4-henet is being used to make the connection to
2001:8d8:1001:27f:2736:6506:2744:808 from
2001:613:1d:28f:224:d7ff:fe7b:1f24 however when the router needs to send
an ICMP6 packet, it is using the source address from the 6to4-foo6
interface even though the packet was received on and needs to be sent
out on the 6in4-henet interface.

Why would this be?

Cheers,
b.


--=-/eiz1AwBHdU7iYqzit+N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABAgAGBQJU8KYBAAoJENrB0DQWy8ig1kkH/0N7W/WqeZTsR2aEnU9rDFbW
Jo3xP/Zr/MDUs0d8FbLjxRRyOQzTrvFp6nZvXx9yli+aXN4RVkLZA2AocsVl+rGq
dYBtVClrtc5dbxLEpqhBQ53IFdxAhr7SQBBRTthdn03N0mERFwP24EjiVImxSvPD
t4YLiH+XyMGJH8H00Dk8uazO61lUYclUIxM9BxUtPujQEozfWtDsTE1nv3lI9GNN
gYpyqTNrwgOZDIlOPTHk2ezs+08tweeYuxbbQb7s5Kz5ssx57yMuFWOo1GXi6J9R
LZE4WKZFV650SS4eD0j7jvoO3ge643XE8lana2SoQiv6pyv4aZ/S4951aLB27G0=
=mQJT
-----END PGP SIGNATURE-----

--=-/eiz1AwBHdU7iYqzit+N--
