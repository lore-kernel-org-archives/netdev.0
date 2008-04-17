From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'upstream-jeff' branch
Date: Thu, 17 Apr 2008 22:44:18 +0200
Message-ID: <20080417204418.GA26332@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Roel Kluin <12o3l@tiscali.nl>, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52594 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753748AbYDQVCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:02:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'upstream-jeff' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff

to get the changes below.

Distance from 'master' (4b119e21d0c66c22e8ca03df05d9de623d0eb50f)
-----------------------------------------------------------------

21e197f231343201368338603cb0909a13961bac
cee60c377de6d9d10f0a2876794149bd79a15020

Diffstat
--------

 drivers/net/r8169.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

Shortlog
--------

Ivan Vecera (1):
      r8169: fix oops in r8169_get_mac_version

Roel Kluin (1):
      r8169: fix past rtl_chip_info array size for unknown chipsets

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3acfeea..6572425 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1617,6 +1617,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 	tp->dev = dev;
+	tp->pci_dev = pdev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -1705,18 +1706,18 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl8169_print_mac_version(tp);
 
-	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
+	for (i = 0; i < ARRAY_SIZE(rtl_chip_info); i++) {
 		if (tp->mac_version == rtl_chip_info[i].mac_version)
 			break;
 	}
-	if (i < 0) {
+	if (i == ARRAY_SIZE(rtl_chip_info)) {
 		/* Unknown chip: assume array element #0, original RTL-8169 */
 		if (netif_msg_probe(tp)) {
 			dev_printk(KERN_DEBUG, &pdev->dev,
 				"unknown chip version, assuming %s\n",
 				rtl_chip_info[0].name);
 		}
-		i++;
+		i = 0;
 	}
 	tp->chipset = i;
 
@@ -1777,7 +1778,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 
 	tp->intr_mask = 0xffff;
-	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
 	tp->align = cfg->align;
 	tp->hw_start = cfg->hw_start;
-- 
Ueimor
