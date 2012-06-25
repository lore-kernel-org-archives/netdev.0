From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: struct sock cleanups
Date: Mon, 25 Jun 2012 08:22:49 +0200
Message-ID: <1340605369.10893.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56870 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab2FYGXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:23:41 -0400
Received: by eaak11 with SMTP id k11so1044810eaa.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 23:23:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add missing kernel doc for sk_rx_dst

Move sk_rx_dst to avoid two 32bit holes on 64bit arches

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 87b424a..d9b558a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -198,6 +198,7 @@ struct cg_proto;
   *	@sk_lock:	synchronizer
   *	@sk_rcvbuf: size of receive buffer in bytes
   *	@sk_wq: sock wait queue and async head
+  *	@sk_rx_dst: receive input route used by early tcp demux
   *	@sk_dst_cache: destination cache
   *	@sk_dst_lock: destination cache lock
   *	@sk_policy: flow policy
@@ -317,9 +318,9 @@ struct sock {
 	struct xfrm_policy	*sk_policy[2];
 #endif
 	unsigned long 		sk_flags;
+	struct dst_entry	*sk_rx_dst;
 	struct dst_entry	*sk_dst_cache;
 	spinlock_t		sk_dst_lock;
-	struct dst_entry	*sk_rx_dst;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
