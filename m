From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/15] tcp: Use cork flow info instead of rt->rt_dst in
 tcp_v4_get_peer()
Date: Sun, 08 May 2011 15:37:59 -0700 (PDT)
Message-ID: <20110508.153759.245415801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755900Ab1EHWib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 779B524C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 374de3c..2b65503 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1773,7 +1773,8 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 	struct inet_sock *inet = inet_sk(sk);
 	struct inet_peer *peer;
 
-	if (!rt || rt->rt_dst != inet->inet_daddr) {
+	if (!rt ||
+	    inet->cork.fl.u.ip4.daddr != inet->inet_daddr) {
 		peer = inet_getpeer_v4(inet->inet_daddr, 1);
 		*release_it = true;
 	} else {
-- 
1.7.5.1

