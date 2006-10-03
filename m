From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] mv643xx_eth: Fix ethtool stats
Date: Tue, 03 Oct 2006 18:42:32 +0200
Message-ID: <1159893752.6580.27.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sakura.staff.proxad.net ([213.228.1.107]:2255 "EHLO
	sakura.staff.proxad.net") by vger.kernel.org with ESMTP
	id S932261AbWJCQn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 12:43:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some stats reported by ethtool -S on mv643xx_eth device are cleared
between each call.

Is it the wanted behaviour ? If not, the attached patch fixes it.


Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

--- linux-2.6.18/drivers/net/mv643xx_eth.c.orig	2006-10-03 18:29:14.000000000 +0200
+++ linux-2.6.18/drivers/net/mv643xx_eth.c	2006-10-03 18:29:42.000000000 +0200
@@ -2156,7 +2156,7 @@
 	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
 			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
 
 	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
 	p->good_octets_sent +=
@@ -2165,7 +2165,7 @@
 	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
 			offset <= ETH_MIB_LATE_COLLISION;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
 }
 
 /*


-- 
Maxime
