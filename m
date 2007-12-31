From: Bodo Eggert <7eggert@gmx.de>
Subject: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 13:09:43 +0100 (CET)
Message-ID: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
To: Jan Engelhardt <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, Adrian Bunk <bunk@kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:57320 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382AbXLaMJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 07:09:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
on normal systems. This is especially true since udev needs these sockets
and fails to run if UNIX=m.

Signed-Off-By: Bodo Eggert <7eggert@gmx.de>

---
Last minute change: I decided against making it a bool because embedded 
folks might depend on a small kernel image. Edited in the patch below.

diff -X dontdiff -pruN linux-2.6.23.base/net/unix/Kconfig linux-2.6.23.socket-y/net/unix/Kconfig
--- linux-2.6.23.base/net/unix/Kconfig	2006-11-29 22:57:37.000000000 +0100
+++ linux-2.6.23.socket-y/net/unix/Kconfig	2007-12-31 12:57:44.000000000 +0100
@@ -3,7 +3,8 @@
 #
 
 config UNIX
-	tristate "Unix domain sockets"
+	tristate "Unix domain sockets" if EMBEDDED
+	default y
 	---help---
 	  If you say Y here, you will include support for Unix domain sockets;
 	  sockets are the standard Unix mechanism for establishing and

-- 
            A. Top posters
            Q. What's the most annoying thing on Usenet?
