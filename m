From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilter: Remove complexity
Date: Tue, 28 Mar 2017 18:30:56 +0530
Message-ID: <20170328130032.GA5009@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To remove complexity of code the function is added in nfnetlink.h
to make code more clear and readable.

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 include/linux/netfilter/nfnetlink.h  |  6 ++++++
 net/netfilter/nf_conntrack_netlink.c | 12 +++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

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
-- 
2.11.0
