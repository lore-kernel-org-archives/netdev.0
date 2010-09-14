From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/4] X.25 remove bkl in listen
Date: Wed, 15 Sep 2010 09:31:16 +1000
Message-ID: <1284507076.1742.51.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59587 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab0INXbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 19:31:21 -0400
Received: by vws3 with SMTP id 3so439029vws.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 16:31:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Listen updates socket values and needs lock_sock.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5e86d4e..f6a8f17 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -507,14 +507,14 @@ static int x25_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int rc = -EOPNOTSUPP;
 
-	lock_kernel();
+	lock_sock(sk);
 	if (sk->sk_state != TCP_LISTEN) {
 		memset(&x25_sk(sk)->dest_addr, 0, X25_ADDR_LEN);
 		sk->sk_max_ack_backlog = backlog;
 		sk->sk_state           = TCP_LISTEN;
 		rc = 0;
 	}
-	unlock_kernel();
+	release_sock(sk);
 
 	return rc;
 }
-- 
1.7.0.4



