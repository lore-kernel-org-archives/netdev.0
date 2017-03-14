From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 1/7] qed: Align CIDs according to DORQ requirement
Date: Tue, 14 Mar 2017 15:25:58 +0200
Message-ID: <1489497964-13734-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39030 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751978AbdCNN0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:14 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

The Doorbell HW block can be configured at a granularity
of 16 x CIDs, so we need to make sure that the actual number
of CIDs configured would be a multiplication of 16.

Today, when RoCE is enabled - given that the number is unaligned,
doorbelling the higher CIDs would fail to reach the firmware and
would eventually timeout.

Fixes: dbb799c39717 ("qed: Initialize hardware for new protocols")
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index d42d03d..7e3a6fe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -422,8 +422,9 @@ static void qed_cxt_set_proto_cid_count(struct qed_hwfn *p_hwfn,
 		u32 page_sz = p_mgr->clients[ILT_CLI_CDUC].p_size.val;
 		u32 cxt_size = CONN_CXT_SIZE(p_hwfn);
 		u32 elems_per_page = ILT_PAGE_IN_BYTES(page_sz) / cxt_size;
+		u32 align = elems_per_page * DQ_RANGE_ALIGN;
 
-		p_conn->cid_count = roundup(p_conn->cid_count, elems_per_page);
+		p_conn->cid_count = roundup(p_conn->cid_count, align);
 	}
 }
 
-- 
1.9.3
