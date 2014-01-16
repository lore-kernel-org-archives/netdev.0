From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: nft_ct: fix compilation warning if NF_CONNTRACK_MARK is not set
Date: Thu, 16 Jan 2014 10:04:53 +0100
Message-ID: <1389863093-4530-4-git-send-email-pablo@netfilter.org>
References: <1389863093-4530-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389863093-4530-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kristian Evensen <kristian.evensen@gmail.com>

net/netfilter/nft_ct.c: In function 'nft_ct_set_eval':
net/netfilter/nft_ct.c:136:6: warning: unused variable 'value' [-Wunused-variable]

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index c7c1285..917052e 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -133,7 +133,9 @@ static void nft_ct_set_eval(const struct nft_expr *expr,
 {
 	const struct nft_ct *priv = nft_expr_priv(expr);
 	struct sk_buff *skb = pkt->skb;
+#ifdef CONFIG_NF_CONNTRACK_MARK
 	u32 value = data[priv->sreg].data[0];
+#endif
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 
-- 
1.7.10.4

