From: akpm@linux-foundation.org
Subject: [patch 08/18] 3c59x: check return of pci_enable_device()
Date: Fri, 10 Aug 2007 14:05:18 -0700
Message-ID: <200708102105.l7AL5Jje008968@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	mark@hindley.org.uk, klassert@mathematik.tu-chemnitz.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41128 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938138AbXHJVHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:07:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Hindley <mark@hindley.org.uk>

Check return of pci_enable_device in vortex_up().

Signed-off-by: Mark Hindley <mark@hindley.org.uk>
Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c59x.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/net/3c59x.c~3c59x-check-return-of-pci_enable_device drivers/net/3c59x.c
--- a/drivers/net/3c59x.c~3c59x-check-return-of-pci_enable_device
+++ a/drivers/net/3c59x.c
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
_
