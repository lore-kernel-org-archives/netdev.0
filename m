From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/5] bnx2: Restrict WoL support.
Date: Wed, 12 Nov 2008 15:10:01 -0800
Message-ID: <1226531404-26118-2-git-send-email-mchan@broadcom.com>
References: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1800 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbYKLXDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 18:03:47 -0500
In-Reply-To: <1226531404-26118-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some quad-port cards that cannot support WoL on all ports due
to excessive power consumption, the driver needs to restrict WoL
on some ports by checking VAUX_PRESET bit.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 49ebb50..d28cbce 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7586,7 +7586,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B1)) {
+	    (CHIP_ID(bp) == CHIP_ID_5708_B1) ||
+	    !(REG_RD(bp, BNX2_PCI_CONFIG_3) & BNX2_PCI_CONFIG_3_VAUX_PRESET)) {
 		bp->flags |= BNX2_FLAG_NO_WOL;
 		bp->wol = 0;
 	}
-- 
1.5.6.GIT


