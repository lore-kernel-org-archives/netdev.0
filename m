From: "Andre Tomt" <andre@tomt.net>
Subject: unable to add ipv6 default route in 2.4.21-rc1 + latest bkbits.net pieces
Date: Fri, 2 May 2003 20:25:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002001c310d8$2bb57b00$0a01ff0a@slurv>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I noticed a problem on one of our semi-production systems today, it
suddenly lacked a working ipv6 default route. After further
investigation, even the raw iproute commands failed (I had it all set up
in /etc/network/interfaces, a debian network configuration file).

It seems to me something changed in 2.4.21? It certainly broke my
iproute. 2.4.20 works fine (well, with many fixes not related to ipv6).
iproute is debian version 20010824-9 (from unstable/sid).

kvass:~# ip -6 route add default via 2003:730:f:3:: dev eth0
RTNETLINK answers: Invalid argument

and for good measure:
kvass:~# ip -6 route add 2000::/3 via 2003:730:f:3:: dev eth0
RTNETLINK answers: Invalid argument

2001:730:f:3::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss
1440
fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
ff00::/8 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
unreachable default dev lo  proto none  metric -1  error -101

kvass:~# ip -6 route
2001:730:f:3::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss
1440
fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
ff00::/8 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
default dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
unreachable default dev lo  proto none  metric -1  error -101

Theres a defaultroute there pointing to eth0 with noe gw set, that seems
to be some kind of, err, default. Removing it and (trying, in this case)
adding a proper default route has no effect. I even tried to recompile
iproute, but that gave the same symptoms. Not sure if dpkg-buildpackage
actually buildt it against /usr/include/linux or
/usr/src/linux/include/linux though.

Any ideas? I know there have been some deal of ipv6 fixes and additions
going into 2.4.21, did this break something?

--=20
Cheers,
Andr=E9 Tomt
andre@tomt.net
