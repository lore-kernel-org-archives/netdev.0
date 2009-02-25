From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] netlink: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:34:41 +0800
Message-ID: <49A51EC1.8000003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56180 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760678AbZBYKfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:35:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/netlink/af_netlink.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ed587be..6e37db9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1049,8 +1049,7 @@ int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 
 	netlink_unlock_table();
 
-	if (info.skb2)
-		kfree_skb(info.skb2);
+	kfree_skb(info.skb2);
 
 	if (info.delivery_failure)
 		return -ENOBUFS;
@@ -1542,8 +1541,7 @@ EXPORT_SYMBOL(netlink_set_nonroot);
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
 {
-	if (cb->skb)
-		kfree_skb(cb->skb);
+	kfree_skb(cb->skb);
 	kfree(cb);
 }
 
-- 
1.5.3.8




