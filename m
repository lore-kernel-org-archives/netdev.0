From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/4] qed: add Rx flow hash/indirection support.
Date: Sun, 10 Apr 2016 12:43:00 +0300
Message-ID: <1460281382-13656-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37918 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752490AbcDJJnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 05:43:12 -0400
In-Reply-To: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Adds the required API for passing RSS-related configuration from qede.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 17 +----------------
 include/linux/qed/qed_eth_if.h           |  1 +
 include/linux/qed/qed_if.h               | 11 +++++++++++
 3 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index e848d5a..5005497 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -35,19 +35,6 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 
-enum qed_rss_caps {
-	QED_RSS_IPV4		= 0x1,
-	QED_RSS_IPV6		= 0x2,
-	QED_RSS_IPV4_TCP	= 0x4,
-	QED_RSS_IPV6_TCP	= 0x8,
-	QED_RSS_IPV4_UDP	= 0x10,
-	QED_RSS_IPV6_UDP	= 0x20,
-};
-
-/* Should be the same as ETH_RSS_IND_TABLE_ENTRIES_NUM */
-#define QED_RSS_IND_TABLE_SIZE 128
-#define QED_RSS_KEY_SIZE 10 /* size in 32b chunks */
-
 struct qed_rss_params {
 	u8	update_rss_config;
 	u8	rss_enable;
@@ -1744,9 +1731,7 @@ static int qed_update_vport(struct qed_dev *cdev,
 		sp_rss_params.update_rss_capabilities = 1;
 		sp_rss_params.update_rss_ind_table = 1;
 		sp_rss_params.update_rss_key = 1;
-		sp_rss_params.rss_caps = QED_RSS_IPV4 |
-					 QED_RSS_IPV6 |
-					 QED_RSS_IPV4_TCP | QED_RSS_IPV6_TCP;
+		sp_rss_params.rss_caps = params->rss_params.rss_caps;
 		sp_rss_params.rss_table_size_log = 7; /* 2^7 = 128 */
 		memcpy(sp_rss_params.rss_ind_table,
 		       params->rss_params.rss_ind_table,
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index e00c8db..795c990 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -27,6 +27,7 @@ struct qed_dev_eth_info {
 struct qed_update_vport_rss_params {
 	u16	rss_ind_table[128];
 	u32	rss_key[10];
+	u8	rss_caps;
 };
 
 struct qed_update_vport_params {
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index b007011..67e8c20 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -515,4 +515,15 @@ static inline void internal_ram_wr(void __iomem *addr,
 	__internal_ram_wr(NULL, addr, size, data);
 }
 
+enum qed_rss_caps {
+	QED_RSS_IPV4		= 0x1,
+	QED_RSS_IPV6		= 0x2,
+	QED_RSS_IPV4_TCP	= 0x4,
+	QED_RSS_IPV6_TCP	= 0x8,
+	QED_RSS_IPV4_UDP	= 0x10,
+	QED_RSS_IPV6_UDP	= 0x20,
+};
+
+#define QED_RSS_IND_TABLE_SIZE 128
+#define QED_RSS_KEY_SIZE 10 /* size in 32b chunks */
 #endif
-- 
1.9.3
