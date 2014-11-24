From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/17] netfilter: nft_meta: add cgroup support
Date: Mon, 24 Nov 2014 14:27:46 +0100
Message-ID: <1416835674-11871-10-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44885 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932107AbaKXNZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:57 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ana Rey <anarey@gmail.com>

This allows you to filter traffic by process control group (cgroup).

Signed-off-by: Ana Rey <anarey@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_meta.c                 |    7 +++++++
 2 files changed, 9 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 16f62a5..832bc46 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -579,6 +579,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_CPU: cpu id through smp_processor_id()
  * @NFT_META_IIFGROUP: packet input interface group
  * @NFT_META_OIFGROUP: packet output interface group
+ * @NFT_META_CGROUP: socket control group (skb->sk->sk_classid)
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -604,6 +605,7 @@ enum nft_meta_keys {
 	NFT_META_CPU,
 	NFT_META_IIFGROUP,
 	NFT_META_OIFGROUP,
+	NFT_META_CGROUP,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 1e7c076..e99911e 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -165,6 +165,12 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 			goto err;
 		dest->data[0] = out->group;
 		break;
+	case NFT_META_CGROUP:
+		if (skb->sk == NULL)
+			break;
+
+		dest->data[0] = skb->sk->sk_classid;
+		break;
 	default:
 		WARN_ON(1);
 		goto err;
@@ -240,6 +246,7 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 	case NFT_META_CPU:
 	case NFT_META_IIFGROUP:
 	case NFT_META_OIFGROUP:
+	case NFT_META_CGROUP:
 		break;
 	default:
 		return -EOPNOTSUPP;
-- 
1.7.10.4
