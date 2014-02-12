From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] socket: replace some printk with pr_*
Date: Wed, 12 Feb 2014 17:09:55 +0800
Message-ID: <1392196195-6716-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5404 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbaBLJKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 04:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer pr_*(...) to printk(KERN_* ...).

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/socket.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 879933a..840cffb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -593,7 +593,7 @@ void sock_release(struct socket *sock)
 	}
 
 	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
-		printk(KERN_ERR "sock_release: fasync list not empty!\n");
+		pr_err("%s: fasync list not empty!\n", __func__);
 
 	if (test_bit(SOCK_EXTERNALLY_ALLOCATED, &sock->flags))
 		return;
@@ -1265,8 +1265,8 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 		static int warned;
 		if (!warned) {
 			warned = 1;
-			printk(KERN_INFO "%s uses obsolete (PF_INET,SOCK_PACKET)\n",
-			       current->comm);
+			pr_info("%s uses obsolete (PF_INET,SOCK_PACKET)\n",
+				current->comm);
 		}
 		family = PF_PACKET;
 	}
@@ -2595,8 +2595,7 @@ int sock_register(const struct net_proto_family *ops)
 	int err;
 
 	if (ops->family >= NPROTO) {
-		printk(KERN_CRIT "protocol %d >= NPROTO(%d)\n", ops->family,
-		       NPROTO);
+		pr_crit("protocol %d >= NPROTO(%d)\n", ops->family, NPROTO);
 		return -ENOBUFS;
 	}
 
@@ -2610,7 +2609,7 @@ int sock_register(const struct net_proto_family *ops)
 	}
 	spin_unlock(&net_family_lock);
 
-	printk(KERN_INFO "NET: Registered protocol family %d\n", ops->family);
+	pr_info("NET: Registered protocol family %d\n", ops->family);
 	return err;
 }
 EXPORT_SYMBOL(sock_register);
@@ -2638,7 +2637,7 @@ void sock_unregister(int family)
 
 	synchronize_rcu();
 
-	printk(KERN_INFO "NET: Unregistered protocol family %d\n", family);
+	pr_info("NET: Unregistered protocol family %d\n", family);
 }
 EXPORT_SYMBOL(sock_unregister);
 
-- 
1.8.0
