From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/6] netvsc: use hv_get_bytes_to_read
Date: Thu,  8 Jun 2017 16:21:19 -0700
Message-ID: <20170608232123.28366-3-sthemmin@microsoft.com>
References: <20170608232123.28366-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36239 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbdFHXVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:21:39 -0400
Received: by mail-pg0-f47.google.com with SMTP id a70so20575640pge.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 16:21:38 -0700 (PDT)
In-Reply-To: <20170608232123.28366-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't need need to look at write space in netvsc_close.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index df6d8e28949e..436a3ad55cfd 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -120,7 +120,7 @@ static int netvsc_close(struct net_device *net)
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct netvsc_device *nvdev = rtnl_dereference(net_device_ctx->nvdev);
 	int ret;
-	u32 aread, awrite, i, msec = 10, retry = 0, retry_max = 20;
+	u32 aread, i, msec = 10, retry = 0, retry_max = 20;
 	struct vmbus_channel *chn;
 
 	netif_tx_disable(net);
@@ -141,15 +141,11 @@ static int netvsc_close(struct net_device *net)
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
