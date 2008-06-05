From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next] netlink: Remove nonblock parameter from netlink_attachskb
Date: Thu,  5 Jun 2008 18:24:56 +0400
Message-ID: <1212675896-18012-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23550 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755471AbYFEOYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:24:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/linux/netlink.h  |    2 +-
 ipc/mqueue.c             |    2 +-
 net/netlink/af_netlink.c |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index bec1062..9ff1b54 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -193,7 +193,7 @@ extern int netlink_unregister_notifier(struct notifier_block *nb);
 
 /* finegrained unicast helpers: */
 struct sock *netlink_getsockbyfilp(struct file *filp);
-int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
+int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		      long *timeo, struct sock *ssk);
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index b3b69fd..3e84b95 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1054,7 +1054,7 @@ retry:
 			}
 
 			timeo = MAX_SCHEDULE_TIMEOUT;
-			ret = netlink_attachskb(sock, nc, 0, &timeo, NULL);
+			ret = netlink_attachskb(sock, nc, &timeo, NULL);
 			if (ret == 1)
 		       		goto retry;
 			if (ret) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b97f80..6507c02 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -759,7 +759,7 @@ struct sock *netlink_getsockbyfilp(struct file *filp)
  * 0: continue
  * 1: repeat lookup - reference dropped while waiting for socket memory.
  */
-int netlink_attachskb(struct sock *sk, struct sk_buff *skb, int nonblock,
+int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 		      long *timeo, struct sock *ssk)
 {
 	struct netlink_sock *nlk;
@@ -892,7 +892,7 @@ retry:
 		return err;
 	}
 
-	err = netlink_attachskb(sk, skb, nonblock, &timeo, ssk);
+	err = netlink_attachskb(sk, skb, &timeo, ssk);
 	if (err == 1)
 		goto retry;
 	if (err)
-- 
1.5.3.rc5

