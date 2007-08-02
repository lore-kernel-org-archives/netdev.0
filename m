From: Brandon Philips <brandon@suse.de>
Subject: [patch 1/5][RFC] NET: Change pci_enable_device to
	pci_reenable_device to keep device enable balance
Date: Thu, 2 Aug 2007 15:44:23 -0700
Message-ID: <20070802224423.GC5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55815 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816AbXHBWo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 18:44:27 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 5F39A122A9
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2007 00:44:26 +0200 (CEST)
Content-Disposition: inline; filename="net-pci-reenable-on-slot-reset.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a slot_reset event pci_disable_device() is never called so calling
pci_enable_device() will unbalance the enable count.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/e100.c             |    2 +-
 drivers/net/e1000/e1000_main.c |    2 +-
 drivers/net/ixgb/ixgb_main.c   |    2 +-
 drivers/net/s2io.c             |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2828,7 +2828,7 @@ static pci_ers_result_t e100_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -5270,7 +5270,7 @@ static pci_ers_result_t e1000_io_slot_re
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
+++ linux-2.6/drivers/net/ixgb/ixgb_main.c
@@ -2294,7 +2294,7 @@ static pci_ers_result_t ixgb_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(pci_enable_device(pdev)) {
+	if(pci_reenable_device(pdev)) {
 		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/s2io.c
===================================================================
--- linux-2.6.orig/drivers/net/s2io.c
+++ linux-2.6/drivers/net/s2io.c
@@ -7833,7 +7833,7 @@ static pci_ers_result_t s2io_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct s2io_nic *sp = netdev->priv;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "s2io: "
 		       "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;

-- 
