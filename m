From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net,stable 2/2] l2tp: Fix sendmsg() return value
Date: Wed, 12 Jun 2013 16:07:36 +0200
Message-ID: <20130612140736.GC3500@alphalink.fr>
References: <cover.1371044671.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39420 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751483Ab3FLOSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 10:18:15 -0400
Content-Disposition: inline
In-Reply-To: <cover.1371044671.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPPoL2TP sockets should comply with the standard send*() return values
(i.e. return number of bytes sent instead of 0 upon success).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 681c626..8dec687 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -358,7 +358,7 @@ static int pppol2tp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msgh
 	sock_put(ps->tunnel_sock);
 	sock_put(sk);
 
-	return error;
+	return total_len;
 
 error_put_sess_tun:
 	sock_put(ps->tunnel_sock);
-- 
1.7.10.4
