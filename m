From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Tue, 3 Feb 2009 23:15:26 +0100
Message-ID: <200902032315.27113.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200902031029.30739.rjw@sisk.pl> <alpine.DEB.2.00.0902031622070.5481@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41561 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbZBCWPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 17:15:44 -0500
In-Reply-To: <alpine.DEB.2.00.0902031622070.5481@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 February 2009, Parag Warudkar wrote:
> 
> On Tue, 3 Feb 2009, Rafael J. Wysocki wrote:
> 
> > Did you have a chance to check if the patch from Linus (reproduced
> > below) on top of current -git fixed the problem for you too?
> > 
> Hi Rafael,
> 
> Yes, the patch below (atop today's git) does work for me.

Good.

Can you also test this one instead and tell me if it still works?

Rafael

---
 drivers/pci/pcie/portdrv_pci.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

Index: linux-2.6/drivers/pci/pcie/portdrv_pci.c
===================================================================
--- linux-2.6.orig/drivers/pci/pcie/portdrv_pci.c
+++ linux-2.6/drivers/pci/pcie/portdrv_pci.c
@@ -55,25 +55,13 @@ static int pcie_portdrv_suspend(struct p
 
 }
 
-static int pcie_portdrv_suspend_late(struct pci_dev *dev, pm_message_t state)
-{
-	return pci_save_state(dev);
-}
-
-static int pcie_portdrv_resume_early(struct pci_dev *dev)
-{
-	return pci_restore_state(dev);
-}
-
 static int pcie_portdrv_resume(struct pci_dev *dev)
 {
-	pcie_portdrv_restore_config(dev);
+	pci_set_master(dev);
 	return pcie_port_device_resume(dev);
 }
 #else
 #define pcie_portdrv_suspend NULL
-#define pcie_portdrv_suspend_late NULL
-#define pcie_portdrv_resume_early NULL
 #define pcie_portdrv_resume NULL
 #endif
 
@@ -292,8 +280,6 @@ static struct pci_driver pcie_portdriver
 	.remove		= pcie_portdrv_remove,
 
 	.suspend	= pcie_portdrv_suspend,
-	.suspend_late	= pcie_portdrv_suspend_late,
-	.resume_early	= pcie_portdrv_resume_early,
 	.resume		= pcie_portdrv_resume,
 
 	.err_handler 	= &pcie_portdrv_err_handler,

