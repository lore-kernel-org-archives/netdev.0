From: Victor NOEL <victor.noel@crazydwarves.org>
Subject: zd1211rw (2.6.26.5) and ipv6
Date: Tue, 16 Sep 2008 19:50:09 +0200
Message-ID: <20080916175008.GR4610@crazydwarves.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="o6aug3O60clXg2rj"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crazydwarves.org ([82.233.236.81]:35953 "HELO
	mail.crazydwarves.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753105AbYIPR5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 13:57:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--o6aug3O60clXg2rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

After a little investigation (see after), I came to the conclusion
there was something strange with the zd1211rw wifi driver (or
maybe mac80211-based ones like it happened in the past ?) and ipv6
(at least with autoconfiguration).

I am on Archlinux with kernel 2.6.26.5 kernel behind a router
connecting me to internet by ipv4 and ipv6.

After a little discussion with John W. Linville on irc, he
redirected me to this mailing list.

The idea is that I connect to a wireless network with wpa
protection, get my ipv4 address by dhcp and my ipv6 address by
autoconfiguration : the ip is ok, the routes are goods, I can
ping6 myself, I can ping6 the router (the next hop for default
route) but I can't go out of this network.

If I do the same but with ethernet (same router serving both
ethernet and wifi), all the ip configuration, routes, neighbors
are the same, but I can go out on the net.

Nothing in dmesg.

Of course ipv6 works on other boxes (I tried a windows on a
laptop, and the routes used are the same too)

This is what I have with both ethernet and wifi :
First wifi :
[victor@pistache ~]$ ip -6 route
2a01:e35:2f1f:8f10::/64 dev wlan0  proto kernel  metric 256 expires 86386se=
c mtu 1480 advmss 1420 hoplimit 4294967295
fe80::/64 dev wlan0  metric 256  mtu 1480 advmss 1420 hoplimit 4294967295  =
                                          =20
default via fe80::207:cbff:fec8:d1d2 dev wlan0  proto kernel metric 1024  e=
xpires 1797sec mtu 1480 advmss 1420 hoplimit 64

[victor@pistache ~]$ ifconfig
lo        Link encap:Local Loopback                                        =
                                             =20
          inet addr:127.0.0.1  Mask:255.0.0.0                              =
                                             =20
          inet6 addr: ::1/128 Scope:Host                                   =
                                             =20
          UP LOOPBACK RUNNING  MTU:16436  Metric:1                         =
                                             =20
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0              =
                                             =20
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0            =
                                             =20
          collisions:0 txqueuelen:0
          RX bytes:748 (748.0 b)  TX bytes:748 (748.0 b)

wlan0     Link encap:Ethernet  HWaddr 00:60:B3:EA:19:97
          inet addr:192.168.0.1  Bcast:192.168.0.255 Mask:255.255.255.0
          inet6 addr: 2a01:e35:2f1f:8f10:5:2b83:18cf:89f1/64 Scope:Global
          inet6 addr: 2a01:e35:2f1f:8f10:260:b3ff:feea:1997/64 Scope:Global
          inet6 addr: fe80::260:b3ff:feea:1997/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:18242 errors:0 dropped:0 overruns:0 frame:0
          TX packets:19472 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:16047994 (15.3 Mb)  TX bytes:2862642 (2.7 Mb)

wmaster0  Link encap:UNSPEC  HWaddr 00-60-B3-EA-19-97-00-00-00-00-00-00-00-=
00-00-00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
[victor@pistache ~]$ ping6 www.kame.net
PING www.kame.net(orange.kame.net) 56 data bytes
^C
--- www.kame.net ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4011ms

[victor@pistache ~]$ tracepath6 www.kame.net
 1?: [LOCALHOST]                      pmtu 1480
 1:  no reply
^C

[victor@pistache ~]$ ip -6 neigh show
fe80::207:cbff:fec8:d1d2 dev wlan0 lladdr 00:07:cb:c8:d1:d2 router STALE


And ethernet :
[victor@pistache ~]$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0E:A6:AA:D4:55
          inet addr:192.168.0.21  Bcast:192.168.0.255 Mask:255.255.255.0
          inet6 addr: 2a01:e35:2f1f:8f10:20e:a6ff:feaa:d455/64 Scope:Global
          inet6 addr: fe80::20e:a6ff:feaa:d455/64 Scope:Link
          inet6 addr: 2a01:e35:2f1f:8f10:c8bc:d444:cd3:ca45/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:36 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1548 (1.5 Kb)  TX bytes:7671 (7.4 Kb)
          Interrupt:22

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:748 (748.0 b)  TX bytes:748 (748.0 b)

[victor@pistache ~]$ ip -6 route
2a01:e35:2f1f:8f10::/64 dev eth0  proto kernel  metric 256 expires 86369sec=
 mtu 1480 advmss 1420 hoplimit 4294967295
fe80::/64 dev eth0  metric 256  mtu 1480 advmss 1420 hoplimit 4294967295
default via fe80::207:cbff:fec8:d1d2 dev eth0  proto kernel metric 1024  ex=
pires 1780sec mtu 1480 advmss 1420 hoplimit 64

[victor@pistache ~]$ ping6 www.kame.net
PING www.kame.net(orange.kame.net) 56 data bytes
64 bytes from orange.kame.net: icmp_seq=3D1 ttl=3D50 time=3D283 ms
^C
--- www.kame.net ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 283.337/283.337/283.337/0.000 ms

[victor@pistache ~]$ tracepath6 www.kame.net
 1?: [LOCALHOST]                      pmtu 1480
 1:  2a01:e35:2f1f:8f10::1                      1.078ms
 2:  6to4-b8-e3.intf.routers.proxad.net        30.465ms
 3:  bzn-crs16-1-te1-1-0-7.intf.routers.proxad.net  32.224ms
 4:  2001:5a0:0:300::25                        31.212ms
 5:  2001:5a0:0:300::2a                       107.376ms
 6:  if-1-0.core2.nto-newyork.ipv6.teleglobe.net 108.126ms
 7:  p16-0-1-1.r20.nycmny01.us.bb.gin.ntt.net asymm  8 107.843ms
^C

[victor@pistache ~]$ ip -6 neigh show
fe80::207:cbff:fec8:d1d2 dev eth0 lladdr 00:07:cb:c8:d1:d2 router STALE

That's all for now, I hope nothing is missing.

Thanks you for your help,

Victor

--o6aug3O60clXg2rj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIz/HQQ7uDv7gIkeURApTuAKChCp3TwiCKHVhSz2OaLBdGKbFlRQCfQMhi
molaLvOLQQ3rFyM90Tg4p5E=
=tA8/
-----END PGP SIGNATURE-----

--o6aug3O60clXg2rj--
