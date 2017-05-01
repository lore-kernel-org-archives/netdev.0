From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/53] netfilter: Use seq_puts()/seq_putc() where possible
Date: Mon,  1 May 2017 12:46:39 +0200
Message-ID: <1493635640-24325-13-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: simran singhal <singhalsimran0@gmail.com>

For string without format specifiers, use seq_puts(). For
seq_printf("\n"), use seq_putc('\n').

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c          | 8 ++++----
 net/netfilter/nf_conntrack_expect.c     | 4 ++--
 net/netfilter/nf_conntrack_standalone.c | 6 +++---
 net/netfilter/nf_log.c                  | 4 ++--
 net/netfilter/nf_synproxy_core.c        | 6 +++---
 net/netfilter/xt_recent.c               | 2 +-
 6 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 541aa7694775..c578b6c0dc41 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2130,8 +2130,8 @@ static int ip_vs_stats_show(struct seq_file *seq, void *v)
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
-	seq_printf(seq,
-		   "   Conns  Packets  Packets            Bytes            Bytes\n");
+	seq_puts(seq,
+		 "   Conns  Packets  Packets            Bytes            Bytes\n");
 
 	ip_vs_copy_stats(&show, &net_ipvs(net)->tot_stats);
 	seq_printf(seq, "%8LX %8LX %8LX %16LX %16LX\n\n",
@@ -2178,8 +2178,8 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 /*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
 	seq_puts(seq,
 		 "       Total Incoming Outgoing         Incoming         Outgoing\n");
-	seq_printf(seq,
-		   "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
+	seq_puts(seq,
+		 "CPU    Conns  Packets  Packets            Bytes            Bytes\n");
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *u = per_cpu_ptr(cpustats, i);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 71d136469be0..7f12c8a78112 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -549,7 +549,7 @@ static int exp_seq_show(struct seq_file *s, void *v)
 		seq_printf(s, "%ld ", timer_pending(&expect->timeout)
 			   ? (long)(expect->timeout.expires - jiffies)/HZ : 0);
 	else
-		seq_printf(s, "- ");
+		seq_puts(s, "- ");
 	seq_printf(s, "l3proto = %u proto=%u ",
 		   expect->tuple.src.l3num,
 		   expect->tuple.dst.protonum);
@@ -559,7 +559,7 @@ static int exp_seq_show(struct seq_file *s, void *v)
 				       expect->tuple.dst.protonum));
 
 	if (expect->flags & NF_CT_EXPECT_PERMANENT) {
-		seq_printf(s, "PERMANENT");
+		seq_puts(s, "PERMANENT");
 		delim = ",";
 	}
 	if (expect->flags & NF_CT_EXPECT_INACTIVE) {
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 2256147dcaad..ccb5cb9043e0 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -250,7 +250,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 
 	if (!(test_bit(IPS_SEEN_REPLY_BIT, &ct->status)))
-		seq_printf(s, "[UNREPLIED] ");
+		seq_puts(s, "[UNREPLIED] ");
 
 	print_tuple(s, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 		    l3proto, l4proto);
@@ -261,7 +261,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 
 	if (test_bit(IPS_ASSURED_BIT, &ct->status))
-		seq_printf(s, "[ASSURED] ");
+		seq_puts(s, "[ASSURED] ");
 
 	if (seq_has_overflowed(s))
 		goto release;
@@ -350,7 +350,7 @@ static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
+		seq_puts(seq, "entries  searched found new invalid ignore delete delete_list insert insert_failed drop early_drop icmp_error  expect_new expect_create expect_delete search_restart\n");
 		return 0;
 	}
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8d85a0598b60..cc32727e3f32 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -376,13 +376,13 @@ static int seq_show(struct seq_file *s, void *v)
 		logger = nft_log_dereference(loggers[*pos][i]);
 		seq_printf(s, "%s", logger->name);
 		if (i == 0 && loggers[*pos][i + 1] != NULL)
-			seq_printf(s, ",");
+			seq_puts(s, ",");
 
 		if (seq_has_overflowed(s))
 			return -ENOSPC;
 	}
 
-	seq_printf(s, ")\n");
+	seq_puts(s, ")\n");
 
 	if (seq_has_overflowed(s))
 		return -ENOSPC;
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 7c6d1fbe38b9..abe03e869f7b 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -287,9 +287,9 @@ static int synproxy_cpu_seq_show(struct seq_file *seq, void *v)
 	struct synproxy_stats *stats = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries\t\tsyn_received\t"
-				"cookie_invalid\tcookie_valid\t"
-				"cookie_retrans\tconn_reopened\n");
+		seq_puts(seq, "entries\t\tsyn_received\t"
+			      "cookie_invalid\tcookie_valid\t"
+			      "cookie_retrans\tconn_reopened\n");
 		return 0;
 	}
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 1d89a4eaf841..37d581a31cff 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -532,7 +532,7 @@ static int recent_seq_show(struct seq_file *seq, void *v)
 			   &e->addr.in6, e->ttl, e->stamps[i], e->index);
 	for (i = 0; i < e->nstamps; i++)
 		seq_printf(seq, "%s %lu", i ? "," : "", e->stamps[i]);
-	seq_printf(seq, "\n");
+	seq_putc(seq, '\n');
 	return 0;
 }
 
-- 
2.1.4

