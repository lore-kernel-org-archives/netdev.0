From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/2] nf_conntrack: table max size should hold at least table size
Date: Fri, 20 Feb 2009 00:43:41 +0100
Message-ID: <1235087023-30451-2-git-send-email-hagen@jauu.net>
References: <1235087023-30451-1-git-send-email-hagen@jauu.net>
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1235087023-30451-1-git-send-email-hagen@jauu.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Table size is defined as unsigned, wheres the table maximum size is
defined as a signed integer. The calculation of max is 8 or 4,
multiplied the table size. Therefore the max value is aligned to
unsigned.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/net/netfilter/nf_conntrack.h |    2 +-
 net/netfilter/nf_conntrack_core.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

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
-- 
1.5.6.5

