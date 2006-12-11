From: Brice Goglin <brice@myri.com>
Subject: [PATCH 5/7] myri10ge: Full vlan frame in small_bytes
Date: Mon, 11 Dec 2006 11:26:38 +0100
Message-ID: <457D325E.7090301@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42239 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762759AbWLKK1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:27:00 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Receive full vlan frames into smalls when running with a jumbo MTU.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:44.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:51.000000000 +0100
@@ -1650,8 +1650,8 @@
 		    ? (128 - MXGEFW_PAD)
 		    : (SMP_CACHE_BYTES - MXGEFW_PAD);
 	else
-		/* enough for an ETH_DATA_LEN frame */
-		mgp->small_bytes = ETH_FRAME_LEN;
+		/* enough for a vlan encapsulated ETH_DATA_LEN frame */
+		mgp->small_bytes = VLAN_ETH_FRAME_LEN;
 
 	/* Override the small buffer size? */
 	if (myri10ge_small_bytes > 0)


