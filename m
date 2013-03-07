From: pablo@netfilter.org
Subject: [PATCH 1/3] netfilter: nf_ct_helper: Fix logging for dropped packets
Date: Thu,  7 Mar 2013 12:00:00 +0100
Message-ID: <1362654002-4405-2-git-send-email-pablo@netfilter.org>
References: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1362654002-4405-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

Update nf_ct_helper_log to emit args along with the format.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 013cdf6..bb4188f 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -341,6 +341,13 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 {
 	const struct nf_conn_help *help;
 	const struct nf_conntrack_helper *helper;
+	struct va_format vaf;
+	va_list args;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
 
 	/* Called from the helper function, this call never fails */
 	help = nfct_help(ct);
@@ -349,7 +356,9 @@ void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
 	helper = rcu_dereference(help->helper);
 
 	nf_log_packet(nf_ct_l3num(ct), 0, skb, NULL, NULL, NULL,
-		      "nf_ct_%s: dropping packet: %s ", helper->name, fmt);
+		      "nf_ct_%s: dropping packet: %pV ", helper->name, &vaf);
+
+	va_end(args);
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_log);
 
-- 
1.7.10.4

