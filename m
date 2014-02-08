From: Wolfgang Walter <linux@stwm.de>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Sun, 09 Feb 2014 00:17:15 +0100
Message-ID: <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1720760.5dnaEcLin5@h2o.as.studentenwerk.mhn.de> <20140207222227.GC16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:40490 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbaBHXRR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 18:17:17 -0500
In-Reply-To: <20140207222227.GC16198@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 7. Februar 2014, 23:22:27 schrieb Hannes Frederic Sowa:
> Hi!
>=20
> On Fri, Feb 07, 2014 at 07:17:40PM +0100, Wolfgang Walter wrote:
> > Am Freitag, 7. Februar 2014, 18:56:41 schrieb Hannes Frederic Sowa:
> > > Hi!
> > >=20
> > > On Fri, Feb 07, 2014 at 06:47:07PM +0100, Wolfgang Walter wrote:
> > > > with kernel 3.13 I have a problem with isatap tunnels receiving
> > > > fragmented
> > > > ipv6 udp packets.
> > >=20
> > > Which was the last known version that did work?
> >=20
> > I think 3.12 had no problems, but I'm not sure. I test this tonight=
=2E

3.12 is indeed fine. But this is probably because of:

ethtool -k is0
=2E...
udp-fragmentation-offload: off [fixed]
=2E...


>=20
> Could you give me a bit more details on your setup, please?
>=20
> I just tested a setup with UFO packets in sit tunnels and it worked
> properly for me (on net).
>=20

host A (which shows the problem with kernel 3.13):

$ ip addr ls eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP=20
group default qlen 1000
    link/ether 11:22:33:44:55:66 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/24 brd 192.168.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 2001:1111:2222:aaaa:0:5efe:c0a8:101/120 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::1322:33ff:fe44:5566/64 scope link=20
       valid_lft forever preferred_lft forever

$ ip addr ls is0
14: is0: <NOARP,UP,LOWER_UP> mtu 1280 qdisc noqueue state UNKNOWN group=
=20
default=20
    link/sit 192.168.1.1 brd 0.0.0.0
    inet6 2001:1111:2222:aaaa:0:5efe:c0a8:101/64 scope global dynamic=20
       valid_lft 85977sec preferred_lft 13977sec
    inet6 fe80::5efe:c0a8:101/64 scope link=20
       valid_lft forever preferred_lft forever



The other host B is in the same isatap-subnet (but a different ipv4-sub=
net):

$ ip addr ls eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP=20
group default qlen 1000
    link/ether 11:22:33:44:55:ee brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.1/24 brd 192.168.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::1322:33ff:fe44:55ee/64 scope link=20
       valid_lft forever preferred_lft forever


$ ip addr ls is0
10: is0: <NOARP,UP,LOWER_UP> mtu 1280 qdisc noqueue state UNKNOWN group=
=20
default=20
    link/sit 192.168.10.1 brd 0.0.0.0
    inet6 2001:1111:2222:aaaa:0:5efe:c0a8:a01/64 scope global dynamic=20
       valid_lft 85977sec preferred_lft 13977sec
    inet6 fe80::5efe:c0a8:a01/64 scope link=20
       valid_lft forever preferred_lft forever


The application I see this is strongswan (ikev2). When it establishes a=
n=20
connection it sends udp-packets to large for is0 (here 1316 data-bytes,=
=20
strongswan says).

=46or the tests I unloaded the netfilter modules so there should be no=20
interference with the firewall or conntrack etc.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
