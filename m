From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] af_key: fix info leaks in notify messages
Date: Wed, 26 Jun 2013 23:52:30 +0200
Message-ID: <1372283550-29911-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:45297 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab3FZVxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 17:53:15 -0400
Received: by mail-bk0-f47.google.com with SMTP id jg1so5120239bkc.20
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 14:53:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

key_notify_sa_flush() and key_notify_policy_flush() miss to initialize
the sadb_msg_reserved member of the broadcasted message and thereby
leak 2 bytes of heap memory to listeners. Fix that.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/key/af_key.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c5fbd75..9da8620 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1710,6 +1710,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+	hdr->sadb_msg_reserved = 0;
 
 	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 
@@ -2699,6 +2700,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+	hdr->sadb_msg_reserved = 0;
 	pfkey_broadcast(skb_out, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 	return 0;
 
-- 
1.7.10.4
