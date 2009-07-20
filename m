From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Fix error return for setsockopt(SO_TIMESTAMPING)
Date: Mon, 20 Jul 2009 13:47:04 +0300
Message-ID: <1248086824-18836-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:22909 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbZGTKot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 06:44:49 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KAibog017212
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 13:44:38 +0300
Received: from localhost.localdomain (esdhcp03592.research.nokia.com [172.21.35.92])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KAibud017553
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 13:44:38 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

I guess it should be -EINVAL rather than EINVAL. I have not checked
when the bug came in. Perhaps a candidate for -stable?

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/core/sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 6354863..73b5af5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -631,7 +631,7 @@ set_rcvbuf:
=20
 	case SO_TIMESTAMPING:
 		if (val & ~SOF_TIMESTAMPING_MASK) {
-			ret =3D EINVAL;
+			ret =3D -EINVAL;
 			break;
 		}
 		sock_valbool_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE,
--=20
1.6.0.4

