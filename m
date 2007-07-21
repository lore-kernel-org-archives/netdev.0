From: Mark Hindley <mark@hindley.org.uk>
Subject: [PATCH] 3c59x, check return of pci_enable_device()
Date: Sat, 21 Jul 2007 23:13:04 +0100
Message-ID: <20070721221304.GD10630@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 83-216-141-215.markhi700.adsl.metronet.co.uk ([83.216.141.215]:4408
	"EHLO mx.hindley.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599AbXGUW1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 18:27:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 36d139ccebba6a1082b743fbedb53c5a5097987c
Author: Mark Hindley <mark@hindley.org.uk>
Date:   Sat Jul 21 22:56:08 2007 +0100

    Check return of pci_enable_device in vortex_up().
    
    Signed-off-by: Mark Hindley <mark@hindley.org.uk>

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index f26ca33..192e74b 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1490,13 +1490,17 @@ vortex_up(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 	unsigned int config;
-	int i, mii_reg1, mii_reg5;
+	int i, mii_reg1, mii_reg5, err;
 
 	if (VORTEX_PCI(vp)) {
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */
 		if (vp->pm_state_valid)
 			pci_restore_state(VORTEX_PCI(vp));
-		pci_enable_device(VORTEX_PCI(vp));
+		err = pci_enable_device(VORTEX_PCI(vp));
+		if (err) {
+			printk(KERN_WARNING "%s: Could not enable device \n",
+				dev->name);
+		}
 	}
 
 	/* Before initializing select the active media port. */
