From: Julien Brunel <brunel@diku.dk>
Subject: [PATCH] net/xfrm: Use an IS_ERR test rather than a NULL test
Date: Mon, 1 Sep 2008 10:53:33 +0200
Message-ID: <200809011053.34028.brunel@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:51286 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbYIAIxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2008 04:53:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Brunel <brunel@diku.dk>

In case of error, the function xfrm_bundle_create returns an ERR
pointer, but never returns a NULL pointer. So a NULL test that comes
after an IS_ERR test should be deleted.

The semantic match that finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@match_bad_null_test@
expression x, E;
statement S1,S2;
@@
x =  xfrm_bundle_create(...)
... when != x = E
*  if (x != NULL) 
S1 else S2
// </smpl>

Signed-off-by:  Julien Brunel <brunel@diku.dk>
Signed-off-by:  Julia Lawall <julia@diku.dk>

---
 net/xfrm/xfrm_policy.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -u -p a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1731,8 +1731,7 @@ restart:
 			 * We can't enlist stable bundles either.
 			 */
 			write_unlock_bh(&policy->lock);
-			if (dst)
-				dst_free(dst);
+			dst_free(dst);
 
 			if (pol_dead)
 				XFRM_INC_STATS(LINUX_MIB_XFRMOUTPOLDEAD);
@@ -1748,8 +1747,7 @@ restart:
 			err = xfrm_dst_update_origin(dst, fl);
 		if (unlikely(err)) {
 			write_unlock_bh(&policy->lock);
-			if (dst)
-				dst_free(dst);
+			dst_free(dst);
 			XFRM_INC_STATS(LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
 			goto error;
 		}
