From: Bjorn Helgaas <helgaas@kernel.org>
Subject: [PATCH] bnx2x: Use pci_ari_enabled() instead of local copy
Date: Fri, 06 Oct 2017 06:00:30 -0500
Message-ID: <20171006110030.10980.52268.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, everest-linux-l2@cavium.com,
        linux-kernel@vger.kernel.org
To: Ariel Elior <ariel.elior@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>

Use pci_ari_enabled() from the PCI core instead of the identical local copy
bnx2x_ari_enabled().  No functional change intended.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 9ca994d0bab6..3591077a5f6b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1074,11 +1074,6 @@ static void bnx2x_vf_set_bars(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	}
 }
 
-static int bnx2x_ari_enabled(struct pci_dev *dev)
-{
-	return dev->bus->self && dev->bus->self->ari_enabled;
-}
-
 static int
 bnx2x_get_vf_igu_cam_info(struct bnx2x *bp)
 {
@@ -1212,7 +1207,7 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 
 	err = -EIO;
 	/* verify ari is enabled */
-	if (!bnx2x_ari_enabled(bp->pdev)) {
+	if (!pci_ari_enabled(bp->pdev->bus)) {
 		BNX2X_ERR("ARI not supported (check pci bridge ARI forwarding), SRIOV can not be enabled\n");
 		return 0;
 	}
