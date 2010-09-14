From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 4/4] X.25 remove bkl in connect
Date: Wed, 15 Sep 2010 09:32:03 +1000
Message-ID: <1284507123.1742.57.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59587 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138Ab0INXcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 19:32:08 -0400
Received: by mail-vw0-f46.google.com with SMTP id 3so439029vws.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 16:32:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connect already has socket locking.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index bd6fce3..ab959d0 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -751,7 +751,6 @@ static int x25_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct x25_route *rt;
 	int rc = 0;
 
-	lock_kernel();
 	lock_sock(sk);
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
 		sock->state = SS_CONNECTED;
@@ -829,7 +828,6 @@ out_put_route:
 	x25_route_put(rt);
 out:
 	release_sock(sk);
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.0.4



