From: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>
Subject: [PATCH net-next] TLS: Fix length check in do_tls_getsockopt_tx()
Date: Thu, 6 Jul 2017 00:56:36 -0400
Message-ID: <5b6ff892-fd27-94c6-045a-70c6ab721fb3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
        davejwatson@fb.com, aviadye@mellanox.com, ilyal@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36036 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdGFE4j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 00:56:39 -0400
Received: by mail-it0-f67.google.com with SMTP id k3so16559075ita.3
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 21:56:38 -0700 (PDT)
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

copy_to_user() copies the struct the pointer is pointing to, but the
length check compares against sizeof(pointer) and not sizeof(struct).
On 32-bit the size is probably the same, so it might have worked
accidentally.

Signed-off-by: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>
---
 net/tls/tls_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tls/tls_main.c b/net/tls/tls_main.c
index a03130a..60aff60 100644
--- a/net/tls/tls_main.c
+++ b/net/tls/tls_main.c
@@ -272,7 +272,7 @@ static int do_tls_getsockopt_tx(struct sock *sk, char __user *optval,
 		goto out;
 	}
 
-	if (len == sizeof(crypto_info)) {
+	if (len == sizeof(*crypto_info)) {
 		if (copy_to_user(optval, crypto_info, sizeof(*crypto_info)))
 			rc = -EFAULT;
 		goto out;
-- 
2.8.3
