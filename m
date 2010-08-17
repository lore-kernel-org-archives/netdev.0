From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 08:00:02 +0200
Message-ID: <1282024802.2487.687.camel@edumazet-laptop>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
	 <1281953960.2524.23.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
	 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 ao=C3=BBt 2010 =C3=A0 07:35 +0200, Thomas Habets a =C3=A9cr=
it :
> On Mon, 16 Aug 2010, Thomas Habets wrote:
> > Am I not allowed to add addresses to lo? That I've deconfigured thi=
s address=20
> > and rebooted the box to check if this matters.
>=20
> It didn't help.
>=20
> > I will re-check ethtool and Cisco router output for mismatches when=
 it breaks=20
> > again to make sure that there's no change or errors counting up.
>=20
> IPv6 is currently not working and it's still 1000 Full on both sides=20
> ("show int GiX/Y" and "ethtool eth0").
> No errors in "ethtool -S eth0" or "show int GiX/Y".
>=20
> "ethtool eth0" output is the same as yesterday.
>=20
> Here's the addresses and routing table as they are now, and have been=
=20
> since reboot:
>=20
> $ ip -6 a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
>      inet6 ::1/128 scope host
>         valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>      inet6 2a00:800:752:1::5c:2/112 scope global
>         valid_lft forever preferred_lft forever
>      inet6 fe80::224:81ff:fea3:4424/64 scope link
>         valid_lft forever preferred_lft forever
>=20
>=20
> $ ip -6 r sh
> 2a00:800:752:1::5c:0/112 dev eth0  proto kernel  metric 256  mtu 1500
> advmss 1440 hoplimit 4294967295
>=20
> fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
> hoplimit 4294967295
>=20
> default via 2a00:800:752:1::5c:1 dev eth0  metric 1024  mtu 1500 advm=
ss
> 1440 hoplimit 4294967295
>=20
> $ ip -6 ne sh
> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router STALE
>=20
> [try ping6 again, no reply]
>=20
> $ ip -6 ne sh
> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router DELAY
>=20
> [try ping6 again, no reply]
>=20
> $ ip -6 ne sh
> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router REACHAB=
LE
>=20

This seems a bit different than previous mail. Apparently discovery now
works ?

Could you have a tcpdump on both sides ?

Maybe your host is OK, but other side drops your ICMP packets ?

> [try ping6 again, no reply]
>=20
> Configured network with /etc/network/interfaces:
>=20
> auto lo
> iface lo inet loopback
>=20
> allow-hotplug eth0
> iface eth0 inet static
>  	address x.x.x.x
>  	netmask 255.255.255.252
>  	broadcast x.x.x.x
>  	gateway x.x.x.x
>  	up ip a a 2a00:800:752:1::5c:2/112 dev eth0
>  	up ip r a default via 2a00:800:752:1::5c:1
>  	dns-nameservers x.x.x.x
>  	dns-search xxxx.net
