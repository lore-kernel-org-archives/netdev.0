From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/6] xfrm: use memdup_user
Date: Fri, 23 Jun 2017 10:38:25 +0200
Message-ID: <1498207110-22520-2-git-send-email-steffen.klassert@secunet.com>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51098 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751231AbdFWIih (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:37 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fc3c5aa..5780cda 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2023,13 +2023,9 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	if (optlen <= 0 || optlen > PAGE_SIZE)
 		return -EMSGSIZE;
 
-	data = kmalloc(optlen, GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
-
-	err = -EFAULT;
-	if (copy_from_user(data, optval, optlen))
-		goto out;
+	data = memdup_user(optval, optlen);
+	if (IS_ERR(data))
+		return PTR_ERR(data);
 
 	err = -EINVAL;
 	rcu_read_lock();
@@ -2047,7 +2043,6 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 		err = 0;
 	}
 
-out:
 	kfree(data);
 	return err;
 }
-- 
2.7.4
