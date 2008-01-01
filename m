From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 22/26] atl1: update netpoll
Date: Mon, 31 Dec 2007 20:22:49 -0600
Message-ID: <1199154173-4058-23-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:64425 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbYAAC2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:18 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename atl1_poll_controller() to atl1_netpoll() and update to conform with
the current vendor driver version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 997c83c..f09928d 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2691,11 +2691,14 @@ static int atl1_resume(struct pci_dev *pdev)
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void atl1_poll_controller(struct net_device *netdev)
+static void atl1_netpoll(struct net_device *netdev)
 {
-	disable_irq(netdev->irq);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+
+	disable_irq(adapter->pdev->irq);
 	atl1_intr(netdev->irq, netdev);
-	enable_irq(netdev->irq);
+	atl1_clean_tx_irq(adapter);
+	enable_irq(adapter->pdev->irq);
 }
 #endif
 
@@ -2796,7 +2799,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->tx_timeout = &atlx_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = atl1_poll_controller;
+	netdev->poll_controller = atl1_netpoll;
 #endif
 	netdev->vlan_rx_register = atlx_vlan_rx_register;
 
-- 
1.5.3.3

