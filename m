From: pablo@netfilter.org
Subject: [PATCH 05/12] netfilter: ebt_ulog: remove unnecessary spin lock protection
Date: Mon, 25 Mar 2013 13:15:45 +0100
Message-ID: <1364213752-3934-6-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46533 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757227Ab3CYMQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:16 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

No need for spinlock to protect the netlink skb in the
ebt_ulog_fini path. We are sure there is noone using it
at that stage.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_ulog.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 3bf43f7..442b032 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -319,12 +319,11 @@ static void __exit ebt_ulog_fini(void)
 	for (i = 0; i < EBT_ULOG_MAXNLGROUPS; i++) {
 		ub = &ulog_buffers[i];
 		del_timer(&ub->timer);
-		spin_lock_bh(&ub->lock);
+
 		if (ub->skb) {
 			kfree_skb(ub->skb);
 			ub->skb = NULL;
 		}
-		spin_unlock_bh(&ub->lock);
 	}
 	netlink_kernel_release(ebtulognl);
 }
-- 
1.7.10.4
