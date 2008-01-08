From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: xfrm_state_clone() should be static, not exported
Date: Tue, 08 Jan 2008 09:00:20 +0100
Message-ID: <47832D94.3000302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040307020909010103000409"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48178 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYAHIA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 03:00:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040307020909010103000409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

xfrm_state_clone() is not used outside of net/xfrm/xfrm_state.c
There is no need to export it.

Spoted by sparse checker.
   CHECK   net/xfrm/xfrm_state.c
net/xfrm/xfrm_state.c:1103:19: warning: symbol 'xfrm_state_clone' was not 
declared. Should it be static?

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------040307020909010103000409
Content-Type: text/plain;
 name="xfrm_state.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_state.patch"

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 81b0fce..5fc8217 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1100,7 +1100,7 @@ out:
 EXPORT_SYMBOL(xfrm_state_add);
 
 #ifdef CONFIG_XFRM_MIGRATE
-struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
+static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 {
 	int err = -ENOMEM;
 	struct xfrm_state *x = xfrm_state_alloc();
@@ -1175,7 +1175,6 @@ struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	kfree(x);
 	return NULL;
 }
-EXPORT_SYMBOL(xfrm_state_clone);
 
 /* xfrm_state_lock is held */
 struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)

--------------040307020909010103000409--
