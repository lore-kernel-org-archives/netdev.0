From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netfilter: nf_tables: use _safe version of list_for_each
Date: Mon, 4 Nov 2013 15:58:56 +0300
Message-ID: <20131104125856.GB12213@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to use the _safe version of list_for_each_entry() here otherwise
we have a use after free bug.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 4811f76..a82667c 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -634,9 +634,9 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 
 static void nft_match_release(void)
 {
-	struct nft_xt *nft_match;
+	struct nft_xt *nft_match, *tmp;
 
-	list_for_each_entry(nft_match, &nft_match_list, head)
+	list_for_each_entry_safe(nft_match, tmp, &nft_match_list, head)
 		kfree(nft_match);
 }
 
@@ -705,9 +705,9 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 
 static void nft_target_release(void)
 {
-	struct nft_xt *nft_target;
+	struct nft_xt *nft_target, *tmp;
 
-	list_for_each_entry(nft_target, &nft_target_list, head)
+	list_for_each_entry_safe(nft_target, tmp, &nft_target_list, head)
 		kfree(nft_target);
 }
 
