From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH 1/2] sundance: add netconsole support
Date: Fri, 16 Aug 2013 20:32:27 +0400
Message-ID: <1376670748-2084-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36277 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab3HQAX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:23:26 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so1795969lbf.4
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 17:23:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add netconsole logging support

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 drivers/net/ethernet/dlink/sundance.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 50d9c63..2688a84 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -469,6 +469,17 @@ static void sundance_reset(struct net_device *dev, unsigned long reset_cmd)
 	}
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void sundance_poll_controller(struct net_device *dev)
+{
+	struct netdev_private *np = netdev_priv(dev);
+
+	disable_irq(np->pci_dev->irq);
+	intr_handler(np->pci_dev->irq, dev);
+	enable_irq(np->pci_dev->irq);
+}
+#endif
+
 static const struct net_device_ops netdev_ops = {
 	.ndo_open		= netdev_open,
 	.ndo_stop		= netdev_close,
@@ -480,6 +491,9 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_change_mtu		= change_mtu,
 	.ndo_set_mac_address 	= sundance_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = sundance_poll_controller,
+#endif
 };
 
 static int sundance_probe1(struct pci_dev *pdev,
-- 
1.8.0.2
