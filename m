From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] net: Use kmemdup instead of kmalloc and memcpy
Date: Sat, 24 Dec 2016 00:44:58 +0530
Message-ID: <1482520498-28259-1-git-send-email-mayhs11saini@gmail.com>
Cc: jasowang@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34909 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752031AbcLWTPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 14:15:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id i5so1354530pgh.2
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 11:15:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when some other buffer is immediately copied into allocated region.
Replace calls to kmalloc followed by a memcpy with a direct
call to kmemdup.

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/virtio_net.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ba1aa24..dde4bc4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1206,10 +1206,9 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr;
 	struct scatterlist sg;
 
-	addr = kmalloc(sizeof(*addr), GFP_KERNEL);
+	addr = kmemdup(p, sizeof(*addr), GFP_KERNEL);
 	if (!addr)
 		return -ENOMEM;
-	memcpy(addr, p, sizeof(*addr));
 
 	ret = eth_prepare_mac_addr_change(dev, addr);
 	if (ret)
-- 
2.7.4
