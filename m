From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netdev: change name length
Date: Fri, 11 Aug 2006 15:13:29 -0700
Message-ID: <20060811151329.3bcb94b8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42732 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964796AbWHKWNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 18:13:34 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some improvements to robust name interface.  These API's are safe
now by convention, but it is worth providing some safety checks
against future bugs.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/core/dev.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- net-2.6.19.orig/net/core/dev.c
+++ net-2.6.19/net/core/dev.c
@@ -636,7 +636,8 @@ struct net_device * dev_get_by_flags(uns
  */
 int dev_valid_name(const char *name)
 {
-	return !(*name == '\0' 
+	return !(*name == '\0'
+		 || strlen(name) >= IFNAMSIZ
 		 || !strcmp(name, ".")
 		 || !strcmp(name, "..")
 		 || strchr(name, '/'));
@@ -3198,13 +3199,15 @@ struct net_device *alloc_netdev(int size
 	struct net_device *dev;
 	int alloc_size;
 
+	BUG_ON(strlen(name) >= sizeof(dev->name));
+
 	/* ensure 32-byte alignment of both the device and private area */
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
-		printk(KERN_ERR "alloc_dev: Unable to allocate device.\n");
+		printk(KERN_ERR "alloc_netdev: Unable to allocate device.\n");
 		return NULL;
 	}
 
