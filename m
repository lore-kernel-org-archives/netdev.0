From: Kevin Hao <kexin.hao@windriver.com>
Subject: [PATCH] net: add net poll support for atl2 driver
Date: Sat, 20 Sep 2008 15:56:44 +0800
Message-ID: <1221897404-20290-1-git-send-email-kexin.hao@windriver.com>
To: Jeff Garzik <jgarzik@redhat.com>, Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40488 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbYITH5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2008 03:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netconsole support for Atheros L2 10/100 network device.

Signed-off-by: Kevin Hao <kexin.hao@windriver.com>
---
 drivers/net/atlx/atl2.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index d548a67..b2995ac 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1327,6 +1327,15 @@ static void atl2_setup_pcicmd(struct pci_dev *pdev)
 	pci_write_config_dword(pdev, REG_PM_CTRLSTAT, 0);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void atl2_poll_controller(struct net_device *netdev)
+{
+	disable_irq(netdev->irq);
+	atl2_intr(netdev->irq, netdev);
+	enable_irq(netdev->irq);
+}
+#endif
+
 /*
  * atl2_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -1410,6 +1419,9 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 	netdev->do_ioctl = &atl2_ioctl;
 	atl2_set_ethtool_ops(netdev);
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = atl2_poll_controller;
+#endif
 #ifdef HAVE_TX_TIMEOUT
 	netdev->tx_timeout = &atl2_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-- 
1.5.6.2.220.g44701

