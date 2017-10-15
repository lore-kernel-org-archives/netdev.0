From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] xen/9pfs: mark expected switch fall-through in
 xen_9pfs_front_changed
Date: Sun, 15 Oct 2017 13:08:40 -0500
Message-ID: <20171015180840.GA7305@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([192.185.198.26]:13640 "EHLO
        gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751337AbdJOSIl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 14:08:41 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway30.websitewelcome.com (Postfix) with ESMTP id 79A27F5E
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 13:08:41 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in this particular case, I placed the "fall through" comment
on its own line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).

 net/9p/trans_xen.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
index 6ad3e04..7ec5df9 100644
--- a/net/9p/trans_xen.c
+++ b/net/9p/trans_xen.c
@@ -510,7 +510,8 @@ static void xen_9pfs_front_changed(struct xenbus_device *dev,
 	case XenbusStateClosed:
 		if (dev->state == XenbusStateClosed)
 			break;
-		/* Missed the backend's CLOSING state -- fallthrough */
+		/* Missed the backend's CLOSING state */
+		/* fall through */
 	case XenbusStateClosing:
 		xenbus_frontend_closed(dev);
 		break;
-- 
2.7.4
