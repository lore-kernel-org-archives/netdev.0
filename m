From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH 2/2] arc_emac: add netpoll support
Date: Sun, 11 May 2014 18:11:48 +0200
Message-ID: <1399824708-2497-3-git-send-email-b.galvani@gmail.com>
References: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:34513 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245AbaEKQM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 12:12:26 -0400
In-Reply-To: <1399824708-2497-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 12fc810..6a1e589 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -363,6 +363,15 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void arc_emac_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	arc_emac_intr(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
 /**
  * arc_emac_open - Open the network device.
  * @ndev:	Pointer to the network device.
@@ -657,6 +666,9 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 	.ndo_set_mac_address	= arc_emac_set_address,
 	.ndo_get_stats		= arc_emac_stats,
 	.ndo_set_rx_mode	= arc_emac_set_rx_mode,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= arc_emac_poll_controller,
+#endif
 };
 
 static int arc_emac_probe(struct platform_device *pdev)
-- 
1.7.10.4
