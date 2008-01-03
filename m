From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: Do not define km_migrate() if !CONFIG_XFRM_MIGRATE
Date: Thu, 3 Jan 2008 18:24:49 +0100
Message-ID: <20080103182449.ee02958e.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:55577 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbYACRYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 12:24:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In include/net/xfrm.h we find :

#ifdef CONFIG_XFRM_MIGRATE
extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
                      struct xfrm_migrate *m, int num_bundles);
...
#endif

We can also guard the function body itself in net/xfrm/xfrm_state.c
with same condition.

(Problem spoted by sparse checker)
make C=2 net/xfrm/xfrm_state.o
...
net/xfrm/xfrm_state.c:1765:5: warning: symbol 'km_migrate' was not declared. Should it be static?
...

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4dec655..65f5ea4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1762,6 +1762,7 @@ void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
 }
 EXPORT_SYMBOL(km_policy_expired);
 
+#ifdef CONFIG_XFRM_MIGRATE
 int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	       struct xfrm_migrate *m, int num_migrate)
 {
@@ -1781,6 +1782,7 @@ int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 	return err;
 }
 EXPORT_SYMBOL(km_migrate);
+#endif
 
 int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
 {
