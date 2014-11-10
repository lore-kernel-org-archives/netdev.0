From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/4] bnx2x: remove pci_assigned_vfs() check while disabling VFs
Date: Mon, 10 Nov 2014 17:23:28 +0530
Message-ID: <1415620410-4937-3-git-send-email-sathya.perla@emulex.com>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, <linux.nics@intel.com>,
	<shahed.shaikh@qlogic.com>, <ddutile@redhat.com>
To: <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The pci_assigned_vfs() check (while disabling VFs) is being moved to the
pci-sysfs.c file and will be done before invoking sriov_configure().

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index c88b20a..e90a10b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2481,7 +2481,7 @@ int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs_param)
 	bp->requested_nr_virtfn = num_vfs_param;
 	if (num_vfs_param == 0) {
 		bnx2x_set_pf_tx_switching(bp, false);
-		bnx2x_disable_sriov(bp);
+		pci_disable_sriov(bp->pdev);
 		return 0;
 	} else {
 		return bnx2x_enable_sriov(bp);
-- 
1.7.1
