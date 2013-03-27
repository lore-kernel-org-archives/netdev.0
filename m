From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/6] bnx2x: missing ARI should not be lethal
Date: Wed, 27 Mar 2013 13:05:14 +0200
Message-ID: <1364382319-24952-2-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2697 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963Ab3C0MK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:26 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

If ARI forwarding flag is missing from the PCI bridge, remove SR-IOV
support instead of failing the probe process.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index faadd15..ad7ad1d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1932,20 +1932,22 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 
 	/* SRIOV can be enabled only with MSIX */
 	if (int_mode_param == BNX2X_INT_MODE_MSI ||
-	    int_mode_param == BNX2X_INT_MODE_INTX)
+	    int_mode_param == BNX2X_INT_MODE_INTX) {
 		BNX2X_ERR("Forced MSI/INTx mode is incompatible with SRIOV\n");
+		return 0;
+	}
 
 	err = -EIO;
 	/* verify ari is enabled */
 	if (!bnx2x_ari_enabled(bp->pdev)) {
-		BNX2X_ERR("ARI not supported, SRIOV can not be enabled\n");
-		return err;
+		BNX2X_ERR("ARI not supported (check pci bridge ARI forwarding), SRIOV can not be enabled\n");
+		return 0;
 	}
 
 	/* verify igu is in normal mode */
 	if (CHIP_INT_MODE_IS_BC(bp)) {
 		BNX2X_ERR("IGU not normal mode,  SRIOV can not be enabled\n");
-		return err;
+		return 0;
 	}
 
 	/* allocate the vfs database */
-- 
1.8.1.227.g44fe835
