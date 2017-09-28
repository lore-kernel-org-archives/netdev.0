From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: fix __percpu annotation
Date: Thu, 28 Sep 2017 17:57:58 +0200
Message-ID: <1e69021734ef43406df65571b9fa97884831825d.1506613995.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <gfree.wind@vip.163.com>,
        Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55043 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdI1P6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:58:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move sparse annotation right after pointer type.

Fixes sparse warning:
    drivers/net/ppp/ppp_generic.c:1422:13: warning: incorrect type in initializer (different address spaces)
    drivers/net/ppp/ppp_generic.c:1422:13:    expected void const [noderef] <asn:3>*__vpp_verify
    drivers/net/ppp/ppp_generic.c:1422:13:    got int *<noident>
    ...

Fixes: e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp devices")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index a404552555d4..c3f77e3b7819 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -120,7 +120,7 @@ struct ppp {
 	int		n_channels;	/* how many channels are attached 54 */
 	spinlock_t	rlock;		/* lock for receive side 58 */
 	spinlock_t	wlock;		/* lock for transmit side 5c */
-	int		*xmit_recursion __percpu; /* xmit recursion detect */
+	int __percpu	*xmit_recursion; /* xmit recursion detect */
 	int		mru;		/* max receive unit 60 */
 	unsigned int	flags;		/* control bits 64 */
 	unsigned int	xstate;		/* transmit state bits 68 */
-- 
2.14.2
