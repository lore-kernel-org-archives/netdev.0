From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/21] netfilter: nf_ct_expect: nf_ct_expect_insert() returns void
Date: Sun, 12 Feb 2017 20:42:46 +0100
Message-ID: <1486928573-24773-15-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Because nf_ct_expect_insert() always succeeds now, its return value can
be just void instead of int. And remove code that checks for its return
value.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index f8dbacf66795..e19a69787d99 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -353,7 +353,7 @@ void nf_ct_expect_put(struct nf_conntrack_expect *exp)
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_put);
 
-static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
+static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 {
 	struct nf_conn_help *master_help = nfct_help(exp->master);
 	struct nf_conntrack_helper *helper;
@@ -380,7 +380,6 @@ static int nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	add_timer(&exp->timeout);
 
 	NF_CT_STAT_INC(net, expect_create);
-	return 0;
 }
 
 /* Race with expectations being used means we could have none to find; OK. */
@@ -464,9 +463,8 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 	if (ret <= 0)
 		goto out;
 
-	ret = nf_ct_expect_insert(expect);
-	if (ret < 0)
-		goto out;
+	nf_ct_expect_insert(expect);
+
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 	nf_ct_expect_event_report(IPEXP_NEW, expect, portid, report);
 	return ret;
-- 
2.1.4

