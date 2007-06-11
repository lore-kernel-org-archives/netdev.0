From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: report when the link partner is running in
 Myrinet mode
Date: Mon, 11 Jun 2007 20:26:50 +0200
Message-ID: <466D93EA.2010002@myri.com>
References: <466D9380.7090605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2031 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752308AbXFKS0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:26:23 -0400
In-Reply-To: <466D9380.7090605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since Myri-10G boards may also run in Myrinet mode instead of Ethernet,
add a message when we detect that the link partner is not running in the
right mode.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-06-05 08:25:05.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-06-11 20:04:57.000000000 +0200
@@ -1156,9 +1156,11 @@
 	struct mcp_irq_data *stats = mgp->fw_stats;
 
 	if (unlikely(stats->stats_updated)) {
-		if (mgp->link_state != stats->link_up) {
-			mgp->link_state = stats->link_up;
-			if (mgp->link_state) {
+		unsigned link_up = ntohl(stats->link_up);
+		if (mgp->link_state != link_up) {
+			mgp->link_state = link_up;
+
+			if (mgp->link_state == MXGEFW_LINK_UP) {
 				if (netif_msg_link(mgp))
 					printk(KERN_INFO
 					       "myri10ge: %s: link up\n",
@@ -1168,8 +1170,11 @@
 			} else {
 				if (netif_msg_link(mgp))
 					printk(KERN_INFO
-					       "myri10ge: %s: link down\n",
-					       mgp->dev->name);
+					       "myri10ge: %s: link %s\n",
+					       mgp->dev->name,
+					       (link_up == MXGEFW_LINK_MYRINET ?
+						"mismatch (Myrinet detected)" :
+						"down"));
 				netif_carrier_off(mgp->dev);
 				mgp->link_changes++;
 			}


