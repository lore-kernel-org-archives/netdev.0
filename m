From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 4/5] qed: Correct doorbell configuration for !4Kb pages
Date: Tue, 9 May 2017 15:07:50 +0300
Message-ID: <1494331671-16273-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0057.outbound.protection.outlook.com ([104.47.42.57]:24876
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753576AbdEIMIX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:23 -0400
In-Reply-To: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

When configuring the doorbell DPI address, driver aligns the start
address to 4KB [HW-pages] instead of host PAGE_SIZE.
As a result, RoCE applications might receive addresses which are
unaligned to pages [when PAGE_SIZE > 4KB], which is a security risk.

Fixes: 51ff17251c9c ("qed: Add support for RoCE hw init")
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index bb70522..463927f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1370,7 +1370,7 @@ enum QED_ROCE_EDPM_MODE {
 						   NULL) +
 		       qed_cxt_get_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
 						   NULL);
-	norm_regsize = roundup(QED_PF_DEMS_SIZE * non_pwm_conn, 4096);
+	norm_regsize = roundup(QED_PF_DEMS_SIZE * non_pwm_conn, PAGE_SIZE);
 	min_addr_reg1 = norm_regsize / 4096;
 	pwm_regsize = db_bar_size - norm_regsize;
 
-- 
1.9.3
