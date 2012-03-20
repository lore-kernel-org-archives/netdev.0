From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] Fix pppol2tp getsockname()
Date: Tue, 20 Mar 2012 09:57:54 -0400
Message-ID: <20120320135754.GA30155@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:60104 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757979Ab2CTN5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 09:57:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing L2TP functionality, I came across a bug in getsockname().  The
IP address returned within the pppol2tp_addr's addr memember was not being
set to the IP  address in use.  This bug is caused by using inet_sk() on the
wrong socket (the L2TP socket rather than the underlying UDP socket), and was
likely introduced during the addition of L2TPv3 support.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/l2tp/l2tp_ppp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 96bc7a6..9b07191 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -915,7 +915,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		goto end_put_sess;
 	}
 
-	inet = inet_sk(sk);
+	inet = inet_sk(tunnel->sock);
 	if (tunnel->version == 2) {
 		struct sockaddr_pppol2tp sp;
 		len = sizeof(sp);
-- 
1.7.4.1
