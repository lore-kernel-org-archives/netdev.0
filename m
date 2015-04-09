From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/5 v2] netfilter: Fix portid types
Date: Thu,  9 Apr 2015 23:57:15 +0200
Message-ID: <1428616637-21690-3-git-send-email-richard@nod.at>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428616637-21690-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netlink portid is an unsigned integer, use this type
also in netfilter.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/netfilter/nfnetlink_log.c        | 4 ++--
 net/netfilter/nfnetlink_queue_core.c | 7 +++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 11d85b3..7150d11 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -62,7 +62,7 @@ struct nfulnl_instance {
 	struct timer_list timer;
 	struct net *net;
 	struct user_namespace *peer_user_ns;	/* User namespace of the peer process */
-	int peer_portid;			/* PORTID of the peer process */
+	u32 peer_portid;		/* PORTID of the peer process */
 
 	/* configurable parameters */
 	unsigned int flushtimeout;	/* timeout until queue flush */
@@ -151,7 +151,7 @@ static void nfulnl_timer(unsigned long data);
 
 static struct nfulnl_instance *
 instance_create(struct net *net, u_int16_t group_num,
-		int portid, struct user_namespace *user_ns)
+		u32 portid, struct user_namespace *user_ns)
 {
 	struct nfulnl_instance *inst;
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 0db8515..0aba0b9 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -54,7 +54,7 @@ struct nfqnl_instance {
 	struct hlist_node hlist;		/* global list of queues */
 	struct rcu_head rcu;
 
-	int peer_portid;
+	u32 peer_portid;
 	unsigned int queue_maxlen;
 	unsigned int copy_range;
 	unsigned int queue_dropped;
@@ -109,8 +109,7 @@ instance_lookup(struct nfnl_queue_net *q, u_int16_t queue_num)
 }
 
 static struct nfqnl_instance *
-instance_create(struct nfnl_queue_net *q, u_int16_t queue_num,
-		int portid)
+instance_create(struct nfnl_queue_net *q, u_int16_t queue_num, u32 portid)
 {
 	struct nfqnl_instance *inst;
 	unsigned int h;
@@ -860,7 +859,7 @@ static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
 };
 
 static struct nfqnl_instance *
-verdict_instance_lookup(struct nfnl_queue_net *q, u16 queue_num, int nlportid)
+verdict_instance_lookup(struct nfnl_queue_net *q, u16 queue_num, u32 nlportid)
 {
 	struct nfqnl_instance *queue;
 
-- 
1.8.4.5
