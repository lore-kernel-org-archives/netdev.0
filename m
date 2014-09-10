From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/25] netfilter: nf_tables: add devgroup support in meta expresion
Date: Wed, 10 Sep 2014 17:10:33 +0200
Message-ID: <1410361842-4656-17-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ana Rey <anarey@gmail.com>

Add devgroup support to let us match device group of a packets incoming
or outgoing interface.

Signed-off-by: Ana Rey <anarey@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    4 ++++
 net/netfilter/nft_meta.c                 |   12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index c9b6f00..c000947 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -573,6 +573,8 @@ enum nft_exthdr_attributes {
  * @NFT_META_BRI_OIFNAME: packet output bridge interface name
  * @NFT_META_PKTTYPE: packet type (skb->pkt_type), special handling for loopback
  * @NFT_META_CPU: cpu id through smp_processor_id()
+ * @NFT_META_IIFGROUP: packet input interface group
+ * @NFT_META_OIFGROUP: packet output interface group
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -596,6 +598,8 @@ enum nft_meta_keys {
 	NFT_META_BRI_OIFNAME,
 	NFT_META_PKTTYPE,
 	NFT_META_CPU,
+	NFT_META_IIFGROUP,
+	NFT_META_OIFGROUP,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 843e099..1e7c076 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -155,6 +155,16 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 	case NFT_META_CPU:
 		dest->data[0] = smp_processor_id();
 		break;
+	case NFT_META_IIFGROUP:
+		if (in == NULL)
+			goto err;
+		dest->data[0] = in->group;
+		break;
+	case NFT_META_OIFGROUP:
+		if (out == NULL)
+			goto err;
+		dest->data[0] = out->group;
+		break;
 	default:
 		WARN_ON(1);
 		goto err;
@@ -228,6 +238,8 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 #endif
 	case NFT_META_PKTTYPE:
 	case NFT_META_CPU:
+	case NFT_META_IIFGROUP:
+	case NFT_META_OIFGROUP:
 		break;
 	default:
 		return -EOPNOTSUPP;
-- 
1.7.10.4

