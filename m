From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/23] netfilter: conntrack: don't acquire lock during seq_printf
Date: Fri, 22 Apr 2016 15:39:54 +0200
Message-ID: <1461332394-3994-24-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

read access doesn't need any lock here.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_sctp.c | 8 +-------
 net/netfilter/nf_conntrack_proto_tcp.c  | 8 +-------
 2 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 9578a7c..1d7ab96 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -191,13 +191,7 @@ static void sctp_print_tuple(struct seq_file *s,
 /* Print out the private part of the conntrack. */
 static void sctp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
-	enum sctp_conntrack state;
-
-	spin_lock_bh(&ct->lock);
-	state = ct->proto.sctp.state;
-	spin_unlock_bh(&ct->lock);
-
-	seq_printf(s, "%s ", sctp_conntrack_names[state]);
+	seq_printf(s, "%s ", sctp_conntrack_names[ct->proto.sctp.state]);
 }
 
 #define for_each_sctp_chunk(skb, sch, _sch, offset, dataoff, count)	\
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 278f3b9..e0cb0ce 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -313,13 +313,7 @@ static void tcp_print_tuple(struct seq_file *s,
 /* Print out the private part of the conntrack. */
 static void tcp_print_conntrack(struct seq_file *s, struct nf_conn *ct)
 {
-	enum tcp_conntrack state;
-
-	spin_lock_bh(&ct->lock);
-	state = ct->proto.tcp.state;
-	spin_unlock_bh(&ct->lock);
-
-	seq_printf(s, "%s ", tcp_conntrack_names[state]);
+	seq_printf(s, "%s ", tcp_conntrack_names[ct->proto.tcp.state]);
 }
 
 static unsigned int get_conntrack_index(const struct tcphdr *tcph)
-- 
2.1.4

