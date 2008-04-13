From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.26] [IPV6] MROUTE: Do not call ipv6_find_idev()
 directly.
Date: Sun, 13 Apr 2008 16:58:30 +0900 (JST)
Message-ID: <20080413.165830.63819736.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33440 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbYDMH4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 03:56:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since NETDEV_REGISTER notifier chain is responsible for creating
inet6_dev{}, we do not need to call ipv6_find_idev() directly here.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/mroute6.h |    3 ---
 net/ipv6/addrconf.c     |    2 +-
 net/ipv6/ip6mr.c        |    5 -----
 3 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index f6469fb..e798959 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -117,9 +117,6 @@ struct sioc_mif_req6
 
 #include <linux/skbuff.h>	/* for struct sk_buff_head */
 
-struct net_device;
-struct inet6_dev *ipv6_find_idev(struct net_device *dev);
-
 #ifdef CONFIG_IPV6_MROUTE
 static inline int ip6_mroute_opt(int opt)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e93fa62..9d49ed2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -412,7 +412,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	return ndev;
 }
 
-struct inet6_dev * ipv6_find_idev(struct net_device *dev)
+static struct inet6_dev * ipv6_find_idev(struct net_device *dev)
 {
 	struct inet6_dev *idev;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 94ede69..6e2e3c9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -435,7 +435,6 @@ static void reg_vif_setup(struct net_device *dev)
 static struct net_device *ip6mr_reg_vif(void)
 {
 	struct net_device *dev;
-	struct inet6_dev *in_dev;
 
 	dev = alloc_netdev(sizeof(struct net_device_stats), "pim6reg",
 			   reg_vif_setup);
@@ -449,10 +448,6 @@ static struct net_device *ip6mr_reg_vif(void)
 	}
 	dev->iflink = 0;
 
-	in_dev = ipv6_find_idev(dev);
-	if (!in_dev)
-		goto failure;
-
 	if (dev_open(dev))
 		goto failure;
 
-- 
1.4.4.4

