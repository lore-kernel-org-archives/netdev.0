From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] rxrpc: key: use BUG_ON instead of if condition followed by
 BUG
Date: Tue, 24 Oct 2017 11:24:27 -0500
Message-ID: <20171024162427.GA29478@embeddedor.com>
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
 net/rxrpc/key.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index e7f6b88..b7cc1b1 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -851,8 +851,7 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 		return PTR_ERR(ci);
 	}
 
-	if (crypto_skcipher_setkey(ci, prep->data, 8) < 0)
-		BUG();
+	BUG_ON(crypto_skcipher_setkey(ci, prep->data, 8) < 0);
 
 	prep->payload.data[0] = ci;
 	_leave(" = 0");
-- 
2.7.4
