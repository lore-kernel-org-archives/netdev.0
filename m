From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH] [IPv6] Do not update all temporary address, only the one
	with the same prefix
Date: Tue, 18 Mar 2008 13:47:36 +0100
Message-ID: <20080318124736.GC6977@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:36753 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbYCRMrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 08:47:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the temporary address with the same prefix should be updated

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

---
I was wondering why my temporary address would always become deprecated,
the reason was that my ISP is advertizing two prefixes, one is with
preferred lifetime = 0, the other isn't.
As soon as an RA came, it updated the lifetime of both adresses to 0.

The check for the prefix_len isn't necessary since it should always be 64,
maybe it could be removed, I don't know

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 101e0e7..5d0e404 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1831,6 +1848,10 @@ ok:
                                 * lifetimes of an existing temporary address
                                 * when processing a Prefix Information Option.
                                 */
+                               if (ift->prefix_len != ifp->prefix_len ||
+                                   !ipv6_prefix_equal(&ift->addr, &ifp->addr, ifp->prefix_len))
+                                       continue;
+
                                spin_lock(&ift->lock);
                                flags = ift->flags;
                                if (ift->valid_lft > valid_lft &&


-- 
:wq
