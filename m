From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: rxrpc: rxkad: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 11:18:09 -0500
Message-ID: <20171024161809.GA29118@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use BUG_ON instead of if condition followed by BUG.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/rxrpc/rxkad.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index c38b3a1..80bad60 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -70,9 +70,8 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 		goto error;
 	}
 
-	if (crypto_skcipher_setkey(ci, token->kad->session_key,
-				   sizeof(token->kad->session_key)) < 0)
-		BUG();
+	BUG_ON(crypto_skcipher_setkey(ci, token->kad->session_key,
+				   sizeof(token->kad->session_key)) < 0);
 
 	switch (conn->params.security_level) {
 	case RXRPC_SECURITY_PLAIN:
@@ -570,8 +569,7 @@ static void rxkad_locate_data_1(struct rxrpc_call *call, struct sk_buff *skb,
 {
 	struct rxkad_level1_hdr sechdr;
 
-	if (skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0)
-		BUG();
+	BUG_ON(skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0);
 	*_offset += sizeof(sechdr);
 	*_len = ntohl(sechdr.data_size) & 0xffff;
 }
@@ -584,8 +582,7 @@ static void rxkad_locate_data_2(struct rxrpc_call *call, struct sk_buff *skb,
 {
 	struct rxkad_level2_hdr sechdr;
 
-	if (skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0)
-		BUG();
+	BUG_ON(skb_copy_bits(skb, *_offset, &sechdr, sizeof(sechdr)) < 0);
 	*_offset += sizeof(sechdr);
 	*_len = ntohl(sechdr.data_size) & 0xffff;
 }
@@ -1022,9 +1019,8 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 	ASSERT(rxkad_ci != NULL);
 
 	mutex_lock(&rxkad_ci_mutex);
-	if (crypto_skcipher_setkey(rxkad_ci, session_key->x,
-				   sizeof(*session_key)) < 0)
-		BUG();
+	BUG_ON(crypto_skcipher_setkey(rxkad_ci, session_key->x,
+				   sizeof(*session_key)) < 0);
 
 	memcpy(&iv, session_key, sizeof(iv));
 
@@ -1066,8 +1062,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	if (skb_copy_bits(skb, sizeof(struct rxrpc_wire_header),
 			  &response, sizeof(response)) < 0)
 		goto protocol_error;
-	if (!pskb_pull(skb, sizeof(response)))
-		BUG();
+
+	BUG_ON(!pskb_pull(skb, sizeof(response)));
 
 	version = ntohl(response.version);
 	ticket_len = ntohl(response.ticket_len);
-- 
2.7.4
