From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 2/7] qed: Prevent creation of too-big u32-chains
Date: Tue, 14 Mar 2017 15:25:59 +0200
Message-ID: <1489497964-13734-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tomer Tayar <Tomer.Tayar@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39033 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752177AbdCNN0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:21 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>

Current Logic would allow the creation of a chain with U32_MAX + 1
elements, when the actual maximum supported by the driver infrastructure
is U32_MAX.

Fixes: a91eb52abb50 ("qed: Revisit chain implementation")
Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index e2a081c..e518f91 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2389,9 +2389,8 @@ void qed_chain_free(struct qed_dev *cdev, struct qed_chain *p_chain)
 	 * size/capacity fields are of a u32 type.
 	 */
 	if ((cnt_type == QED_CHAIN_CNT_TYPE_U16 &&
-	     chain_size > 0x10000) ||
-	    (cnt_type == QED_CHAIN_CNT_TYPE_U32 &&
-	     chain_size > 0x100000000ULL)) {
+	     chain_size > ((u32)U16_MAX + 1)) ||
+	    (cnt_type == QED_CHAIN_CNT_TYPE_U32 && chain_size > U32_MAX)) {
 		DP_NOTICE(cdev,
 			  "The actual chain size (0x%llx) is larger than the maximal possible value\n",
 			  chain_size);
-- 
1.9.3
