From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] inet_peer : group together avl_left, avl_right, v4daddr to speedup lookups on some CPUS
Date: Wed, 18 Oct 2006 09:38:38 +0200
Message-ID: <200610180938.39175.dada1@cosmosbay.com>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <20061016.223513.35356292.davem@davemloft.net> <200610171458.37636.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/ndNFplxJX3XyUB"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:11146 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932066AbWJRHij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 03:38:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <200610171458.37636.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_/ndNFplxJX3XyUB
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

Lot of routers still use CPUS with 32 bytes cache lines. (Intel PIII)
It make sense to make sure fields used at lookup time are in the same cache 
line, to reduce cache footprint and speedup lookups.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_/ndNFplxJX3XyUB
Content-Type: text/plain;
  charset="utf-8";
  name="inetpeer_speedup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="inetpeer_speedup.patch"

--- linux/include/net/inetpeer.h	2006-10-18 09:30:12.000000000 +0200
+++ linux-ed/include/net/inetpeer.h	2006-10-18 09:32:17.000000000 +0200
@@ -17,14 +17,15 @@
 
 struct inet_peer
 {
+	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer	*avl_left, *avl_right;
+	__u32			v4daddr;	/* peer's address */
+	__u16			avl_height;
+	__u16			ip_id_count;	/* IP ID for the next packet */
 	struct inet_peer	*unused_next, **unused_prevp;
 	__u32	dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
-	__u32			v4daddr;	/* peer's address */
-	__u16			avl_height;
-	__u16			ip_id_count;	/* IP ID for the next packet */
 	atomic_t		rid;		/* Frag reception counter */
 	__u32			tcp_ts;
 	unsigned long		tcp_ts_stamp;

--Boundary-00=_/ndNFplxJX3XyUB--
