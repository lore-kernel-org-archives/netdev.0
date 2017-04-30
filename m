From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/6] qed: add error handling flow to TID deregistratin posting failure
Date: Sun, 30 Apr 2017 11:49:07 +0300
Message-ID: <1493542150-21826-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0049.outbound.protection.outlook.com ([104.47.36.49]:25302
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1167164AbdD3Itk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:40 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

If the posting of the ramrod for the purpose of TID deregistration
fails, abort the deregistration operation without using the FW's
return code.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 01244d7..0c449dd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2457,6 +2457,8 @@ static int qed_rdma_modify_qp(void *rdma_cxt,
 	}
 
 	rc = qed_spq_post(p_hwfn, p_ent, &fw_return_code);
+	if (rc)
+		return rc;
 
 	if (fw_return_code != RDMA_RETURN_OK) {
 		DP_NOTICE(p_hwfn, "fw_return_code = %d\n", fw_return_code);
-- 
1.9.3
