From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 2/6] net/trivial: replace numeric with standard PM state macros
Date: Thu, 27 Jun 2013 20:53:42 +0800
Message-ID: <1372337622-26076-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use standard PM state macros PCI_Dx instead of numeric 0/1/2..

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/8390/ne2k-pci.c             |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c      |    4 ++--
 drivers/net/ethernet/intel/e100.c                |    4 ++--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    2 +-
 drivers/net/ethernet/realtek/8139cp.c            |    2 +-
 drivers/net/ethernet/ti/tlan.c                   |    2 +-
 drivers/net/ethernet/via/via-velocity.c          |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.h       |    2 +-
 8 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 587a885..9220108 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -676,7 +676,7 @@ static int ne2k_pci_resume (struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata (pdev);
 	int rc;
 
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
 	rc = pci_enable_device(pdev);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a0b4be5..f4994ae 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4390,7 +4390,7 @@ static int be_resume(struct pci_dev *pdev)
 	if (status)
 		return status;
 
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
 	/* tell fw we're ready to fire cmds */
@@ -4486,7 +4486,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	pci_set_master(pdev);
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
 	/* Check if card is ok and fw is ready */
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d2bea3f..5115ae7 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -3069,7 +3069,7 @@ static int e100_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	/* ack any pending wake events, disable PME */
-	pci_enable_wake(pdev, 0, 0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* disable reverse auto-negotiation */
 	if (nic->phy == phy_82552_v) {
@@ -3160,7 +3160,7 @@ static void e100_io_resume(struct pci_dev *pdev)
 	struct nic *nic = netdev_priv(netdev);
 
 	/* ack any pending wake events, disable PME */
-	pci_enable_wake(pdev, 0, 0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 
 	netif_device_attach(netdev);
 	if (netif_running(netdev)) {
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 7be9788..967bae8 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3299,7 +3299,7 @@ static int myri10ge_resume(struct pci_dev *pdev)
 	if (mgp == NULL)
 		return -EINVAL;
 	netdev = mgp->dev;
-	pci_set_power_state(pdev, 0);	/* zeros conf space as a side effect */
+	pci_set_power_state(pdev, PCI_D0);	/* zeros conf space as a side effect */
 	msleep(5);		/* give card time to respond */
 	pci_read_config_word(mgp->pdev, PCI_VENDOR_ID, &vendor);
 	if (vendor == 0xffff) {
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 0352345..e6acb9f 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1817,7 +1817,7 @@ static int cp_set_eeprom(struct net_device *dev,
 /* Put the board into D3cold state and wait for WakeUp signal */
 static void cp_set_d3_state (struct cp_private *cp)
 {
-	pci_enable_wake (cp->pdev, 0, 1); /* Enable PME# generation */
+	pci_enable_wake(cp->pdev, PCI_D0, 1); /* Enable PME# generation */
 	pci_set_power_state (cp->pdev, PCI_D3hot);
 }
 
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 60c400f..c80b1d5 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -372,7 +372,7 @@ static int tlan_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_wake(pdev, 0, 0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 	netif_device_attach(dev);
 
 	if (netif_running(dev))
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index fb62489..f5d7c3f 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -3082,7 +3082,7 @@ static int velocity_resume(struct pci_dev *pdev)
 		return 0;
 
 	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_wake(pdev, 0, 0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 	pci_restore_state(pdev);
 
 	mac_wol_reset(vptr->mac_regs);
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.h b/drivers/net/wireless/orinoco/orinoco_pci.h
index ea7231a..43f5b9f 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco/orinoco_pci.h
@@ -38,7 +38,7 @@ static int orinoco_pci_resume(struct pci_dev *pdev)
 	struct net_device *dev = priv->ndev;
 	int err;
 
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	err = pci_enable_device(pdev);
 	if (err) {
 		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
-- 
1.7.1
