From: varkabhadram@gmail.com
Subject: [PATCH net-next v3 2/6] ethernet: amd: use devm_ioremap()
Date: Mon, 14 Jul 2014 14:09:05 +0530
Message-ID: <1405327149-6554-3-git-send-email-varkabhadram@gmail.com>
References: <1405327149-6554-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405327149-6554-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch replace ioremap() with the devm_ioremap() so that
the resource will be freed automatically with the probe failed.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index ddd09e8..433107c 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1866,7 +1866,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	spin_lock_init(&lp->lock);
 
-	lp->mmio = ioremap(reg_addr, reg_len);
+	lp->mmio = devm_ioremap(&pdev->dev, reg_addr, reg_len);
 	if (!lp->mmio) {
 		printk(KERN_ERR "amd8111e: Cannot map device registers, "
 		       "exiting\n");
@@ -1913,7 +1913,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR "amd8111e: Cannot register net device, "
 		       "exiting.\n");
-		goto err_iounmap;
+		goto err_free_dev;
 	}
 
 	pci_set_drvdata(pdev, dev);
@@ -1943,8 +1943,6 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 		printk(KERN_INFO "%s: Couldn't detect MII PHY, assuming address 0x01\n",
 		       dev->name);
     	return 0;
-err_iounmap:
-	iounmap(lp->mmio);
 
 err_free_dev:
 	free_netdev(dev);
@@ -1964,7 +1962,6 @@ static void amd8111e_remove_one(struct pci_dev *pdev)
 
 	if (dev) {
 		unregister_netdev(dev);
-		iounmap(((struct amd8111e_priv *)netdev_priv(dev))->mmio);
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-- 
1.7.9.5
