From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 01/11] net,
	fcoe: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Fri, 27 Feb 2009 14:06:37 -0800
Message-ID: <20090227220637.4987.6729.stgit.yi.zou@intel.com>
References: <20090227220034.4987.50755.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47666 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754600AbZB0XOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 18:14:23 -0500
In-Reply-To: <20090227220034.4987.50755.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds eth type ETH_P_FCOE for Fibre Channel over Ethernet (FCoE),
consequently, the ETH_P_FCOE from fc_fcoe.h and fcoe skb->protocol
is not set as ETH_P_FCOE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 drivers/scsi/fcoe/libfcoe.c |    2 +-
 include/linux/if_ether.h    |    1 +
 include/scsi/fc/fc_fcoe.h   |    7 -------
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/scsi/fcoe/libfcoe.c b/drivers/scsi/fcoe/libfcoe.c
index 5548bf3..a99a428 100644
--- a/drivers/scsi/fcoe/libfcoe.c
+++ b/drivers/scsi/fcoe/libfcoe.c
@@ -460,7 +460,7 @@ int fcoe_xmit(struct fc_lport *lp, struct fc_frame *fp)
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb->mac_len = elen;
-	skb->protocol = htons(ETH_P_802_3);
+	skb->protocol = htons(ETH_P_FCOE);
 	skb->dev = fc->real_dev;
 
 	/* fill up mac and fcoe headers */
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 7f3c735..59d197c 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -78,6 +78,7 @@
 #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
 #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
+#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 
 /*
diff --git a/include/scsi/fc/fc_fcoe.h b/include/scsi/fc/fc_fcoe.h
index f271d9c..ccb3dbe 100644
--- a/include/scsi/fc/fc_fcoe.h
+++ b/include/scsi/fc/fc_fcoe.h
@@ -25,13 +25,6 @@
  */
 
 /*
- * The FCoE ethertype eventually goes in net/if_ether.h.
- */
-#ifndef ETH_P_FCOE
-#define	ETH_P_FCOE	0x8906		/* FCOE ether type */
-#endif
-
-/*
  * FC_FCOE_OUI hasn't been standardized yet.   XXX TBD.
  */
 #ifndef FC_FCOE_OUI

