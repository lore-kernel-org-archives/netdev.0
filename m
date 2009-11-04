From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_cls: Use __dev_get_by_index()
Date: Wed, 04 Nov 2009 22:32:59 +0100
Message-ID: <4AF1F30B.2030705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57667 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758177AbZKDVc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:32:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We hold RTNL in tc_dump_tfilter(), we can avoid dev_hold()/dev_put()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/cls_api.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 7cf6c0f..c024da7 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -404,6 +404,7 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
 }
 
+/* called with RTNL */
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -422,7 +423,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 
 	if (cb->nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*tcm)))
 		return skb->len;
-	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
+	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
 	if (!tcm->tcm_parent)
@@ -484,7 +485,6 @@ errout:
 	if (cl)
 		cops->put(q, cl);
 out:
-	dev_put(dev);
 	return skb->len;
 }
 
