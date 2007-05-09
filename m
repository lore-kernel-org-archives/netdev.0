From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] atl1: add netconsole support
Date: Wed, 9 May 2007 18:52:35 +0400
Message-ID: <20070509145235.GA5712@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jacliburn@bellsouth.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:60897 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbXEIOwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 10:52:19 -0400
Received: by ug-out-1314.google.com with SMTP id 44so375719uga
        for <netdev@vger.kernel.org>; Wed, 09 May 2007 07:52:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Copied from b44 driver, but it works:

netconsole: device eth0 not up yet, forcing it
atl1: eth0 link is up 100 Mbps full duplex
netconsole: network logging started

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/atl1/atl1_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2046,6 +2046,15 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void atl1_poll_controller(struct net_device *netdev)
+{
+	disable_irq(netdev->irq);
+	atl1_intr(netdev->irq, netdev);
+	enable_irq(netdev->irq);
+}
+#endif
+
 /*
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
  * will assert. We do soft reset <0x1400=1> according
@@ -2198,6 +2207,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->do_ioctl = &atl1_ioctl;
 	netdev->tx_timeout = &atl1_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = atl1_poll_controller;
+#endif
 	netdev->vlan_rx_register = atl1_vlan_rx_register;
 	netdev->vlan_rx_add_vid = atl1_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = atl1_vlan_rx_kill_vid;

