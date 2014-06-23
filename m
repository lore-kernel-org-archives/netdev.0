From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/22] enic: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:38 -0700
Message-ID: <cfd907966b8feaaa1c2ecbd537a7a0ef3fc98141.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index e86a45c..8a4799c 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -432,14 +432,12 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 	int err = 0;
 
 	if (!vdev->fw_info) {
-		vdev->fw_info = pci_alloc_consistent(vdev->pdev,
-			sizeof(struct vnic_devcmd_fw_info),
-			&vdev->fw_info_pa);
+		vdev->fw_info = pci_zalloc_consistent(vdev->pdev,
+						      sizeof(struct vnic_devcmd_fw_info),
+						      &vdev->fw_info_pa);
 		if (!vdev->fw_info)
 			return -ENOMEM;
 
-		memset(vdev->fw_info, 0, sizeof(struct vnic_devcmd_fw_info));
-
 		a0 = vdev->fw_info_pa;
 		a1 = sizeof(struct vnic_devcmd_fw_info);
 
-- 
1.8.1.2.459.gbcd45b4.dirty
