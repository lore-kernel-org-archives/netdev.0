From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] xilinx_emaclite: netpoll support
Date: Wed, 18 Aug 2010 13:22:49 +0200
Message-ID: <1282130569-11314-1-git-send-email-monstr@monstr.eu>
Cc: netdev@vger.kernel.org, Michal Simek <monstr@monstr.eu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36491 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab0HRLWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 07:22:53 -0400
Received: by bwz11 with SMTP id 11so94235bwz.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 04:22:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netconsole requires poll support.

Signed-off-by: Michal Simek <monstr@monstr.eu>
---
 drivers/net/xilinx_emaclite.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index ecbbb68..71122ee 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -1269,6 +1269,16 @@ static int __devexit xemaclite_of_remove(struct platform_device *of_dev)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void
+xemaclite_poll_controller(struct net_device *ndev)
+{
+	disable_irq(ndev->irq);
+	xemaclite_interrupt(ndev->irq, ndev);
+	enable_irq(ndev->irq);
+}
+#endif
+
 static struct net_device_ops xemaclite_netdev_ops = {
 	.ndo_open		= xemaclite_open,
 	.ndo_stop		= xemaclite_close,
@@ -1276,6 +1286,9 @@ static struct net_device_ops xemaclite_netdev_ops = {
 	.ndo_set_mac_address	= xemaclite_set_mac_address,
 	.ndo_tx_timeout		= xemaclite_tx_timeout,
 	.ndo_get_stats		= xemaclite_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = xemaclite_poll_controller,
+#endif
 };
 
 /* Match table for OF platform binding */
-- 
1.5.5.6

