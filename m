From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/23] netfilter: nf_tables: add nfproto support to meta expression
Date: Fri, 10 Jan 2014 01:35:25 +0100
Message-ID: <1389314142-17969-7-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Needed by multi-family tables to distinguish IPv4 and IPv6 packets.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_meta.c                 |    4 ++++
 2 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index aa86a152..10afbfc 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -531,6 +531,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_NFTRACE: packet nftrace bit
  * @NFT_META_RTCLASSID: realm value of packet's route (skb->dst->tclassid)
  * @NFT_META_SECMARK: packet secmark (skb->secmark)
+ * @NFT_META_NFPROTO: netfilter protocol
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -548,6 +549,7 @@ enum nft_meta_keys {
 	NFT_META_NFTRACE,
 	NFT_META_RTCLASSID,
 	NFT_META_SECMARK,
+	NFT_META_NFPROTO,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 1ceaaa6..999d046 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -43,6 +43,9 @@ static void nft_meta_get_eval(const struct nft_expr *expr,
 	case NFT_META_PROTOCOL:
 		*(__be16 *)dest->data = skb->protocol;
 		break;
+	case NFT_META_NFPROTO:
+		dest->data[0] = pkt->ops->pf;
+		break;
 	case NFT_META_PRIORITY:
 		dest->data[0] = skb->priority;
 		break;
@@ -181,6 +184,7 @@ static int nft_meta_init_validate_get(uint32_t key)
 	switch (key) {
 	case NFT_META_LEN:
 	case NFT_META_PROTOCOL:
+	case NFT_META_NFPROTO:
 	case NFT_META_PRIORITY:
 	case NFT_META_MARK:
 	case NFT_META_IIF:
-- 
1.7.10.4

