From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH -next 3/3] 8390(p): remove old compat_net_dev_ops code
Date: Wed, 15 Apr 2009 21:58:29 +0400
Message-ID: <1239818309-14899-3-git-send-email-a.beregalov@gmail.com>
References: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
 <1239818309-14899-2-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:29635 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbZDOR6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 13:58:52 -0400
Received: by ti-out-0910.google.com with SMTP id 11so6496tim.23
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 10:58:52 -0700 (PDT)
In-Reply-To: <1239818309-14899-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove compat_net_dev_ops code and use struct net_device_ops
instead of it.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/8390.c  |   10 ++--------
 drivers/net/8390p.c |   10 ++--------
 2 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/8390.c b/drivers/net/8390.c
index ec3e22e..21153de 100644
--- a/drivers/net/8390.c
+++ b/drivers/net/8390.c
@@ -74,14 +74,8 @@ EXPORT_SYMBOL(ei_netdev_ops);
 struct net_device *__alloc_ei_netdev(int size)
 {
 	struct net_device *dev = ____alloc_ei_netdev(size);
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	if (dev) {
-		dev->hard_start_xmit = ei_start_xmit;
-		dev->get_stats	= ei_get_stats;
-		dev->set_multicast_list = ei_set_multicast_list;
-		dev->tx_timeout = ei_tx_timeout;
-	}
-#endif
+	if (dev)
+		dev->netdev_ops = &ei_netdev_ops;
 	return dev;
 }
 EXPORT_SYMBOL(__alloc_ei_netdev);
diff --git a/drivers/net/8390p.c b/drivers/net/8390p.c
index da863c9..6ec11da 100644
--- a/drivers/net/8390p.c
+++ b/drivers/net/8390p.c
@@ -79,14 +79,8 @@ EXPORT_SYMBOL(eip_netdev_ops);
 struct net_device *__alloc_eip_netdev(int size)
 {
 	struct net_device *dev = ____alloc_ei_netdev(size);
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	if (dev) {
-		dev->hard_start_xmit = eip_start_xmit;
-		dev->get_stats	= eip_get_stats;
-		dev->set_multicast_list = eip_set_multicast_list;
-		dev->tx_timeout = eip_tx_timeout;
-	}
-#endif
+	if (dev)
+		dev->netdev_ops = &eip_netdev_ops;
 	return dev;
 }
 EXPORT_SYMBOL(__alloc_eip_netdev);
-- 
1.6.2.3

