From: Chuck Ebbert <cebbert@redhat.com>
Subject: [patch] xfrm: spin_lock() should be spin_unlock() in xfrm_state.c
Date: Thu, 26 Mar 2009 18:58:45 -0400
Message-ID: <20090326185845.2c5719b4@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54059 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761524AbZCZXBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 19:01:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm: spin_lock() should be spin_unlock() in xfrm_state.c

spin_lock() should be spin_unlock() in xfrm_state_walk_done().

caused by:
commit 12a169e7d8f4b1c95252d8b04ed0f1033ed7cfe2
"ipsec: Put dumpers on the dump list"

Reported-by: Marc Milgram <mmilgram@redhat.com>
Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
---

--- linux-2.6.29.noarch.orig/net/xfrm/xfrm_state.c
+++ linux-2.6.29.noarch/net/xfrm/xfrm_state.c
@@ -1615,7 +1615,7 @@ void xfrm_state_walk_done(struct xfrm_st
 
 	spin_lock_bh(&xfrm_state_lock);
 	list_del(&walk->all);
-	spin_lock_bh(&xfrm_state_lock);
+	spin_unlock_bh(&xfrm_state_lock);
 }
 EXPORT_SYMBOL(xfrm_state_walk_done);
 
