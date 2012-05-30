From: Joe Perches <joe@perches.com>
Subject: [PATCH] netdevice: Update netif_dbg for CONFIG_DYNAMIC_DEBUG
Date: Wed, 30 May 2012 10:43:34 -0700
Message-ID: <1338399814.3715.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jim Cromie <jim.cromie@gmail.com>, Jason Baron <jbaron@redhat.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51796 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752306Ab2E3Rno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 13:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make netif_dbg use dynamic debugging whenever
CONFIG_DYNAMIC_DEBUG is enabled.

commit b558c96ffa53
("dynamic_debug: make dynamic-debug supersede DEBUG ccflag")
missed updating the netif_dbg variant.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7fd468..d94cb14 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2795,15 +2795,15 @@ do {								\
 #define netif_info(priv, type, dev, fmt, args...)		\
 	netif_level(info, priv, type, dev, fmt, ##args)
 
-#if defined(DEBUG)
-#define netif_dbg(priv, type, dev, format, args...)		\
-	netif_printk(priv, type, KERN_DEBUG, dev, format, ##args)
-#elif defined(CONFIG_DYNAMIC_DEBUG)
+#if defined(CONFIG_DYNAMIC_DEBUG)
 #define netif_dbg(priv, type, netdev, format, args...)		\
 do {								\
 	if (netif_msg_##type(priv))				\
 		dynamic_netdev_dbg(netdev, format, ##args);	\
 } while (0)
+#elif defined(DEBUG)
+#define netif_dbg(priv, type, dev, format, args...)		\
+	netif_printk(priv, type, KERN_DEBUG, dev, format, ##args)
 #else
 #define netif_dbg(priv, type, dev, format, args...)			\
 ({									\
