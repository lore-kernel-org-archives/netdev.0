From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] hostap_{pci,plx}.c: fix memory leaks
Date: Mon, 13 Mar 2006 23:28:41 +0100
Message-ID: <20060313222841.GQ13973@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964809AbWCMW2n@vger.kernel.org>
To: jkmaline@cc.hut.fi
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes two memotry leaks spotted by the Coverity checker.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/wireless/hostap/hostap_pci.c |    6 +++---
 drivers/net/wireless/hostap/hostap_plx.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

--- linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_pci.c.old	2006-03-13 22:34:30.000000000 +0100
+++ linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_pci.c	2006-03-13 22:37:57.000000000 +0100
@@ -301,14 +301,14 @@ static int prism2_pci_probe(struct pci_d
 	struct hostap_interface *iface;
 	struct hostap_pci_priv *hw_priv;
 
+	if (pci_enable_device(pdev))
+		return -EIO;
+
 	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
 	memset(hw_priv, 0, sizeof(*hw_priv));
 
-	if (pci_enable_device(pdev))
-		return -EIO;
-
 	phymem = pci_resource_start(pdev, 0);
 
 	if (!request_mem_region(phymem, pci_resource_len(pdev, 0), "Prism2")) {
--- linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_plx.c.old	2006-03-13 22:39:40.000000000 +0100
+++ linux-2.6.16-rc6-mm1-full/drivers/net/wireless/hostap/hostap_plx.c	2006-03-13 22:40:09.000000000 +0100
@@ -446,14 +446,14 @@ static int prism2_plx_probe(struct pci_d
 	int tmd7160;
 	struct hostap_plx_priv *hw_priv;
 
+	if (pci_enable_device(pdev))
+		return -EIO;
+
 	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
 	memset(hw_priv, 0, sizeof(*hw_priv));
 
-	if (pci_enable_device(pdev))
-		return -EIO;
-
 	/* National Datacomm NCP130 based on TMD7160, not PLX9052. */
 	tmd7160 = (pdev->vendor == 0x15e8) && (pdev->device == 0x0131);
 
