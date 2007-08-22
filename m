From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24] [NET] Cleanup: DIV_ROUND_UP
Date: Wed, 22 Aug 2007 13:48:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708221347010.16255@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1159792761-1187779694=:16255"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39066 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbXHVKsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 06:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1159792761-1187779694=:16255
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    6 +-----
 net/key/af_key.c      |   17 +++++------------
 2 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 10b2e39..bca4ee2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -646,11 +646,7 @@ static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb, unsigned
 		skb_shinfo(skb)->gso_size = 0;
 		skb_shinfo(skb)->gso_type = 0;
 	} else {
-		unsigned int factor;
-
-		factor = skb->len + (mss_now - 1);
-		factor /= mss_now;
-		skb_shinfo(skb)->gso_segs = factor;
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
 		skb_shinfo(skb)->gso_size = mss_now;
 		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
 	}
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5502df1..17b2a69 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -352,16 +352,14 @@ static int verify_address_len(void *p)
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		len  = sizeof(*sp) + sizeof(*sin) + (sizeof(uint64_t) - 1);
-		len /= sizeof(uint64_t);
+		len = DIV_ROUND_UP(sizeof(*sp) + sizeof(*sin), sizeof(uint64_t));
 		if (sp->sadb_address_len != len ||
 		    sp->sadb_address_prefixlen > 32)
 			return -EINVAL;
 		break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
-		len  = sizeof(*sp) + sizeof(*sin6) + (sizeof(uint64_t) - 1);
-		len /= sizeof(uint64_t);
+		len = DIV_ROUND_UP(sizeof(*sp) + sizeof(*sin6), sizeof(uint64_t));
 		if (sp->sadb_address_len != len ||
 		    sp->sadb_address_prefixlen > 128)
 			return -EINVAL;
@@ -386,14 +384,9 @@ static int verify_address_len(void *p)
 
 static inline int pfkey_sec_ctx_len(struct sadb_x_sec_ctx *sec_ctx)
 {
-	int len = 0;
-
-	len += sizeof(struct sadb_x_sec_ctx);
-	len += sec_ctx->sadb_x_ctx_len;
-	len += sizeof(uint64_t) - 1;
-	len /= sizeof(uint64_t);
-
-	return len;
+	return DIV_ROUND_UP(sizeof(struct sadb_x_sec_ctx) +
+			    sec_ctx->sadb_x_ctx_len,
+			    sizeof(uint64_t));
 }
 
 static inline int verify_sec_ctx_len(void *p)
-- 
1.5.0.6

---696243703-1159792761-1187779694=:16255--
