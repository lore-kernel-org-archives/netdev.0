From: Yinglin Luan <synmyth@gmail.com>
Subject: [PATCH] netxen: fix poll implementation
Date: Mon, 23 Aug 2010 15:56:19 +0800
Message-ID: <4C7229A3.7070306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, monstr@monstr.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56574 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab0HWH40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 03:56:26 -0400
Received: by pxi10 with SMTP id 10so2172710pxi.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 00:56:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function netxen_intr has pointer to nx_host_sds_ring
as second parameter not pointer to netxen_adapter.

Signed-off-by: Yinglin Luan <synmyth@gmail.com>
---
 drivers/net/netxen/netxen_nic_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index fd86e18..4147be5 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2133,9 +2133,16 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev)
 {
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
 	struct netxen_adapter *adapter = netdev_priv(netdev);
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
 	disable_irq(adapter->irq);
-	netxen_intr(adapter->irq, adapter);
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		netxen_intr(adapter->irq, sds_ring);
+	}
 	enable_irq(adapter->irq);
 }
 #endif
-- 
1.7.0.4
