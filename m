From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 3/4] X.25 remove bkl in accept
Date: Wed, 15 Sep 2010 09:31:50 +1000
Message-ID: <1284507110.1742.56.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59587 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138Ab0INXb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 19:31:56 -0400
Received: by mail-vw0-f46.google.com with SMTP id 3so439029vws.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 16:31:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accept already has socket locking.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index ab959d0..4ebde0d 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -867,7 +867,6 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int rc = -EINVAL;
 
-	lock_kernel();
 	if (!sk || sk->sk_state != TCP_LISTEN)
 		goto out;
 
@@ -895,7 +894,6 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 out2:
 	release_sock(sk);
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.0.4



