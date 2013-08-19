From: Rami Rosen <ramirose@gmail.com>
Subject: [ PATCH net-next ] xfrm: remove irrelevant comment in xfrm_input().
Date: Mon, 19 Aug 2013 15:47:11 +0300
Message-ID: <1376916431-8249-1-git-send-email-ramirose@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:58657 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab3HSJr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 05:47:27 -0400
Received: by mail-wi0-f173.google.com with SMTP id en1so1621090wid.6
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 02:47:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a comment in xfrm_input() which became irrelevant
due to commit 2774c13, "xfrm: Handle blackhole route creation via afinfo".
That commit removed returning -EREMOTE in the xfrm_lookup() method when the 
packet should be discarded  and also removed the correspoinding -EREMOTE 
handlers. This was replaced by calling the make_blackhole() method. Therefore
the comment about -EREMOTE is not relevant anymore.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/xfrm/xfrm_policy.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d8da6b8..3d65c6e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2132,8 +2132,6 @@ restart:
 		 * have the xfrm_state's. We need to wait for KM to
 		 * negotiate new SA's or bail out with error.*/
 		if (net->xfrm.sysctl_larval_drop) {
-			/* EREMOTE tells the caller to generate
-			 * a one-shot blackhole route. */
 			dst_release(dst);
 			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
-- 
1.8.1.4
