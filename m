From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 01/12] bnx2x: allow FCoE and DCB for 578xx
Date: Sun, 13 Nov 2011 14:47:18 +0200
Message-ID: <1321188449-5822-2-git-send-email-dmitry@broadcom.com>
References: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4268 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab1KMMrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:47:47 -0500
In-Reply-To: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 51bd748..5cba9d7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -923,7 +923,7 @@ static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
 
 void bnx2x_dcbx_set_state(struct bnx2x *bp, bool dcb_on, u32 dcbx_enabled)
 {
-	if (!CHIP_IS_E1x(bp) && !CHIP_IS_E3(bp)) {
+	if (!CHIP_IS_E1x(bp)) {
 		bp->dcb_state = dcb_on;
 		bp->dcbx_enabled = dcbx_enabled;
 	} else {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6486ab8..6f3a784 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10817,8 +10817,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp);
 
 #ifdef BCM_CNIC
-	/* disable FCOE L2 queue for E1x and E3*/
-	if (CHIP_IS_E1x(bp) || CHIP_IS_E3(bp))
+	/* disable FCOE L2 queue for E1x */
+	if (CHIP_IS_E1x(bp))
 		bp->flags |= NO_FCOE_FLAG;
 
 #endif
-- 
1.7.7.2
