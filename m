From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 3/8] qlcnic: enable RSS for TCP over IPv6
Date: Fri, 25 Jan 2013 15:20:36 -0500
Message-ID: <1359145241-5175-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47084 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751372Ab3AYUlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:24 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o This patch enables RSS for TYPE-C packets to enable RSS for TCP over IPv6

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 8e0412b..eb1f3cc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -756,7 +756,10 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 }
 
 
-#define RSS_HASHTYPE_IP_TCP	0x3
+#define QLCNIC_RSS_HASHTYPE_IP_TCP	0x3
+#define QLCNIC_ENABLE_TYPE_C_RSS	BIT_10
+#define QLCNIC_RSS_FEATURE_FLAG	(1ULL << 63)
+#define QLCNIC_RSS_IND_TABLE_MASK	0x7ULL
 
 int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 {
@@ -783,13 +786,19 @@ int qlcnic_82xx_config_rss(struct qlcnic_adapter *adapter, int enable)
 	 *	7-6: hash_type_ipv6
 	 *	  8: enable
 	 *        9: use indirection table
-	 *    47-10: reserved
-	 *    63-48: indirection table mask
+	 *       10: type-c rss
+	 *	 11: udp rss
+	 *    47-12: reserved
+	 *    62-48: indirection table mask
+	 *	 63: feature flag
 	 */
-	word =  ((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
-		((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
+	word =  ((u64)(QLCNIC_RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
+		((u64)(QLCNIC_RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
 		((u64)(enable & 0x1) << 8) |
-		((0x7ULL) << 48);
+		((u64)QLCNIC_RSS_IND_TABLE_MASK << 48) |
+		(u64)QLCNIC_ENABLE_TYPE_C_RSS |
+		(u64)QLCNIC_RSS_FEATURE_FLAG;
+
 	req.words[0] = cpu_to_le64(word);
 	for (i = 0; i < 5; i++)
 		req.words[i+1] = cpu_to_le64(key[i]);
-- 
1.7.1
