From: Tomer Tayar <Tomer.Tayar@cavium.com>
Subject: [PATCH net] qed: fix dump of context data
Date: Tue, 13 Jun 2017 12:15:59 +0300
Message-ID: <1497345359-2193-1-git-send-email-Tomer.Tayar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yuval.mintz@cavium.com>, Tomer Tayar <Tomer.Tayar@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0081.outbound.protection.outlook.com ([104.47.40.81]:13291
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751884AbdFMJQH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 05:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when dumping a context data only word number '1' is read for the
entire context.

Fixes: c965db444629 ("qed: Add support for debug data collection")

Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_debug.c b/drivers/net/ethernet/qlogic/qed/qed_debug.c
index 483241b..a672f6a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_debug.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_debug.c
@@ -2956,7 +2956,7 @@ static u32 qed_grc_dump_ctx_data(struct qed_hwfn *p_hwfn,
 				qed_wr(p_hwfn,
 				       p_ptt,
 				       s_storm_defs[storm_id].cm_ctx_wr_addr,
-				       BIT(9) | lid);
+				       (i << 9) | lid);
 				*(dump_buf + offset) = qed_rd(p_hwfn,
 							      p_ptt,
 							      rd_reg_addr);
-- 
1.8.3.1
