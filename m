From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] macvlan: make start_xmit local
Date: Fri, 27 Dec 2013 12:06:46 -0800
Message-ID: <20131227120646.52138f4b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:64243 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab3L0UGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 15:06:54 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so9621940pad.12
        for <netdev@vger.kernel.org>; Fri, 27 Dec 2013 12:06:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used in one file, no need to expose

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/macvlan.c      |    5 ++---
 include/linux/if_macvlan.h |    3 ---
 2 files changed, 2 insertions(+), 6 deletions(-)

--- a/drivers/net/macvlan.c	2013-12-24 15:15:26.885739628 -0800
+++ b/drivers/net/macvlan.c	2013-12-24 15:15:59.221305048 -0800
@@ -290,8 +290,8 @@ xmit_world:
 	return dev_queue_xmit(skb);
 }
 
-netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
-			       struct net_device *dev)
+static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	unsigned int len = skb->len;
 	int ret;
@@ -317,7 +317,6 @@ netdev_tx_t macvlan_start_xmit(struct sk
 	}
 	return ret;
 }
-EXPORT_SYMBOL_GPL(macvlan_start_xmit);
 
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 			       unsigned short type, const void *daddr,
--- a/include/linux/if_macvlan.h	2013-12-24 15:15:26.885739628 -0800
+++ b/include/linux/if_macvlan.h	2013-12-24 15:15:59.221305048 -0800
@@ -111,9 +111,6 @@ extern void macvlan_dellink(struct net_d
 
 extern int macvlan_link_register(struct rtnl_link_ops *ops);
 
-extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
-				      struct net_device *dev);
-
 #if IS_ENABLED(CONFIG_MACVLAN)
 static inline struct net_device *
 macvlan_dev_real_dev(const struct net_device *dev)
