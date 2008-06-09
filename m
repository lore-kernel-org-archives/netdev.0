From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] add missing lance_* exports
Date: Tue, 10 Jun 2008 01:22:16 +0300
Message-ID: <20080609222216.GD1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:47006 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758742AbYFIWXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:23:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following build error:

<--  snip  -->

...
  Building modules, stage 2.
  MODPOST 1203 modules
ERROR: "lance_open" [drivers/net/mvme147.ko] undefined!
ERROR: "lance_close" [drivers/net/mvme147.ko] undefined!
ERROR: "lance_tx_timeout" [drivers/net/mvme147.ko] undefined!
ERROR: "lance_set_multicast" [drivers/net/mvme147.ko] undefined!
ERROR: "lance_start_xmit" [drivers/net/mvme147.ko] undefined!
...
make[2]: *** [__modpost] Error 1

<--  snip  -->

Reported-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/7990.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

506cb8d679dd0aedae861635aca435e5cd09bcc2 diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 750a46f..ad6b8a5 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -506,6 +506,7 @@ int lance_open (struct net_device *dev)
 
 	return res;
 }
+EXPORT_SYMBOL_GPL(lance_open);
 
 int lance_close (struct net_device *dev)
 {
@@ -521,6 +522,7 @@ int lance_close (struct net_device *dev)
 
         return 0;
 }
+EXPORT_SYMBOL_GPL(lance_close);
 
 void lance_tx_timeout(struct net_device *dev)
 {
@@ -529,7 +531,7 @@ void lance_tx_timeout(struct net_device *dev)
 	dev->trans_start = jiffies;
 	netif_wake_queue (dev);
 }
-
+EXPORT_SYMBOL_GPL(lance_tx_timeout);
 
 int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
@@ -586,6 +588,7 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
         return 0;
 }
+EXPORT_SYMBOL_GPL(lance_start_xmit);
 
 /* taken from the depca driver via a2065.c */
 static void lance_load_multicast (struct net_device *dev)
@@ -654,6 +657,7 @@ void lance_set_multicast (struct net_device *dev)
 	if (!stopped)
 		netif_start_queue (dev);
 }
+EXPORT_SYMBOL_GPL(lance_set_multicast);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void lance_poll(struct net_device *dev)

