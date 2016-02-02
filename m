From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] netfilter: nft_ct: define nft_ct_get_eval_counter() only when needed
Date: Mon,  1 Feb 2016 20:30:57 -0600
Message-ID: <1454380257-27195-1-git-send-email-ebiggers3@gmail.com>
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers3@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This eliminates an "unused function" compiler warning when
CONFIG_NF_CONNTRACK_LABELS is not defined.

Signed-off-by: Eric Biggers <ebiggers3@gmail.com>
---
 net/netfilter/nft_ct.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index a0eb216..3cd6b5b 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -31,6 +31,7 @@ struct nft_ct {
 	};
 };
 
+#ifdef CONFIG_NF_CONNTRACK_LABELS
 static u64 nft_ct_get_eval_counter(const struct nf_conn_counter *c,
 				   enum nft_ct_keys k,
 				   enum ip_conntrack_dir d)
@@ -42,6 +43,7 @@ static u64 nft_ct_get_eval_counter(const struct nf_conn_counter *c,
 	return nft_ct_get_eval_counter(c, k, IP_CT_DIR_ORIGINAL) +
 	       nft_ct_get_eval_counter(c, k, IP_CT_DIR_REPLY);
 }
+#endif
 
 static void nft_ct_get_eval(const struct nft_expr *expr,
 			    struct nft_regs *regs,
-- 
2.7.0
