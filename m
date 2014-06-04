From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: remove some unless free on failure in alloc_netdev_mqs()
Date: Tue,  3 Jun 2014 17:11:54 -0700
Message-ID: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:48225 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbaFDAMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 20:12:16 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so5288338pde.4
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 17:12:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we jump to free_pcpu on failure in alloc_netdev_mqs()
rx and tx queues are not yet allocated, so no need to free them.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/dev.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0355ca5..1ba2cfe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6503,11 +6503,6 @@ free_all:
 
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
-	netif_free_tx_queues(dev);
-#ifdef CONFIG_SYSFS
-	kfree(dev->_rx);
-#endif
-
 free_dev:
 	netdev_freemem(dev);
 	return NULL;
-- 
1.8.3.1
