From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 7/7] bnx2x: Disable FCoE for 57840 since not yet
 supported by FW
Date: Wed, 31 Oct 2012 17:46:58 +0200
Message-ID: <1351698418-10005-8-git-send-email-dmitry@broadcom.com>
References: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: ariele@broadcom.com, eilong@broadcom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3321 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618Ab2JaPrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:23 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d5648fc..f23e8c0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11902,7 +11902,15 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* disable FCOE L2 queue for E1x */
 	if (CHIP_IS_E1x(bp))
 		bp->flags |= NO_FCOE_FLAG;
-
+	/* disable FCOE for 57840 device, until FW supports it */
+	switch (ent->driver_data) {
+	case BCM57840_O:
+	case BCM57840_4_10:
+	case BCM57840_2_20:
+	case BCM57840_MFO:
+	case BCM57840_MF:
+		bp->flags |= NO_FCOE_FLAG;
+	}
 #endif
 
 
-- 
1.7.7.2
