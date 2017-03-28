From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH v2] net: netfilter: add nfnl_msg_type() helper function
Date: Tue, 28 Mar 2017 22:25:00 +0530
Message-ID: <20170328165500.GA11580@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To remove complexity of code the function is added in nfnetlink.h
to make code more clear and readable.
This is opencoded in a way that makes it error prone for future
netfilter netlink subsystems.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
changes in v2
 - make the patch title more relevant
 - make the changes more wider.

 include/linux/netfilter/nfnetlink.h  |  6 ++++++
 net/netfilter/nf_conntrack_netlink.c | 12 +++++++-----
 net/netfilter/nfnetlink_acct.c       |  2 +-
 net/netfilter/nfnetlink_cthelper.c   |  2 +-
 net/netfilter/nfnetlink_cttimeout.c  |  4 ++--
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 1b49209dd5c7..9a36a7c3145d 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -50,6 +50,12 @@ static inline bool lockdep_nfnl_is_held(__u8 subsys_id)
 {
 	return true;
 }
+
+static inline u16 nfnl_msg_type(u8 subsys, u8 msg_type)
+{
+	return subsys << 8 | msg_type;
+}
+
 #endif /* CONFIG_PROVE_LOCKING */
 
 /*
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index aa344c5868c5..67f6f88a3e92 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -467,7 +467,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	struct nlattr *nest_parms;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK, IPCTNL_MSG_CT_NEW);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -1983,7 +1983,8 @@ ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK,
+			      IPCTNL_MSG_CT_GET_STATS_CPU);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2066,7 +2067,7 @@ ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 
-	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK, IPCTNL_MSG_CT_GET_STATS);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2576,7 +2577,7 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
-	event |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_EXP, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -3223,7 +3224,8 @@ ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, int cpu,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
-	event = NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK,
+			      IPCTNL_MSG_EXP_GET_STATS_CPU);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index d44d89b56127..ae0aef6cb7ee 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -138,7 +138,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	u64 pkts, bytes;
 	u32 old_flags;
 
-	event |= NFNL_SUBSYS_ACCT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_ACCT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index de8782345c86..e2c443c43cb9 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -416,7 +416,7 @@ nfnl_cthelper_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	int status;
 
-	event |= NFNL_SUBSYS_CTHELPER << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTHELPER, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 139e0867e56e..6d76172117e4 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -158,7 +158,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
 
-	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_TIMEOUT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -431,7 +431,7 @@ cttimeout_default_fill_info(struct net *net, struct sk_buff *skb, u32 portid,
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
-	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	event = nfnl_msg_type(NFNL_SUBSYS_CTNETLINK_TIMEOUT, event);
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
-- 
2.11.0

