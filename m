From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 15/41: nf_conntrack: table max size should hold at least table size
Date: Tue, 24 Mar 2009 15:03:27 +0100 (MET)
Message-ID: <20090324140323.31401.2934.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e478075c6f07a383c378fb400edc1a7407a941b0
Author: Hagen Paul Pfeifer <hagen@jauu.net>
Date:   Fri Feb 20 10:47:09 2009 +0100

    netfilter: nf_conntrack: table max size should hold at least table size
    
    Table size is defined as unsigned, wheres the table maximum size is
    defined as a signed integer. The calculation of max is 8 or 4,
    multiplied the table size. Therefore the max value is aligned to
    unsigned.
    
    Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2e0c536..4dfb793 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -287,7 +287,7 @@ static inline int nf_ct_is_untracked(const struct sk_buff *skb)
 
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 extern unsigned int nf_conntrack_htable_size;
-extern int nf_conntrack_max;
+extern unsigned int nf_conntrack_max;
 
 #define NF_CT_STAT_INC(net, count)	\
 	(per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 90ce9dd..f3aa4e6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -54,7 +54,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 unsigned int nf_conntrack_htable_size __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 
-int nf_conntrack_max __read_mostly;
+unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
 struct nf_conn nf_conntrack_untracked __read_mostly;
