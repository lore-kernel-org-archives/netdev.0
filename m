From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] net: Reexport sock_alloc_send_pskb
Date: Wed, 04 Feb 2009 21:49:24 +1100
Message-ID: <E1LUfJs-0005ZH-1U@gondolin.me.apana.org.au>
References: <20090204104825.GA21257@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59762 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752305AbZBDKt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 05:49:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: Reexport sock_alloc_send_pskb

The function sock_alloc_send_pskb is completely useless if not
exported since most of the code in it won't be used as is.  In
fact, this code has already been duplicated in the tun driver.

Now that we need accounting in the tun driver, we can in fact
use this function as is.  So this patch marks it for export again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/sock.h |    5 +++++
 net/core/sock.c    |    8 ++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5a3a151..c047def 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -945,6 +945,11 @@ extern struct sk_buff 		*sock_alloc_send_skb(struct sock *sk,
 						     unsigned long size,
 						     int noblock,
 						     int *errcode);
+extern struct sk_buff 		*sock_alloc_send_pskb(struct sock *sk,
+						      unsigned long header_len,
+						      unsigned long data_len,
+						      int noblock,
+						      int *errcode);
 extern void *sock_kmalloc(struct sock *sk, int size,
 			  gfp_t priority);
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
diff --git a/net/core/sock.c b/net/core/sock.c
index f3a0d08..c64996f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1254,10 +1254,9 @@ static long sock_wait_for_wmem(struct sock * sk, long timeo)
  *	Generic send/receive buffer handlers
  */
 
-static struct sk_buff *sock_alloc_send_pskb(struct sock *sk,
-					    unsigned long header_len,
-					    unsigned long data_len,
-					    int noblock, int *errcode)
+struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
+				     unsigned long data_len, int noblock,
+				     int *errcode)
 {
 	struct sk_buff *skb;
 	gfp_t gfp_mask;
@@ -1337,6 +1336,7 @@ failure:
 	*errcode = err;
 	return NULL;
 }
+EXPORT_SYMBOL(sock_alloc_send_pskb);
 
 struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 				    int noblock, int *errcode)
