From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: [resend] [PATCH] IPv4: Reset scope when changing address
Date: Sat, 16 Feb 2008 12:45:31 +0100
Message-ID: <87bq6hazvo.fsf@obelix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50779 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbYBPLpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2008 06:45:42 -0500
Received: from obelix.mork.no (obelix.mork.no [IPv6:2001:16d8:ffb4:2:205:4eff:fe4c:7769])
	by canardo.mork.no (8.13.8/8.13.8) with ESMTP id m1GBjXHA030803
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 16 Feb 2008 12:45:35 +0100
Received: from bjorn by obelix.mork.no with local (Exim 4.63)
	(envelope-from <bjorn@mork.no>)
	id 1JQLU3-0005pU-HL
	for netdev@vger.kernel.org; Sat, 16 Feb 2008 12:45:31 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<#part type=3Dtext/plain nofile=3Dyes>
Any comments on this?  Apparently introduced in 2.1.68, so there's not
much hurry.  But I'd still like to hear whether that analysis is correc=
t
or not...
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=3D"=3D=3D-=3D-=3D"

The bug did bite at least one user, who did have to resort to rebooting
the system after an "ifconfig eth0 127.0.0.1" typo. =20

Deleting the address and adding a new is a less intrusive workaround.
But I still beleive this is a bug that should be fixed.  Some way or
another.

Another possibility would be to remove the scope mangling based on
address.  This will always be incomplete (are 127/8 the only address
space with host scope requirements?)


Bj=81=F8rn


<#part type=3Dtext/x-diff filename=3D"devinet-rt_scope-fix.patch" dispo=
sition=3Dinline nofile=3Dyes>
We set the scope to RT_SCOPE_HOST if an IPv4 interface is configured
with a loopback address (127/8).  The scope is never reset, and will
remain set to RT_SCOPE_HOST after changing the address. This patch
resets the scope if the address is changed again, to restore normal
functionality.

Signed-off-by: Bjorn Mork <bjorn@mork.no>

--=3D=3D-=3D-=3D

 devinet.c |    1 +
 1 file changed, 1 insertion(+)


--- linux-2.6.24-rc8.orig/net/ipv4/devinet.c	2008-01-16 05:22:48.000000=
000 +0100
+++ linux-2.6.24-rc8/net/ipv4/devinet.c	2008-01-23 19:17:30.000000000 +=
0100
@@ -753,6 +753,7 @@
 			inet_del_ifa(in_dev, ifap, 0);
 			ifa->ifa_broadcast =3D 0;
 			ifa->ifa_anycast =3D 0;
+			ifa->ifa_scope =3D 0;
 		}
=20
 		ifa->ifa_address =3D ifa->ifa_local =3D sin->sin_addr.s_addr;

--=3D=3D-=3D-=3D
Content-Type: text/plain; charset=3Diso-8859-1



--=3D=3D-=3D-=3D--
