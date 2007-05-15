From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] skge: crash on shutdown/suspend
Date: Tue, 15 May 2007 15:08:26 -0700
Message-ID: <20070515220903.789054831@linux-foundation.org>
References: <20070515220821.676720721@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58559 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756621AbXEOWT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:19:29 -0400
Content-Disposition: inline; filename=skge-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If device fails during module startup for some reason (like unsupported chip
version) then driver would crash dereferencing a null pointer, on shutdown
or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- linux-2.6.21.y.orig/drivers/net/skge.c	2007-05-15 09:06:30.000000000 -0700
+++ linux-2.6.21.y/drivers/net/skge.c	2007-05-15 09:07:20.000000000 -0700
@@ -3794,6 +3794,9 @@ static int skge_suspend(struct pci_dev *
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
@@ -3822,6 +3825,9 @@ static int skge_resume(struct pci_dev *p
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3860,6 +3866,9 @@ static void skge_shutdown(struct pci_dev
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

