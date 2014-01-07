From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: only warn once on wrong seqadj usage
Date: Tue,  7 Jan 2014 23:13:39 +0100
Message-ID: <1389132819-9697-3-git-send-email-pablo@netfilter.org>
References: <1389132819-9697-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389132819-9697-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>

Avoid potentially spamming the kernel log with WARN splash messages
when catching wrong usage of seqadj, by simply using WARN_ONCE.

This is a followup to commit db12cf274353 (netfilter: WARN about
wrong usage of sequence number adjustments)

Suggested-by: Flavio Leitner <fbl@redhat.com>
Suggested-by: Daniel Borkmann <dborkman@redhat.com>
Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_seqadj.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index b2d38da..f6e2ae9 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -37,7 +37,7 @@ int nf_ct_seqadj_set(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 		return 0;
 
 	if (unlikely(!seqadj)) {
-		WARN(1, "Wrong seqadj usage, missing nfct_seqadj_ext_add()\n");
+		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
 		return 0;
 	}
 
-- 
1.7.10.4

