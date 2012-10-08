From: Kevin Baradon <kevin.baradon@gmail.com>
Subject: [PATCH] net/ethernet/jme: disable ASPM
Date: Mon,  8 Oct 2012 21:02:36 +0200
Message-ID: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
Cc: Kevin Baradon <kevin.baradon@gmail.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	Matthew Garrett <mjg@redhat.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ven69-h01-31-33-9-98.dsl.sta.abo.bbox.fr ([31.33.9.98]:50692
	"EHLO laptop-kevin.kbaradon.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750754Ab2JHTVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on patch from Matthew Garrett <mjg@redhat.com> (https://lkml.org/lkml/2011/11/11/168).

http://driveragent.com/archive/30421/7-0-14 indicates that ASPM is
disabled on the 250 and 260. Duplicate for sanity.

Fixes random RX engine hangs I experienced with JMC250 on Clevo W270HU.

Signed-off-by: Kevin Baradon <kevin.baradon@gmail.com>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: Matthew Garrett <mjg@redhat.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/jme.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index c911d88..373df5a 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -27,6 +27,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -2973,6 +2974,9 @@ jme_init_one(struct pci_dev *pdev,
 	/*
 	 * set up PCI device basics
 	 */
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
+		PCIE_LINK_STATE_CLKPM);
+
 	rc = pci_enable_device(pdev);
 	if (rc) {
 		pr_err("Cannot enable PCI device\n");
-- 
1.7.10.4
