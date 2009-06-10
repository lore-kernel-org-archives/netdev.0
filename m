From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/31: xtables: fix const inconsistency
Date: Wed, 10 Jun 2009 21:46:29 +0200 (MEST)
Message-ID: <20090610194627.11112.14436.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4f2f6f236af484ada595ff37d0ee1902aa56221f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 20:31:13 2009 +0200

    netfilter: xtables: fix const inconsistency
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 7fcbc16..16b7c09 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -238,8 +238,8 @@ static struct nf_loginfo trace_loginfo = {
 /* Mildly perf critical (only if packet tracing is on) */
 static inline int
 get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
-		      char *hookname, char **chainname,
-		      char **comment, unsigned int *rulenum)
+		      const char *hookname, const char **chainname,
+		      const char **comment, unsigned int *rulenum)
 {
 	struct ipt_standard_target *t = (void *)ipt_get_target(s);
 
@@ -257,8 +257,8 @@ get_chainname_rulenum(struct ipt_entry *s, struct ipt_entry *e,
 		   && unconditional(&s->ip)) {
 			/* Tail of chains: STANDARD target (return/policy) */
 			*comment = *chainname == hookname
-				? (char *)comments[NF_IP_TRACE_COMMENT_POLICY]
-				: (char *)comments[NF_IP_TRACE_COMMENT_RETURN];
+				? comments[NF_IP_TRACE_COMMENT_POLICY]
+				: comments[NF_IP_TRACE_COMMENT_RETURN];
 		}
 		return 1;
 	} else
@@ -277,14 +277,14 @@ static void trace_packet(struct sk_buff *skb,
 {
 	void *table_base;
 	const struct ipt_entry *root;
-	char *hookname, *chainname, *comment;
+	const char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
 
 	table_base = private->entries[smp_processor_id()];
 	root = get_entry(table_base, private->hook_entry[hook]);
 
-	hookname = chainname = (char *)hooknames[hook];
-	comment = (char *)comments[NF_IP_TRACE_COMMENT_RULE];
+	hookname = chainname = hooknames[hook];
+	comment = comments[NF_IP_TRACE_COMMENT_RULE];
 
 	IPT_ENTRY_ITERATE(root,
 			  private->size - private->hook_entry[hook],
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 2b52fac..4853a3d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -270,8 +270,8 @@ static struct nf_loginfo trace_loginfo = {
 /* Mildly perf critical (only if packet tracing is on) */
 static inline int
 get_chainname_rulenum(struct ip6t_entry *s, struct ip6t_entry *e,
-		      char *hookname, char **chainname,
-		      char **comment, unsigned int *rulenum)
+		      const char *hookname, const char **chainname,
+		      const char **comment, unsigned int *rulenum)
 {
 	struct ip6t_standard_target *t = (void *)ip6t_get_target(s);
 
@@ -289,8 +289,8 @@ get_chainname_rulenum(struct ip6t_entry *s, struct ip6t_entry *e,
 		   && unconditional(&s->ipv6)) {
 			/* Tail of chains: STANDARD target (return/policy) */
 			*comment = *chainname == hookname
-				? (char *)comments[NF_IP6_TRACE_COMMENT_POLICY]
-				: (char *)comments[NF_IP6_TRACE_COMMENT_RETURN];
+				? comments[NF_IP6_TRACE_COMMENT_POLICY]
+				: comments[NF_IP6_TRACE_COMMENT_RETURN];
 		}
 		return 1;
 	} else
@@ -309,14 +309,14 @@ static void trace_packet(struct sk_buff *skb,
 {
 	void *table_base;
 	const struct ip6t_entry *root;
-	char *hookname, *chainname, *comment;
+	const char *hookname, *chainname, *comment;
 	unsigned int rulenum = 0;
 
 	table_base = private->entries[smp_processor_id()];
 	root = get_entry(table_base, private->hook_entry[hook]);
 
-	hookname = chainname = (char *)hooknames[hook];
-	comment = (char *)comments[NF_IP6_TRACE_COMMENT_RULE];
+	hookname = chainname = hooknames[hook];
+	comment = comments[NF_IP6_TRACE_COMMENT_RULE];
 
 	IP6T_ENTRY_ITERATE(root,
 			   private->size - private->hook_entry[hook],
