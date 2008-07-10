From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] netlabel: netlink_unicast calls kfree_skb on error path by itself
Date: Thu, 10 Jul 2008 17:11:24 +0400
Message-ID: <1215695484-17519-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, paul.moore@hp.com,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30775 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026AbYGJNK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 09:10:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, no need to kfree_skb here on the error path. In this case we can simply
return.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/netlabel/netlabel_cipso_v4.c  |    7 +------
 net/netlabel/netlabel_mgmt.c      |   12 ++----------
 net/netlabel/netlabel_unlabeled.c |    6 +-----
 3 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index fdc14a0..9080c61 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -584,12 +584,7 @@ list_start:
 	rcu_read_unlock();
 
 	genlmsg_end(ans_skb, data);
-
-	ret_val = genlmsg_reply(ans_skb, info);
-	if (ret_val != 0)
-		goto list_failure;
-
-	return 0;
+	return genlmsg_reply(ans_skb, info);
 
 list_retry:
 	/* XXX - this limit is a guesstimate */
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 22c1912..44be5d5 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -386,11 +386,7 @@ static int netlbl_mgmt_listdef(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_unlock();
 
 	genlmsg_end(ans_skb, data);
-
-	ret_val = genlmsg_reply(ans_skb, info);
-	if (ret_val != 0)
-		goto listdef_failure;
-	return 0;
+	return genlmsg_reply(ans_skb, info);
 
 listdef_failure_lock:
 	rcu_read_unlock();
@@ -501,11 +497,7 @@ static int netlbl_mgmt_version(struct sk_buff *skb, struct genl_info *info)
 		goto version_failure;
 
 	genlmsg_end(ans_skb, data);
-
-	ret_val = genlmsg_reply(ans_skb, info);
-	if (ret_val != 0)
-		goto version_failure;
-	return 0;
+	return genlmsg_reply(ans_skb, info);
 
 version_failure:
 	kfree_skb(ans_skb);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 52b2611..56f8087 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1107,11 +1107,7 @@ static int netlbl_unlabel_list(struct sk_buff *skb, struct genl_info *info)
 		goto list_failure;
 
 	genlmsg_end(ans_skb, data);
-
-	ret_val = genlmsg_reply(ans_skb, info);
-	if (ret_val != 0)
-		goto list_failure;
-	return 0;
+	return genlmsg_reply(ans_skb, info);
 
 list_failure:
 	kfree_skb(ans_skb);
-- 
1.5.3.rc5

