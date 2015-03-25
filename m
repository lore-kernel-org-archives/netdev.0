From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH net-next] crypto: algif - fix warn: unsigned 'used' is never
 less than zero
Date: Wed, 25 Mar 2015 07:29:19 -0700
Message-ID: <20150325142919.4229.90027.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change type from unsigned long to int to fix an issue reported by kbuild robot:
crypto/algif_skcipher.c:596 skcipher_recvmsg_async() warn: unsigned 'used' is
never less than zero.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/algif_skcipher.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 8276f21..60496d4 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -537,7 +537,7 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 
 	while (iov_iter_count(&msg->msg_iter)) {
 		struct skcipher_async_rsgl *rsgl;
-		unsigned long used;
+		int used;
 
 		if (!ctx->used) {
 			err = skcipher_wait_for_data(sk, flags);
