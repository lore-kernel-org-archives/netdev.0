From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/25] netfilter: nft_meta: Add cpu attribute support
Date: Wed, 10 Sep 2014 17:10:20 +0200
Message-ID: <1410361842-4656-4-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ana Rey <anarey@gmail.com>

Add cpu support to meta expresion.

This allows you to match packets with cpu number.

Signed-off-by: Ana Rey <anarey@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_meta.c                 |    5 +++++
 2 files changed, 7 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 98144cd..c9b6f00 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -572,6 +572,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_BRI_IIFNAME: packet input bridge interface name
  * @NFT_META_BRI_OIFNAME: packet output bridge interface name
  * @NFT_META_PKTTYPE: packet type (skb->pkt_type), special handling for loopback
+ * @NFT_META_CPU: cpu id through smp_processor_id()
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -594,6 +595,7 @@ enum nft_meta_keys {
 	NFT_META_BRI_IIFNAME,
 	NFT_META_BRI_OIFNAME,
 	NFT_META_PKTTYPE,
+	NFT_META_CPU,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 4f2862f..843e099 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -17,6 +17,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/smp.h>
 #include <net/dst.h>
 #include <net/sock.h>
 #include <net/tcp_states.h> /* for TCP_TIME_WAIT */
@@ -151,6 +152,9 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			goto err;
 		}
 		break;
+	case NFT_META_CPU:
+		dest->data[0] = smp_processor_id();
+		break;
 	default:
 		WARN_ON(1);
 		goto err;
@@ -223,6 +227,7 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	case NFT_META_SECMARK:
 #endif
 	case NFT_META_PKTTYPE:
+	case NFT_META_CPU:
 		break;
 	default:
 		return -EOPNOTSUPP;
-- 
1.7.10.4

