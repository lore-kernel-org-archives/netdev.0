From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/2][GENETLINK] add cmd dump completion
Date: Fri, 01 Dec 2006 06:33:48 -0500
Message-ID: <1164972828.3562.11.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-8z2oYtlEIh9v2L4/7Oin"
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:30405 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936464AbWLALdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 06:33:52 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1516407nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 03:33:51 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8z2oYtlEIh9v2L4/7Oin
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Sorry, subject was a little messed in the previous one, but should
be fine going forward ..

cheers,
jamal


--=-8z2oYtlEIh9v2L4/7Oin
Content-Disposition: attachment; filename=gnl-dec1-2
Content-Type: text/plain; name=gnl-dec1-2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENETLINK] add cmd dump completion

Remove assumption that generic netlink commands cannot have dump
completion callbacks.

Signed-off-by: Jamal Hadi Salim<hadi@cyberus.ca>

---
commit 7df98e8c6358e7e8483279904823b7bb7bcf8e50
tree 774cd008cbfb4f981e30064da301b8fc7f9476f6
parent 349e0e00396b79d8f2f9a41f6dc28dee9e7d3e3e
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 01 Dec 2006 06:14:20 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Fri, 01 Dec 2006 06:14:20 -0500

 include/net/genetlink.h |    2 ++
 net/netlink/genetlink.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 7fd131c..adff4c8 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -53,6 +53,7 @@ struct genl_info
  * @policy: attribute validation policy
  * @doit: standard command callback
  * @dumpit: callback for dumpers
+ * @done: completion callback for dumps
  * @ops_list: operations list
  */
 struct genl_ops
@@ -64,6 +65,7 @@ struct genl_ops
 				       struct genl_info *info);
 	int		       (*dumpit)(struct sk_buff *skb,
 					 struct netlink_callback *cb);
+	int		       (*done)(struct netlink_callback *cb);
 	struct list_head	ops_list;
 };
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 50928da..96b6820 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -338,7 +338,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		}
 
 		*errp = err = netlink_dump_start(genl_sock, skb, nlh,
-						 ops->dumpit, NULL);
+						 ops->dumpit, ops->done);
 		if (err == 0)
 			skb_pull(skb, min(NLMSG_ALIGN(nlh->nlmsg_len),
 					  skb->len));

--=-8z2oYtlEIh9v2L4/7Oin--

