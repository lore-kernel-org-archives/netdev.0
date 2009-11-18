From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/16] drivers/net/pppol2tp.c: remove exceptional & on function
 name
Date: Wed, 18 Nov 2009 19:22:44 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181922240.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	arnd@arndb.de, joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:56281 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176AbZKRSWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:22:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/pppol2tp.c              |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 849cc9c..8dcc26f 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1537,7 +1537,7 @@ static struct sock *pppol2tp_prepare_tunnel_socket(struct net *net,
 	 * if the tunnel socket goes away.
 	 */
 	tunnel->old_sk_destruct = sk->sk_destruct;
-	sk->sk_destruct = &pppol2tp_tunnel_destruct;
+	sk->sk_destruct = pppol2tp_tunnel_destruct;
 
 	tunnel->sock = sk;
 	sk->sk_allocation = GFP_ATOMIC;
