From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Use bool for return value of dev_valid_name().
Date: Tue, 06 Mar 2012 16:13:10 -0500 (EST)
Message-ID: <20120306.161310.850969890186352572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031152Ab2CFVNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:13:12 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q26LDA1L019339
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Mar 2012 13:13:11 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4d279c5..a89933b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2122,7 +2122,7 @@ extern int netdev_rx_handler_register(struct net_device *dev,
 				      void *rx_handler_data);
 extern void netdev_rx_handler_unregister(struct net_device *dev);
 
-extern int		dev_valid_name(const char *name);
+extern bool		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
 extern unsigned		dev_get_flags(const struct net_device *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 5ef3b65..0090809 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -848,21 +848,21 @@ EXPORT_SYMBOL(dev_get_by_flags_rcu);
  *	to allow sysfs to work.  We also disallow any kind of
  *	whitespace.
  */
-int dev_valid_name(const char *name)
+bool dev_valid_name(const char *name)
 {
 	if (*name == '\0')
-		return 0;
+		return false;
 	if (strlen(name) >= IFNAMSIZ)
-		return 0;
+		return false;
 	if (!strcmp(name, ".") || !strcmp(name, ".."))
-		return 0;
+		return false;
 
 	while (*name) {
 		if (*name == '/' || isspace(*name))
-			return 0;
+			return false;
 		name++;
 	}
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(dev_valid_name);
 
-- 
1.7.7.6
