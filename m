From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH net-next] crypto: algif - use kmalloc instead of kzalloc
Date: Mon, 30 Mar 2015 14:25:44 -0700
Message-ID: <20150330212543.7179.25983.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16482 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbbC3V2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 17:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to use kzalloc to allocate sgls as the structure is initialized anyway.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 crypto/algif_skcipher.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 9492dd5..5fd631f 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -583,7 +583,7 @@ static int skcipher_recvmsg_async(struct socket *sock, struct msghdr *msg,
 			rsgl = &sreq->first_sgl;
 			list_add_tail(&rsgl->list, &sreq->list);
 		} else {
-			rsgl = kzalloc(sizeof(*rsgl), GFP_KERNEL);
+			rsgl = kmalloc(sizeof(*rsgl), GFP_KERNEL);
 			if (!rsgl) {
 				err = -ENOMEM;
 				goto free;
