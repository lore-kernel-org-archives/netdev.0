From: Stewart Brodie <stewart@metahusky.net>
Subject: [PATCH] packet.7: Indicate CAP_NET_BIND_SERVICE capability is required for binding packet sockets
Date: Wed, 25 Nov 2015 17:26:49 +0000
Message-ID: <gemini.nydsgp00qxyqa08jr.stewart@metahusky.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="679423162--749166995--1339358089"
Cc: netdev@vger.kernel.org, linux-man@vger.kernel.org
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metahusky.net ([212.13.203.229]:62929 "EHLO metahusky.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbbKYR4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 12:56:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--679423162--749166995--1339358089
Content-Type: text/plain; charset=us-ascii


Adds a note to packet.7 that the calling process must have the
CAP_NET_BIND_SERVICE capability in order to call bind on packet sockets.

The linux/capability.h header file comments for CAP_NET_BIND_SERVICE do not
document this requirement either.  I did take a brief look in the kernel
source code of both the older kernel I'm using and also in 4.4-rc2 but found
no obvious check for this capability check in files in net/packet, but I'm
not familiar with this code at all.

I discovered this after debugging unexpected permission denied errors in
busybox's udhcpc (when it attempts to renew leases).  It is creating the
socket using:  socket(PF_PACKET, SOCK_DGRAM, htons(ETH_P_IP))   It is
possible that it is only with certain type and protocol parameters? If so,
this patch would need to be revised to reflect that.

Patch generated against man-pages-4.02.


diff -ur a/man-pages-4.02/man7/packet.7 b/man-pages-4.02/man7/packet.7
--- a/man-pages-4.02/man7/packet.7      2015-08-08 17:24:11.000000000 +0100
+++ b/man-pages-4.02/man7/packet.7      2015-11-24 18:44:37.341815032 +0000
@@ -97,6 +97,12 @@
 and
 .IR sll_ifindex .
 
+Only processes with the
+.B CAP_NET_BIND_SERVICE
+capability may use
+.BR bind (2)
+on packet sockets.
+
 The
 .BR connect (2)
 operation is not supported on packet sockets.


-- 
Stewart Brodie


--679423162--749166995--1339358089
Content-Type: text/x-patch; name="packet.7.diff"
Content-Disposition: attachment; filename="packet.7.diff"
Content-Transfer-Encoding: quoted-printable

diff -ur a/man-pages-4.02/man7/packet.7 b/man-pages-4.02/man7/packet.7=0A=
--- a/man-pages-4.02/man7/packet.7	2015-08-08 17:24:11.000000000 +0100=0A=
+++ b/man-pages-4.02/man7/packet.7	2015-11-24 18:44:37.341815032 +0000=0A=
@@ -97,6 +97,12 @@=0A=
 and=0A=
 .IR sll_ifindex .=0A=
=20=0A=
+Only processes with the=0A=
+.B CAP_NET_BIND_SERVICE=0A=
+capability may use=0A=
+.BR bind (2)=0A=
+on packet sockets.=0A=
+=0A=
 The=0A=
 .BR connect (2)=0A=
 operation is not supported on packet sockets.=0A=

--679423162--749166995--1339358089--
