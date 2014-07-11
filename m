From: varkabhadram@gmail.com
Subject: [PATCH net-next 1/8] ethernet: amd: move amd111e_remove_one after probe
Date: Fri, 11 Jul 2014 13:05:03 +0530
Message-ID: <1405064110-22579-2-git-send-email-varkabhadram@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch moves the remove functionalities after the probe 
so that we can see the registered and released resources properly.
Every driver follows the same concept.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 068dc7c..ddd09e8 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1701,18 +1701,6 @@ static int amd8111e_resume(struct pci_dev *pci_dev)
 	return 0;
 }
 
-
-static void amd8111e_remove_one(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	if (dev) {
-		unregister_netdev(dev);
-		iounmap(((struct amd8111e_priv *)netdev_priv(dev))->mmio);
-		free_netdev(dev);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-	}
-}
 static void amd8111e_config_ipg(struct net_device* dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1970,6 +1958,19 @@ err_disable_pdev:
 
 }
 
+static void amd8111e_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (dev) {
+		unregister_netdev(dev);
+		iounmap(((struct amd8111e_priv *)netdev_priv(dev))->mmio);
+		free_netdev(dev);
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
+	}
+}
+
 static struct pci_driver amd8111e_driver = {
 	.name   	= MODULE_NAME,
 	.id_table	= amd8111e_pci_tbl,
-- 
1.7.9.5
