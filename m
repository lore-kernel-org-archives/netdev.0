From: fgao@ikuai8.com
Subject: [PATCH net-next v2 1/1] net: sock: Use USEC_PER_SEC macro instead of literal 1000000
Date: Tue, 21 Feb 2017 17:09:19 +0800
Message-ID: <1487668159-4720-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, edumazet@google.com, soheil@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg320.qq.com ([14.17.32.29]:50946 "EHLO smtpbg320.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750954AbdBUJR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 04:17:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The USEC_PER_SEC is used once in sock_set_timeout as the max value of
tv_usec. But there are other similar codes which use the literal
1000000 in this file.
It is minor cleanup to keep consitent.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Use DIV_ROUND_UP, per Joe Perches
 v1: Initial version

 net/core/sock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 8b35debf..e2f7abd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -367,7 +367,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 	if (tv.tv_sec == 0 && tv.tv_usec == 0)
 		return 0;
 	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1))
-		*timeo_p = tv.tv_sec*HZ + (tv.tv_usec+(1000000/HZ-1))/(1000000/HZ);
+		*timeo_p = tv.tv_sec * HZ + DIV_ROUND_UP(tv.tv_usec, USEC_PER_SEC / HZ);
 	return 0;
 }
 
@@ -1145,7 +1145,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 			v.tm.tv_usec = 0;
 		} else {
 			v.tm.tv_sec = sk->sk_rcvtimeo / HZ;
-			v.tm.tv_usec = ((sk->sk_rcvtimeo % HZ) * 1000000) / HZ;
+			v.tm.tv_usec = ((sk->sk_rcvtimeo % HZ) * USEC_PER_SEC) / HZ;
 		}
 		break;
 
@@ -1156,7 +1156,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 			v.tm.tv_usec = 0;
 		} else {
 			v.tm.tv_sec = sk->sk_sndtimeo / HZ;
-			v.tm.tv_usec = ((sk->sk_sndtimeo % HZ) * 1000000) / HZ;
+			v.tm.tv_usec = ((sk->sk_sndtimeo % HZ) * USEC_PER_SEC) / HZ;
 		}
 		break;
 
-- 
1.9.1
