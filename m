From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] inetpeer: remove dead code
Date: Sun, 23 Aug 2015 08:21:22 -0600
Message-ID: <1440339682-15934-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:32786 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbbHWOW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 10:22:28 -0400
Received: by iods203 with SMTP id s203so124364420iod.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 07:22:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove various inlined functions not referenced in the kernel.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inetpeer.h | 67 --------------------------------------------------
 1 file changed, 67 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index d5332ddcea3f..002f0bd27001 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -65,71 +65,12 @@ struct inet_peer_base {
 	int			total;
 };
 
-#define INETPEER_BASE_BIT	0x1UL
-
-static inline struct inet_peer *inetpeer_ptr(unsigned long val)
-{
-	BUG_ON(val & INETPEER_BASE_BIT);
-	return (struct inet_peer *) val;
-}
-
-static inline struct inet_peer_base *inetpeer_base_ptr(unsigned long val)
-{
-	if (!(val & INETPEER_BASE_BIT))
-		return NULL;
-	val &= ~INETPEER_BASE_BIT;
-	return (struct inet_peer_base *) val;
-}
-
-static inline bool inetpeer_ptr_is_peer(unsigned long val)
-{
-	return !(val & INETPEER_BASE_BIT);
-}
-
-static inline void __inetpeer_ptr_set_peer(unsigned long *val, struct inet_peer *peer)
-{
-	/* This implicitly clears INETPEER_BASE_BIT */
-	*val = (unsigned long) peer;
-}
-
-static inline bool inetpeer_ptr_set_peer(unsigned long *ptr, struct inet_peer *peer)
-{
-	unsigned long val = (unsigned long) peer;
-	unsigned long orig = *ptr;
-
-	if (!(orig & INETPEER_BASE_BIT) ||
-	    cmpxchg(ptr, orig, val) != orig)
-		return false;
-	return true;
-}
-
-static inline void inetpeer_init_ptr(unsigned long *ptr, struct inet_peer_base *base)
-{
-	*ptr = (unsigned long) base | INETPEER_BASE_BIT;
-}
-
-static inline void inetpeer_transfer_peer(unsigned long *to, unsigned long *from)
-{
-	unsigned long val = *from;
-
-	*to = val;
-	if (inetpeer_ptr_is_peer(val)) {
-		struct inet_peer *peer = inetpeer_ptr(val);
-		atomic_inc(&peer->refcnt);
-	}
-}
-
 void inet_peer_base_init(struct inet_peer_base *);
 
 void inet_initpeers(void) __init;
 
 #define INETPEER_METRICS_NEW	(~(u32) 0)
 
-static inline bool inet_metrics_new(const struct inet_peer *p)
-{
-	return p->metrics[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
-}
-
 /* can be called with or without local BH being disabled */
 struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 			       const struct inetpeer_addr *daddr,
@@ -163,12 +104,4 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
 void inetpeer_invalidate_tree(struct inet_peer_base *);
 
-/*
- * temporary check to make sure we dont access rid, tcp_ts,
- * tcp_ts_stamp if no refcount is taken on inet_peer
- */
-static inline void inet_peer_refcheck(const struct inet_peer *p)
-{
-	WARN_ON_ONCE(atomic_read(&p->refcnt) <= 0);
-}
 #endif /* _NET_INETPEER_H */
-- 
2.3.2 (Apple Git-55)
