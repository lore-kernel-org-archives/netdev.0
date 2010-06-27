From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] netdevice.h: Change netif_<level> macros to call netdev_<level> functions
Date: Sun, 27 Jun 2010 04:02:36 -0700
Message-ID: <24b88d3464b3ac4d6a8e64fba03ccd9be07f59ae.1277636091.git.joe@perches.com>
References: <cover.1277636090.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1309 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754908Ab0F0LCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 07:02:41 -0400
In-Reply-To: <cover.1277636090.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduces text ~300 bytes of text (woohoo!) in an x86 defconfig

$ size vmlinux*
   text	   data	    bss	    dec	    hex	filename
7198526	 720112	1366288	9284926	 8dad3e	vmlinux
7198862	 720112	1366288	9285262	 8dae8e	vmlinux.netdev

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7f3197d..489a612 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2291,20 +2291,26 @@ do {					  			\
 		netdev_printk(level, (dev), fmt, ##args);	\
 } while (0)
 
+#define netif_level(level, priv, type, dev, fmt, args...)	\
+do {								\
+	if (netif_msg_##type(priv))				\
+		netdev_##level(dev, fmt, ##args);		\
+} while (0)
+
 #define netif_emerg(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_EMERG, dev, fmt, ##args)
+	netif_level(emerg, priv, type, dev, fmt, ##args)
 #define netif_alert(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_ALERT, dev, fmt, ##args)
+	netif_level(alert, priv, type, dev, fmt, ##args)
 #define netif_crit(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_CRIT, dev, fmt, ##args)
+	netif_level(crit, priv, type, dev, fmt, ##args)
 #define netif_err(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_ERR, dev, fmt, ##args)
+	netif_level(err, priv, type, dev, fmt, ##args)
 #define netif_warn(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_WARNING, dev, fmt, ##args)
+	netif_level(warn, priv, type, dev, fmt, ##args)
 #define netif_notice(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_NOTICE, dev, fmt, ##args)
+	netif_level(notice, priv, type, dev, fmt, ##args)
 #define netif_info(priv, type, dev, fmt, args...)		\
-	netif_printk(priv, type, KERN_INFO, (dev), fmt, ##args)
+	netif_level(info, priv, type, dev, fmt, ##args)
 
 #if defined(DEBUG)
 #define netif_dbg(priv, type, dev, format, args...)		\
-- 
1.7.1.337.g6068.dirty

