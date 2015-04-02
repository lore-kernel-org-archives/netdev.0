From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 04/12] ipmr,ip6mr: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:03 +0200
Message-ID: <1427987231-3669-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56621 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbbDBPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:25 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c  | 7 ++++++-
 net/ipv6/ip6mr.c | 7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index eec68b0c3bc8..d2e3b3ef039e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -473,8 +473,14 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int reg_vif_get_iflink(const struct net_device *dev)
+{
+	return 0;
+}
+
 static const struct net_device_ops reg_vif_netdev_ops = {
 	.ndo_start_xmit	= reg_vif_xmit,
+	.ndo_get_iflink = reg_vif_get_iflink,
 };
 
 static void reg_vif_setup(struct net_device *dev)
@@ -509,7 +515,6 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 		free_netdev(dev);
 		return NULL;
 	}
-	dev->iflink = 0;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 18a5ab286420..003431f5b4b6 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -718,8 +718,14 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int reg_vif_get_iflink(const struct net_device *dev)
+{
+	return 0;
+}
+
 static const struct net_device_ops reg_vif_netdev_ops = {
 	.ndo_start_xmit	= reg_vif_xmit,
+	.ndo_get_iflink = reg_vif_get_iflink,
 };
 
 static void reg_vif_setup(struct net_device *dev)
@@ -752,7 +758,6 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 		free_netdev(dev);
 		return NULL;
 	}
-	dev->iflink = 0;
 
 	if (dev_open(dev))
 		goto failure;
-- 
2.2.2
