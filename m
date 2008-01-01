From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 21/26] atl1: update atl1_close
Date: Mon, 31 Dec 2007 20:22:48 -0600
Message-ID: <1199154173-4058-22-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:64425 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752596AbYAAC2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:17 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update atl1_close() to conform with current vendor driver version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 7d84a51..997c83c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2558,6 +2558,18 @@ err_open:
 	return err;
 }
 
+static void atl1_free_irq(struct atl1_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	free_irq(adapter->pdev->irq, netdev);
+
+#ifdef CONFIG_PCI_MSI
+	if (adapter->have_msi)
+		pci_disable_msi(adapter->pdev);
+#endif
+}
+
 /*
  * atl1_close - Disables a network interface
  * @netdev: network interface device structure
@@ -2572,7 +2584,9 @@ err_open:
 static int atl1_close(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
+
 	atl1_down(adapter);
+	atl1_free_irq(adapter);
 	atl1_free_ring_resources(adapter);
 	return 0;
 }
-- 
1.5.3.3

