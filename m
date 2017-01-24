From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 18/18] netvsc: call netif_receive_skb
Date: Tue, 24 Jan 2017 13:06:15 -0800
Message-ID: <20170124210615.18628-19-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33581 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750856AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f43.google.com with SMTP id 204so57911642pge.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:36 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To improve performance, netvsc can call network stack directly and
avoid the local backlog queue. This is safe since incoming packets are
handled in softirq context already because the receive function
callback is called from a tasklet.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index fe0df72532a3..72b0c1f7496e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -695,7 +695,7 @@ int netvsc_recv_callback(struct net_device *net,
 	 * is done.
 	 * TODO - use NAPI?
 	 */
-	netif_rx(skb);
+	netif_receive_skb(skb);
 	rcu_read_unlock();
 
 	return 0;
-- 
2.11.0
