From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 4/4] bnxt_en: Ignore 0 value in autoneg supported speed from firmware.
Date: Wed,  8 Mar 2017 18:44:35 -0500
Message-ID: <1489016675-16097-5-git-send-email-michael.chan@broadcom.com>
References: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:33965 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753926AbdCHXqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:46:03 -0500
Received: by mail-wr0-f176.google.com with SMTP id l37so34120027wrc.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 15:44:55 -0800 (PST)
In-Reply-To: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some situations, the firmware will return 0 for autoneg supported
speed.  This may happen if the firmware detects no SFP module, for
example.  The driver should ignore this so that we don't end up with
an invalid autoneg setting with nothing advertised.  When SFP module
is inserted, we'll get the updated settings from firmware at that time.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 869d4c9..32de458 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5511,8 +5511,9 @@ static int bnxt_hwrm_phy_qcaps(struct bnxt *bp)
 		bp->lpi_tmr_hi = le32_to_cpu(resp->valid_tx_lpi_timer_high) &
 				 PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_HIGH_MASK;
 	}
-	link_info->support_auto_speeds =
-		le16_to_cpu(resp->supported_speeds_auto_mode);
+	if (resp->supported_speeds_auto_mode)
+		link_info->support_auto_speeds =
+			le16_to_cpu(resp->supported_speeds_auto_mode);
 
 hwrm_phy_qcaps_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
-- 
1.8.3.1
