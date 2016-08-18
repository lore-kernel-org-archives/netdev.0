From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: md5: remove tcp_md5_hash_header()
Date: Thu, 18 Aug 2016 09:49:55 -0700
Message-ID: <1471538995.29842.65.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34007 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbcHSJH6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 05:07:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so1183619pfb.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 02:07:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 19689e38eca5 ("tcp: md5: use kmalloc() backed scratch
areas") this function is no longer used.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |   17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 032a96d78c99..f1a9a0a8a1f3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3092,23 +3092,6 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 }
 EXPORT_SYMBOL(tcp_get_md5sig_pool);
 
-int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
-			const struct tcphdr *th)
-{
-	struct scatterlist sg;
-	struct tcphdr hdr;
-
-	/* We are not allowed to change tcphdr, make a local copy */
-	memcpy(&hdr, th, sizeof(hdr));
-	hdr.check = 0;
-
-	/* options aren't included in the hash */
-	sg_init_one(&sg, &hdr, sizeof(hdr));
-	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(hdr));
-	return crypto_ahash_update(hp->md5_req);
-}
-EXPORT_SYMBOL(tcp_md5_hash_header);
-
 int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 			  const struct sk_buff *skb, unsigned int header_len)
 {
