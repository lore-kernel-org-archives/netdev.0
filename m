From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/02: ctnetlink: report error if event message allocation fails
Date: Fri, 17 Apr 2009 18:09:14 +0200 (MEST)
Message-ID: <20090417160914.32484.5655.sendpatchset@x2.localnet>
References: <20090417160913.32484.93063.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758611AbZDQQJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:09:16 -0400
In-Reply-To: <20090417160913.32484.93063.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 150ace0db360373d2016a2497d252138a59c5ba8
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Fri Apr 17 17:47:31 2009 +0200

    netfilter: ctnetlink: report error if event message allocation fails
    
    This patch fixes an inconsistency that results in no error reports
    to user-space listeners if we fail to allocate the event message.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c6439c7..0ea36e0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -512,7 +512,7 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 
 	skb = ctnetlink_alloc_skb(tuple(ct, IP_CT_DIR_ORIGINAL), GFP_ATOMIC);
 	if (!skb)
-		return NOTIFY_DONE;
+		goto errout;
 
 	b = skb->tail;
 
@@ -591,8 +591,9 @@ static int ctnetlink_conntrack_event(struct notifier_block *this,
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
-	nfnetlink_set_err(0, group, -ENOBUFS);
 	kfree_skb(skb);
+errout:
+	nfnetlink_set_err(0, group, -ENOBUFS);
 	return NOTIFY_DONE;
 }
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
@@ -1564,7 +1565,7 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);
 	if (!skb)
-		return NOTIFY_DONE;
+		goto errout;
 
 	b = skb->tail;
 
@@ -1589,8 +1590,9 @@ static int ctnetlink_expect_event(struct notifier_block *this,
 nla_put_failure:
 	rcu_read_unlock();
 nlmsg_failure:
-	nfnetlink_set_err(0, 0, -ENOBUFS);
 	kfree_skb(skb);
+errout:
+	nfnetlink_set_err(0, 0, -ENOBUFS);
 	return NOTIFY_DONE;
 }
 #endif
