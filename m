From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/5] qed: RoCE doesn't need to use SRC
Date: Mon, 3 Apr 2017 12:21:12 +0300
Message-ID: <1491211273-10910-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51524 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752525AbdDCJV4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:21:56 -0400
In-Reply-To: <1491211273-10910-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RoCE doesn't need to use the SRC, allocating ILT memory
on behalf of RoCE is wasting available ILT lines.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_cxt.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index f7b1a37..8db0234 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -241,8 +241,7 @@ struct qed_cxt_mngr {
 static bool src_proto(enum protocol_type type)
 {
 	return type == PROTOCOLID_ISCSI ||
-	       type == PROTOCOLID_FCOE ||
-	       type == PROTOCOLID_ROCE;
+	       type == PROTOCOLID_FCOE;
 }
 
 static bool tm_cid_proto(enum protocol_type type)
-- 
1.9.3
