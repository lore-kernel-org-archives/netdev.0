From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: [PATCH] networking: [IPv6] Don't generate temporary for TUN devices
Date: Sat, 11 Jun 2005 15:12:40 +0200
Message-ID: <200506111512.42592.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, pekkas@netcore.fi
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hello,

Userland layer-2 tunneling devices allocated through the TUNTAP driver=20
(drivers/net/tun.c) have a type of ARPHRD_NONE, and have no link-layer=20
address. The kernel complains at regular interval when IPv6 Privacy=20
extension are enabled because it can't find an hardware address :

Dec 29 11:02:04 auguste kernel: __ipv6_regen_rndid(idev=3Dcb3e0c00):=20
cannot get EUI64 identifier; use random bytes.

IPv6 Privacy extensions should probably be disabled on that sort of=20
device. They won't work anyway. If userland wants a more usual=20
Ethernet-ish interface with usual IPv6 autoconfiguration, it will use a=20
TAP device with an emulated link-layer  and a random hardware address=20
rather than a TUN device.

As far as I could fine, TUN virtual device from TUNTAP is the very only=20
sort of device using ARPHRD_NONE as kernel device type.


Signed-off-by: R=C3=A9mi Denis-Courmont <rdenis@simphalempin.com>
--- a/net/ipv6/addrconf.c.orig	2004-12-29 10:50:27.000000000 +0100
+++ b/net/ipv6/addrconf.c	2004-12-29 10:50:41.000000000 +0100
@@ -372,6 +372,7 @@
 		ndev->regen_timer.data =3D (unsigned long) ndev;
 		if ((dev->flags&IFF_LOOPBACK) ||
 		    dev->type =3D=3D ARPHRD_TUNNEL ||
+		    dev->type =3D=3D ARPHRD_NONE ||
 		    dev->type =3D=3D ARPHRD_SIT) {
 			printk(KERN_INFO
 				"Disabled Privacy Extensions on device %p(%s)\n",

--=20
R=C3=A9mi Denis-Courmont
http://www.simphalempin.com/home/
