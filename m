From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH RFC] netfilter: cacheline aligning in struct netns_ct
Date: Wed, 12 Mar 2014 15:56:34 +0800
Message-ID: <1394610994-22794-1-git-send-email-yizhouzhou@ict.ac.cn>
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: <davem@davemloft.net>, <pablo@netfilter.org>, <jbenc@redhat.com>,
	<brouer@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

not frequently changing components should share same cachelines

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
---
 include/net/netns/conntrack.h |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index fbcc7fa..69d2d58 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -65,6 +65,12 @@ struct nf_ip_net {
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
+	struct hlist_nulls_head	unconfirmed;
+	struct hlist_nulls_head	dying;
+	struct hlist_nulls_head tmpl;
+
+	/*  not frequently changing components should share same cachelines */
+	struct nf_ip_net	nf_ct_proto ____cacheline_aligned_in_smp;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
@@ -86,13 +92,11 @@ struct netns_ct {
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
-	struct hlist_nulls_head	unconfirmed;
-	struct hlist_nulls_head	dying;
-	struct hlist_nulls_head tmpl;
+
 	struct ip_conntrack_stat __percpu *stat;
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
 	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
-	struct nf_ip_net	nf_ct_proto;
+
 #if defined(CONFIG_NF_CONNTRACK_LABELS)
 	unsigned int		labels_used;
 	u8			label_words;
-- 
1.7.10.4
