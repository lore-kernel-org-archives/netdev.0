From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: 12 Jul 2003 10:55:43 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057996543.1142.12.camel@hades>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5E2h62/6eEALX4jFy4kC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-5E2h62/6eEALX4jFy4kC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, I've separated out the SIT fix. A revised anycast fix will follow.

This is against 2.5.75. The patch will allow a host to set up SIT
tunnels using gateway routes to 6to4 addresses. Previously this only
worked with an IPv4-compatible address. Use of the deprecated
IPv4-compatible addresses should not be required.

Thanks,

	MikaL


--=-5E2h62/6eEALX4jFy4kC
Content-Disposition: attachment; filename=2.5.75-sit.udiff
Content-Type: text/x-patch; name=2.5.75-sit.udiff; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

diff -ur orig/linux-2.5.75/net/ipv6/sit.c linux-2.5.75/net/ipv6/sit.c
--- orig/linux-2.5.75/net/ipv6/sit.c	2003-07-10 23:14:48.000000000 +0300
+++ linux-2.5.75/net/ipv6/sit.c	2003-07-12 10:00:27.000000000 +0300
@@ -472,10 +472,13 @@
 			addr_type =3D ipv6_addr_type(addr6);
 		}
=20
-		if ((addr_type & IPV6_ADDR_COMPATv4) =3D=3D 0)
-			goto tx_error_icmp;
+		if (addr_type & IPV6_ADDR_COMPATv4)
+			dst =3D addr6->s6_addr32[3];
+		else
+			dst =3D try_6to4(addr6);
=20
-		dst =3D addr6->s6_addr32[3];
+		if (!dst)
+			goto tx_error_icmp;
 	}
=20
 	{

--=-5E2h62/6eEALX4jFy4kC--
