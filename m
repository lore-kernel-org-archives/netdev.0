From: gfree.wind@foxmail.com
Subject: [PATCH] net: fib: Decrease one unnecessary rt cache flush in fib_disable_ip
Date: Wed, 26 Apr 2017 19:04:04 +0800
Message-ID: <1493204644-88477-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:35384 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2998967AbdDZLES (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 07:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The func fib_flush already flushes the rt cache if necessary, so it
is not necessary to invoke rt_cache_flush again in fib_disable_ip.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/fib_frontend.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 5a0e456..39bd1ed 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1130,7 +1130,8 @@ static void fib_disable_ip(struct net_device *dev, unsigned long event,
 {
 	if (fib_sync_down_dev(dev, event, force))
 		fib_flush(dev_net(dev));
-	rt_cache_flush(dev_net(dev));
+	else
+		rt_cache_flush(dev_net(dev));
 	arp_ifdown(dev);
 }
 
-- 
1.9.1
