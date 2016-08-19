From: fgao@ikuai8.com
Subject: [PATCH 1/1] l2tp: Fix the connect status check in pppol2tp_getname
Date: Fri, 19 Aug 2016 13:36:23 +0800
Message-ID: <1471584983-18774-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: jchapman@katalix.com, davem@davemloft.net, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG1.QQ.COM ([183.60.61.196]:41918 "EHLO smtpbg1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755037AbcHSFgr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 01:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The sk->sk_state is bits flag, so need use bit operation check
instead of value check.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/l2tp/l2tp_ppp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d9560aa..232cb92 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -856,7 +856,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 	error = -ENOTCONN;
 	if (sk == NULL)
 		goto end;
-	if (sk->sk_state != PPPOX_CONNECTED)
+	if (!(sk->sk_state & PPPOX_CONNECTED))
 		goto end;
 
 	error = -EBADF;
-- 
1.9.1
