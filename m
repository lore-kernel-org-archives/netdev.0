From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] netfilter: ctnetlink: move CTA_TIMEOUT case to outside
Date: Fri,  9 Jun 2017 12:37:47 +0800
Message-ID: <1496983067-11214-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cda[CTA_TIMEOUT] is zero, ctnetlink_new_conntrack will
free allocated ct and return, so move it to outside to optimize
this situation.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/netfilter/nf_conntrack_netlink.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a8be9b7..d1e6b1c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1768,9 +1768,6 @@ static int change_seq_adj(struct nf_ct_seqadj *seq,
 	if (IS_ERR(ct))
 		return ERR_PTR(-ENOMEM);
 
-	if (!cda[CTA_TIMEOUT])
-		goto err1;
-
 	ct->timeout = nfct_time_stamp + ntohl(nla_get_be32(cda[CTA_TIMEOUT])) * HZ;
 
 	rcu_read_lock();
@@ -1944,7 +1941,7 @@ static int ctnetlink_new_conntrack(struct net *net, struct sock *ctnl,
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			enum ip_conntrack_events events;
 
-			if (!cda[CTA_TUPLE_ORIG] || !cda[CTA_TUPLE_REPLY])
+			if (!cda[CTA_TUPLE_ORIG] || !cda[CTA_TUPLE_REPLY] || !cda[CTA_TIMEOUT])
 				return -EINVAL;
 			if (otuple.dst.protonum != rtuple.dst.protonum)
 				return -EINVAL;
-- 
1.8.3.1
