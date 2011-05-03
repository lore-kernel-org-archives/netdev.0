From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 2/5] bnx2x: allow WoL on every function in MF modes
Date: Tue, 3 May 2011 16:27:12 +0300
Message-ID: <1304429232.19456.3.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3807 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab1ECNky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 09:40:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index bc847b1..259d1d9 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8063,13 +8063,9 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		(val >= REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL) ?
 		FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY : 0;
 
-	if (BP_E1HVN(bp) == 0) {
-		pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
-		bp->flags |= (pmc & PCI_PM_CAP_PME_D3cold) ? 0 : NO_WOL_FLAG;
-	} else {
-		/* no WOL capability for E1HVN != 0 */
-		bp->flags |= NO_WOL_FLAG;
-	}
+	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
+	bp->flags |= (pmc & PCI_PM_CAP_PME_D3cold) ? 0 : NO_WOL_FLAG;
+
 	BNX2X_DEV_INFO("%sWoL capable\n",
 		       (bp->flags & NO_WOL_FLAG) ? "not " : "");
 
-- 
1.7.2.2




