From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] netvsc: use hv_get_bytes_to_read
Date: Mon, 29 May 2017 11:31:58 -0700
Message-ID: <20170529183159.22205-2-sthemmin@microsoft.com>
References: <20170529183159.22205-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35368 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdE2ScF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 14:32:05 -0400
Received: by mail-pf0-f174.google.com with SMTP id n23so51211486pfb.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 11:32:05 -0700 (PDT)
In-Reply-To: <20170529183159.22205-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need need to look at write space in netvsc_close.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 548c78863ce9..c3e0277186bb 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -118,7 +118,7 @@ static int netvsc_close(struct net_device *net)
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct netvsc_device *nvdev = rtnl_dereference(net_device_ctx->nvdev);
 	int ret;
-	u32 aread, awrite, i, msec = 10, retry = 0, retry_max = 20;
+	u32 aread, i, msec = 10, retry = 0, retry_max = 20;
 	struct vmbus_channel *chn;
 
 	netif_tx_disable(net);
@@ -139,15 +139,11 @@ static int netvsc_close(struct net_device *net)
 			if (!chn)
 				continue;
 
-			hv_get_ringbuffer_availbytes(&chn->inbound, &aread,
-						     &awrite);
-
+			aread = hv_get_bytes_to_read(&chn->inbound);
 			if (aread)
 				break;
 
-			hv_get_ringbuffer_availbytes(&chn->outbound, &aread,
-						     &awrite);
-
+			aread = hv_get_bytes_to_read(&chn->outbound);
 			if (aread)
 				break;
 		}
-- 
2.11.0
