From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 18:41:32 +0100
Message-ID: <1324575692.2586.6.camel@edumazet-laptop>
References: <4EF200BB.7000209@bootc.net>
	    <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	    <4EF2117F.6000803@bootc.net>
	    <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	    <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	    <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	   <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	   <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
	  <1324528656.2621.19.camel@edumazet-laptop> <4EF300B2.3050903@bootc.net>
	 <1324563353.2153.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF352A2.2090604@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EF352A2.2090604@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 15:54 +0000, Chris Boot a =C3=A9c=
rit :

> Eric,
>=20
> I'm seeing a new problem now with IPv6 on my bridge, I don't know if=20
> it's related to any of the patches you gave me.
>=20
> Basically, I have eth0 and eth1 in a balance-rr bond (bond0), and thi=
s=20
> is added as a port in a bridge. When the bond and bridge are freshly=20
> brought up, IPv4 works fine but it appears to be deaf to IPv6 traffic=
=2E=20
> It stays this way until I run 'tcpdump -i eth0' and 'tcpdump -i eth1'=
=2E=20
> If I run tcpdump with the -p flag to not enable promiscuous mode, the=
=20
> interfaces remain deaf. Only if they enter promiscuous mode do they=20
> start to listen to each other. It also doesn't help to run tcpdump=20
> against bond0 or br0 at all.
>=20
> I'm not sure if once I've killed tcpdump they become deaf again, but =
I=20
> have enough IPv6 traffic to keep the neighbour entry alive.

Thats probably a separate issue. It would be better to open a new threa=
d
on netdev, instead of continuing this one.

IPv6 needs multicast capabilities, so maybe balance-rr bonding mode is
not propagating multicat filters properly on both nics.

It might be a problem on one of your NIC.

(tcpdump automatically installs promiscous mode, so all multicast frame=
s
are received, regardless of previous multicast filters in place)
