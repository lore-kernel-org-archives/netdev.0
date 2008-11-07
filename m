From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] af_key: mark policy as dead before destroying
Date: Fri, 7 Nov 2008 05:49:54 +0300
Message-ID: <20081107024954.GA20157@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:18024 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbYKGCqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 21:46:35 -0500
Received: by nf-out-0910.google.com with SMTP id d3so514156nfc.21
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 18:46:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_policy_destroy() will oops if not dead policy is passed to it.
On error path in pfkey_compile_policy() exactly this happens.

Oopsable for CAP_NET_ADMIN owners.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/key/af_key.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3189,6 +3189,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 	return xp;
 
 out:
+	xp->walk.dead = 1;
 	xfrm_policy_destroy(xp);
 	return NULL;
 }
