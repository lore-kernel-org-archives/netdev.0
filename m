From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] sctp: fix crypto_alloc_hash() error check
Date: Mon, 27 Nov 2006 13:57:43 +0900
Message-ID: <20061127045743.GC1231@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.199]:12508 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1756834AbWK0FEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 00:04:52 -0500
Received: by nz-out-0102.google.com with SMTP id s1so614103nze
        for <netdev@vger.kernel.org>; Sun, 26 Nov 2006 21:04:52 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of crypto_alloc_hash() should be checked by
IS_ERR().

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 net/sctp/socket.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: work-fault-inject/net/sctp/socket.c
===================================================================
--- work-fault-inject.orig/net/sctp/socket.c
+++ work-fault-inject/net/sctp/socket.c
@@ -4885,8 +4885,8 @@ int sctp_inet_listen(struct socket *sock
 	/* Allocate HMAC for generating cookie. */
 	if (sctp_hmac_alg) {
 		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
-		if (!tfm) {
-			err = -ENOSYS;
+		if (IS_ERR(tfm)) {
+			err = PTR_ERR(tfm);
 			goto out;
 		}
 	}
