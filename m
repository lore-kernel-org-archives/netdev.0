From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 10/10] qlcnic: add cksum flag
Date: Tue, 31 Aug 2010 20:17:53 -0700
Message-ID: <1283311073-7165-11-git-send-email-amit.salecha@qlogic.com>
References: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53037 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754045Ab0IADRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 23:17:55 -0400
In-Reply-To: <1283311073-7165-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o New CKSUM flag added by fw to notify cksum is verified.
o Update version to 5.0.9

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    7 ++++---
 drivers/net/qlcnic/qlcnic_init.c |    3 ++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9d21152..cc8385a 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 8
-#define QLCNIC_LINUX_VERSIONID  "5.0.8"
+#define _QLCNIC_LINUX_SUBVERSION 9
+#define QLCNIC_LINUX_VERSIONID  "5.0.9"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
@@ -224,7 +224,8 @@ struct rcv_desc {
 #define QLCNIC_LRO_DESC  	0x12
 
 /* for status field in status_desc */
-#define STATUS_CKSUM_OK		(2)
+#define STATUS_CKSUM_LOOP	0
+#define STATUS_CKSUM_OK		2
 
 /* owner bits of status_desc */
 #define STATUS_OWNER_HOST	(0x1ULL << 56)
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 8e0e7a3..8e47d7a 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1364,7 +1364,8 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 
 	skb = buffer->skb;
 
-	if (likely(adapter->rx_csum && cksum == STATUS_CKSUM_OK)) {
+	if (likely(adapter->rx_csum && (cksum == STATUS_CKSUM_OK ||
+						cksum == STATUS_CKSUM_LOOP))) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else {
-- 
1.6.0.2

