From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 6/7] qed: Correct out-of-bound access in OOO history
Date: Tue, 14 Mar 2017 15:26:03 +0200
Message-ID: <1489497964-13734-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39043 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752190AbdCNN0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:24 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to set the number of entries in database, otherwise the logic
would quickly surpass the array.

Fixes: 1d6cff4fca43 ("qed: Add iSCSI out of order packet handling")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ooo.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ooo.c b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
index 7d731c6..378afce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ooo.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
@@ -159,6 +159,8 @@ struct qed_ooo_info *qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 	if (!p_ooo_info->ooo_history.p_cqes)
 		goto no_history_mem;
 
+	p_ooo_info->ooo_history.num_of_cqes = QED_MAX_NUM_OOO_HISTORY_ENTRIES;
+
 	return p_ooo_info;
 
 no_history_mem:
-- 
1.9.3
