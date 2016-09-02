From: fgao@ikuai8.com
Subject: [PATCH 2/2 nf-next] netfilter: seqadj: print the warning log when fail to add seqadj extension
Date: Fri,  2 Sep 2016 09:50:36 +0800
Message-ID: <1472781036-13547-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Print the warning log when fail to add seqadj extension like
nf_ct_acct_ext_add does. It could be helpful to find the problem.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 include/net/netfilter/nf_conntrack_seqadj.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_conntrack_seqadj.h b/include/net/netfilter/nf_conntrack_seqadj.h
index 4b33629..d548b9c 100644
--- a/include/net/netfilter/nf_conntrack_seqadj.h
+++ b/include/net/netfilter/nf_conntrack_seqadj.h
@@ -27,7 +27,13 @@ static inline struct nf_conn_seqadj *nfct_seqadj(const struct nf_conn *ct)
 
 static inline struct nf_conn_seqadj *nfct_seqadj_ext_add(struct nf_conn *ct)
 {
-	return nf_ct_ext_add(ct, NF_CT_EXT_SEQADJ, GFP_ATOMIC);
+	struct nf_conn_seqadj *seqadj = nf_ct_ext_add(ct, NF_CT_EXT_SEQADJ,
+						      GFP_ATOMIC);
+
+	if (!seqadj)
+		pr_warn("failed to add seqadj extension area");
+
+	return seqadj;
 }
 
 int nf_ct_seqadj_init(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-- 
1.9.1


