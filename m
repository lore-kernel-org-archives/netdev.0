From: Jiri Kosina <jikos@jikos.cz>
Subject: [PATCH] sk98lin: handle pci_enable_device() return value in
 skge_resume() properly
Date: Fri, 13 Oct 2006 00:17:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610130002320.29022@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751207AbWJLWTs@vger.kernel.org>
To: mlindner@syskonnect.de, rroesler@syskonnect.de,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] sk98lin: handle pci_enable_device() return value in skge_resume() properly

Fix missing handling of pci_enable_device() return value in skge_resume() 

Signed-off-by: Jiri Kosina <jikos@jikos.cz>

--- 

 drivers/net/sk98lin/skge.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index 99e9262..e12fb62 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -5070,7 +5070,11 @@ static int skge_resume(struct pci_dev *p
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	if ((ret = pci_enable_device(pdev))) {
+		printk(KERN_ERR "sk98lin: Cannot enable PCI device during resume\n");
+		unregister_netdev(dev);
+		return ret;
+	}
 	pci_set_master(pdev);
 	if (pAC->GIni.GIMacsFound == 2)
 		ret = request_irq(dev->irq, SkGeIsr, IRQF_SHARED, "sk98lin", dev);

-- 
Jiri Kosina
