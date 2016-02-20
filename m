From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Failure to update PHY is not fatal condition.
Date: Fri, 19 Feb 2016 19:43:21 -0500
Message-ID: <1455929001-12039-4-git-send-email-michael.chan@broadcom.com>
References: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:4147 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1428905AbcBTAnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:43:24 -0500
In-Reply-To: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

If we fail to update the PHY, we should print a warning and continue.
The current code to exit is buggy as it has not freed up the NIC
resources yet.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 78f6b5a..8ab000d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4642,7 +4642,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	if (link_re_init) {
 		rc = bnxt_update_phy_setting(bp);
 		if (rc)
-			goto open_err;
+			netdev_warn(bp->dev, "failed to update phy settings\n");
 	}
 
 	if (irq_re_init) {
-- 
1.8.3.1
