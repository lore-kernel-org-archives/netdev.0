From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH 08/11] dynamic_debug: make netif_dbg() call __netdev_printk()
Date: Thu, 11 Aug 2011 14:36:53 -0400
Message-ID: <7a6c401a1329e366db4f4089a326ff292aa1a86e.1313085588.git.jbaron@redhat.com>
References: <cover.1313085588.git.jbaron@redhat.com>
Cc: joe@perches.com, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1313085588.git.jbaron@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Baron <jbaron@redhat.com>

Previously, netif_dbg() was using dynamic_dev_dbg() to perform
the underlying printk. Fix it to use __netdev_printk(), instead.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Jason Baron <jbaron@redhat.com>
---
 include/linux/netdevice.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9333a03..2797260 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2714,9 +2714,7 @@ do {								\
 #define netif_dbg(priv, type, netdev, format, args...)		\
 do {								\
 	if (netif_msg_##type(priv))				\
-		dynamic_dev_dbg((netdev)->dev.parent,		\
-				"%s: " format,			\
-				netdev_name(netdev), ##args);	\
+		dynamic_netdev_dbg(netdev, format, ##args);	\
 } while (0)
 #else
 #define netif_dbg(priv, type, dev, format, args...)			\
-- 
1.7.5.4
