From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] netfilter: Remove uses of seq_<foo> return values
Date: Mon, 23 Mar 2015 12:36:19 +0100
Message-ID: <1427110584-5190-4-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

The seq_printf/seq_puts/seq_putc return values, because they
are frequently misused, will eventually be converted to void.

See: commit 1f33c41c03da ("seq_file: Rename seq_overflow() to
     seq_has_overflowed() and make public")

Miscellanea:

o realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    4 +++-
 net/netfilter/nf_conntrack_acct.c                     |    8 +++++---
 net/netfilter/nf_conntrack_expect.c                   |    4 +++-
 net/netfilter/nfnetlink_log.c                         |   12 +++++++-----
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index a460a87..f0dfe92 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -300,7 +300,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
 		    __nf_ct_l3proto_find(exp->tuple.src.l3num),
 		    __nf_ct_l4proto_find(exp->tuple.src.l3num,
 					 exp->tuple.dst.protonum));
-	return seq_putc(s, '\n');
+	seq_putc(s, '\n');
+
+	return 0;
 }
 
 static const struct seq_operations exp_seq_ops = {
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index a4b5e2a..45da11a 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -47,9 +47,11 @@ seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 		return 0;
 
 	counter = acct->counter;
-	return seq_printf(s, "packets=%llu bytes=%llu ",
-			  (unsigned long long)atomic64_read(&counter[dir].packets),
-			  (unsigned long long)atomic64_read(&counter[dir].bytes));
+	seq_printf(s, "packets=%llu bytes=%llu ",
+		   (unsigned long long)atomic64_read(&counter[dir].packets),
+		   (unsigned long long)atomic64_read(&counter[dir].bytes));
+
+	return 0;
 };
 EXPORT_SYMBOL_GPL(seq_print_acct);
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 91a1837..7a17070 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -561,7 +561,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
 				   helper->expect_policy[expect->class].name);
 	}
 
-	return seq_putc(s, '\n');
+	seq_putc(s, '\n');
+
+	return 0;
 }
 
 static const struct seq_operations exp_seq_ops = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 11d85b3..db5e3a8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -998,11 +998,13 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfulnl_instance *inst = v;
 
-	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
-			  inst->group_num,
-			  inst->peer_portid, inst->qlen,
-			  inst->copy_mode, inst->copy_range,
-			  inst->flushtimeout, atomic_read(&inst->use));
+	seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
+		   inst->group_num,
+		   inst->peer_portid, inst->qlen,
+		   inst->copy_mode, inst->copy_range,
+		   inst->flushtimeout, atomic_read(&inst->use));
+
+	return 0;
 }
 
 static const struct seq_operations nful_seq_ops = {
-- 
1.7.10.4

