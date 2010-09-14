From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 2/4] X.25 remove bkl in bind
Date: Wed, 15 Sep 2010 09:31:38 +1000
Message-ID: <1284507098.1742.55.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59587 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab0INXbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 19:31:44 -0400
Received: by mail-vw0-f46.google.com with SMTP id 3so439029vws.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 16:31:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accept updates socket values in 3 lines so wrapped with lock_sock.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index f6a8f17..bd6fce3 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -688,7 +688,6 @@ static int x25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
 	int len, i, rc = 0;
 
-	lock_kernel();
 	if (!sock_flag(sk, SOCK_ZAPPED) ||
 	    addr_len != sizeof(struct sockaddr_x25) ||
 	    addr->sx25_family != AF_X25) {
@@ -704,12 +703,13 @@ static int x25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		}
 	}
 
+	lock_sock(sk);
 	x25_sk(sk)->source_addr = addr->sx25_addr;
 	x25_insert_socket(sk);
 	sock_reset_flag(sk, SOCK_ZAPPED);
+	release_sock(sk);
 	SOCK_DEBUG(sk, "x25_bind: socket is bound\n");
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.0.4



