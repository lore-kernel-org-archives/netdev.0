From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] skge: crash on shutdown/suspend
Date: Fri, 11 May 2007 11:21:45 -0700
Message-ID: <20070511182251.370243367@linux-foundation.org>
References: <20070511182143.872814956@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:39284 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760613AbXEKSZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:25:39 -0400
Content-Disposition: inline; filename=skge-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If device is not fails during module startup (like unsupported chip
version) then driver would crash dereferencing a null pointer, on shutdown
or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- sky2-2.6.21.orig/drivers/net/skge.c	2007-05-10 10:44:29.000000000 -0700
+++ sky2-2.6.21/drivers/net/skge.c	2007-05-10 10:45:57.000000000 -0700
@@ -3802,6 +3802,9 @@ static int skge_suspend(struct pci_dev *
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
@@ -3830,6 +3833,9 @@ static int skge_resume(struct pci_dev *p
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3868,6 +3874,9 @@ static void skge_shutdown(struct pci_dev
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct skge_port *skge = netdev_priv(dev);

--
Stephen Hemminger <shemminger@linux-foundation.org>

