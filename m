From: Yinglin Luan <synmyth@gmail.com>
Subject: [PATCH] qlcnic: fix poll implementation
Date: Mon, 23 Aug 2010 15:57:56 +0800
Message-ID: <4C722A04.2080100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, monstr@monstr.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:33197 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab0HWH6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 03:58:05 -0400
Received: by pxi10 with SMTP id 10so2173050pxi.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 00:58:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function qlcnic_intr has pointer to qlcnic_host_sds_ring
as second parameter not pointer to qlcnic_adapter.

Signed-off-by: Yinglin Luan <synmyth@gmail.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index bf6d87a..a934dbc 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2190,9 +2190,16 @@ static int qlcnic_rx_poll(struct napi_struct *napi, int budget)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+
 	disable_irq(adapter->irq);
-	qlcnic_intr(adapter->irq, adapter);
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		qlcnic_intr(adapter->irq, sds_ring);
+	}
 	enable_irq(adapter->irq);
 }
 #endif
-- 
1.7.0.4
