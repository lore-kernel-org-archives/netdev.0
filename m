From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Limit 1G link enforcement
Date: Wed, 3 Dec 2014 14:15:20 +0200
Message-ID: <1417608920-30867-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yaniv Rosner <Yaniv.Rosner@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40394 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752572AbaLCMPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 07:15:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>

Change 1G-SFP module detection by verifying not only that it's not
compliant with 10G-Ethernet, but also that it's 1G-ethernet compliant.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 549549e..778e4cd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -8119,10 +8119,11 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	case SFP_EEPROM_CON_TYPE_VAL_LC:
 	case SFP_EEPROM_CON_TYPE_VAL_RJ45:
 		check_limiting_mode = 1;
-		if ((val[SFP_EEPROM_10G_COMP_CODE_ADDR] &
+		if (((val[SFP_EEPROM_10G_COMP_CODE_ADDR] &
 		     (SFP_EEPROM_10G_COMP_CODE_SR_MASK |
 		      SFP_EEPROM_10G_COMP_CODE_LR_MASK |
-		      SFP_EEPROM_10G_COMP_CODE_LRM_MASK)) == 0) {
+		       SFP_EEPROM_10G_COMP_CODE_LRM_MASK)) == 0) &&
+		    (val[SFP_EEPROM_1G_COMP_CODE_ADDR] != 0)) {
 			DP(NETIF_MSG_LINK, "1G SFP module detected\n");
 			phy->media_type = ETH_PHY_SFP_1G_FIBER;
 			if (phy->req_line_speed != SPEED_1000) {
-- 
1.9.3
