From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 19/30] net: Remove dev_queue_xmit_sk
Date: Tue, 15 Sep 2015 20:04:07 -0500
Message-ID: <1442365458-16349-19-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60408 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbbIPBNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:41 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A function with weird arguments that it will never use to accomdate a
netfilter callback prototype is absolutely in the core of the
networking stack.  Frankly it does not make sense and it causes a lot
of confusion as to why arguments that are never used are being passed
to the function.

As I am preparing to make a second change to arguments to the okfn even
the names stops making sense.

As I have removed the two callers of this function remove this confusion
from the networking stack.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h | 6 +-----
 net/core/dev.c            | 4 ++--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a00694eda5..e664f87c8e4c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2213,11 +2213,7 @@ int dev_close(struct net_device *dev);
 int dev_close_many(struct list_head *head, bool unlink);
 void dev_disable_lro(struct net_device *dev);
 int dev_loopback_xmit(struct sock *sk, struct sk_buff *newskb);
-int dev_queue_xmit_sk(struct sock *sk, struct sk_buff *skb);
-static inline int dev_queue_xmit(struct sk_buff *skb)
-{
-	return dev_queue_xmit_sk(skb->sk, skb);
-}
+int dev_queue_xmit(struct sk_buff *skb);
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
 int register_netdevice(struct net_device *dev);
 void unregister_netdevice_queue(struct net_device *dev, struct list_head *head);
diff --git a/net/core/dev.c b/net/core/dev.c
index 877c84834d81..dcf9ff913925 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3143,11 +3143,11 @@ out:
 	return rc;
 }
 
-int dev_queue_xmit_sk(struct sock *sk, struct sk_buff *skb)
+int dev_queue_xmit(struct sk_buff *skb)
 {
 	return __dev_queue_xmit(skb, NULL);
 }
-EXPORT_SYMBOL(dev_queue_xmit_sk);
+EXPORT_SYMBOL(dev_queue_xmit);
 
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv)
 {
-- 
2.2.1
