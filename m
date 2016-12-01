From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] xfrm_user: fix return value from xfrm_user_rcv_msg
Date: Thu, 1 Dec 2016 12:44:50 +0100
Message-ID: <1480592692-3653-2-git-send-email-steffen.klassert@secunet.com>
References: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50002 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcLALpC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 06:45:02 -0500
In-Reply-To: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zhao <yi.zhao@windriver.com>

It doesn't support to run 32bit 'ip' to set xfrm objdect on 64bit host.
But the return value is unknown for user program:

ip xfrm policy list
RTNETLINK answers: Unknown error 524

Replace ENOTSUPP with EOPNOTSUPP:

ip xfrm policy list
RTNETLINK answers: Operation not supported

Signed-off-by: Yi Zhao <yi.zhao@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0889209..671a1d0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2450,7 +2450,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 #ifdef CONFIG_COMPAT
 	if (in_compat_syscall())
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 #endif
 
 	type = nlh->nlmsg_type;
-- 
1.9.1
