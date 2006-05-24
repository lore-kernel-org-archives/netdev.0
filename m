From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 5/5] s390: lcs driver bug fixes and improvements [2/2]
Date: Wed, 24 May 2006 09:51:21 +0200
Message-ID: <20060524095121.5c087748@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:61741 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S932650AbWEXHu5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 03:50:57 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k4O7ou9k091480
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 07:50:56 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4O7qZkc123336
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:52:35 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4O7ou8S029254
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:50:56 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



From: Klaus Wacker <kdwacker@de.ibm.com>
	
	This is the second lcs driver patch containing the rest of lcs fixes.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/lcs.h |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

6956e921ffef4871ce2d422cbcbdad863f7ab0b3
diff --git a/drivers/s390/net/lcs.h b/drivers/s390/net/lcs.h
index 2fad5e4..9314393 100644
--- a/drivers/s390/net/lcs.h
+++ b/drivers/s390/net/lcs.h
@@ -73,13 +73,17 @@ do {                                    
 /**
  * LCS sense byte definitions
  */
+#define LCS_SENSE_BYTE_0 		0
+#define LCS_SENSE_BYTE_1 		1
+#define LCS_SENSE_BYTE_2 		2
+#define LCS_SENSE_BYTE_3 		3
 #define LCS_SENSE_INTERFACE_DISCONNECT	0x01
 #define LCS_SENSE_EQUIPMENT_CHECK	0x10
 #define LCS_SENSE_BUS_OUT_CHECK		0x20
 #define LCS_SENSE_INTERVENTION_REQUIRED 0x40
 #define LCS_SENSE_CMD_REJECT		0x80
-#define LCS_SENSE_RESETTING_EVENT	0x0080
-#define LCS_SENSE_DEVICE_ONLINE		0x0020
+#define LCS_SENSE_RESETTING_EVENT	0x80
+#define LCS_SENSE_DEVICE_ONLINE		0x20
 
 /**
  * LCS packet type definitions
@@ -152,10 +156,9 @@ enum lcs_dev_states {
 
 enum lcs_threads {
 	LCS_SET_MC_THREAD 	= 1,
-	LCS_STARTLAN_THREAD	= 2,
-	LCS_STOPLAN_THREAD	= 4,
-	LCS_STARTUP_THREAD	= 8,
+	LCS_RECOVERY_THREAD 	= 2,
 };
+
 /**
  * LCS struct declarations
  */
@@ -286,6 +289,7 @@ struct lcs_card {
 	struct net_device_stats stats;
 	unsigned short (*lan_type_trans)(struct sk_buff *skb,
 					 struct net_device *dev);
+	struct ccwgroup_device *gdev;
 	struct lcs_channel read;
 	struct lcs_channel write;
 	struct lcs_buffer *tx_buffer;
-- 
1.2.4

