From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 4/4] X25: Remove bkl in sockopts
Date: Mon, 17 May 2010 19:00:35 +1000
Message-ID: <1274086835.4104.55.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:34564 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab0EQJAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 05:00:41 -0400
Received: by pxi5 with SMTP id 5so2420744pxi.19
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 02:00:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Removes the BKL in x25 setsock and getsockopts.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index e5c1e32..5e86d4e 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -453,7 +453,6 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int rc = -ENOPROTOOPT;
 
-	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -471,7 +470,6 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 		clear_bit(X25_Q_BIT_FLAG, &x25_sk(sk)->flags);
 	rc = 0;
 out:
-	unlock_kernel();
 	return rc;
 }
 
@@ -481,7 +479,6 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int val, len, rc = -ENOPROTOOPT;
 
-	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -502,7 +499,6 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	val = test_bit(X25_Q_BIT_FLAG, &x25_sk(sk)->flags);
 	rc = copy_to_user(optval, &val, len) ? -EFAULT : 0;
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.5.6.5


