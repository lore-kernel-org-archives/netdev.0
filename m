From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 1/2] l2tp: don't mask errors in pppol2tp_setsockopt()
Date: Thu, 6 Apr 2017 18:31:20 +0200
Message-ID: <8644b1d1debc67a804f01cee42adf4b9f64222b2.1491495941.git.g.nault@alphalink.fr>
References: <cover.1491495941.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60552 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbdDFQb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:31:26 -0400
Content-Disposition: inline
In-Reply-To: <cover.1491495941.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pppol2tp_setsockopt() unconditionally overwrites the error value
returned by pppol2tp_tunnel_setsockopt() or
pppol2tp_session_setsockopt(), thus hiding errors from userspace.

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 861b255a2d51..973a9185b276 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1383,8 +1383,6 @@ static int pppol2tp_setsockopt(struct socket *sock, int level, int optname,
 	} else
 		err = pppol2tp_session_setsockopt(sk, session, optname, val);
 
-	err = 0;
-
 end_put_sess:
 	sock_put(sk);
 end:
-- 
2.11.0
