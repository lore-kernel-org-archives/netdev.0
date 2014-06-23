From: Joe Perches <joe@perches.com>
Subject: [PATCH 13/22] qlogic: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:41 -0700
Message-ID: <5aceec27b2390a68fb96d31fc5753d9b58d82627.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c |  4 +---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c        | 11 +++++------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index 6f6be57..b8d5270 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -129,14 +129,12 @@ netxen_get_minidump_template(struct netxen_adapter *adapter)
 		return NX_RCODE_INVALID_ARGS;
 	}
 
-	addr = pci_alloc_consistent(adapter->pdev, size, &md_template_addr);
-
+	addr = pci_zalloc_consistent(adapter->pdev, size, &md_template_addr);
 	if (!addr) {
 		dev_err(&adapter->pdev->dev, "Unable to allocate dmable memory for template.\n");
 		return -ENOMEM;
 	}
 
-	memset(addr, 0, size);
 	memset(&cmd, 0, sizeof(cmd));
 	memset(&cmd.rsp, 1, sizeof(struct _cdrp_cmd));
 	cmd.req.cmd = NX_CDRP_CMD_GET_TEMP_HDR;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b40050e..d836ace 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2727,23 +2727,22 @@ static void ql_free_shadow_space(struct ql_adapter *qdev)
 static int ql_alloc_shadow_space(struct ql_adapter *qdev)
 {
 	qdev->rx_ring_shadow_reg_area =
-	    pci_alloc_consistent(qdev->pdev,
-				 PAGE_SIZE, &qdev->rx_ring_shadow_reg_dma);
+		pci_zalloc_consistent(qdev->pdev, PAGE_SIZE,
+				      &qdev->rx_ring_shadow_reg_dma);
 	if (qdev->rx_ring_shadow_reg_area == NULL) {
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Allocation of RX shadow space failed.\n");
 		return -ENOMEM;
 	}
-	memset(qdev->rx_ring_shadow_reg_area, 0, PAGE_SIZE);
+
 	qdev->tx_ring_shadow_reg_area =
-	    pci_alloc_consistent(qdev->pdev, PAGE_SIZE,
-				 &qdev->tx_ring_shadow_reg_dma);
+		pci_zalloc_consistent(qdev->pdev, PAGE_SIZE,
+				      &qdev->tx_ring_shadow_reg_dma);
 	if (qdev->tx_ring_shadow_reg_area == NULL) {
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Allocation of TX shadow space failed.\n");
 		goto err_wqp_sh_area;
 	}
-	memset(qdev->tx_ring_shadow_reg_area, 0, PAGE_SIZE);
 	return 0;
 
 err_wqp_sh_area:
-- 
1.8.1.2.459.gbcd45b4.dirty
