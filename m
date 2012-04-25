From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] dl2k: Tighten ioctl permissions
Date: Wed, 25 Apr 2012 15:33:43 -0400
Message-ID: <4F985197.1060607@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47231 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757285Ab2DYTdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 15:33:47 -0400
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id B914B8FE69
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 21:33:45 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 dl2k's rio_ioctl function defines several ioctls that involve
 operations that should be denied to regular users.

 SIOCDEVPRIVATE + 2 is a renumbered SIOCSMIIREG.
 SIOCDEVPRIVATE + 5 calls netif_stop_queue.
 SIOCDEVPRIVATE + 6 calls netif_wake_queue.

Reported-by: Stephan Mueller <stephan.mueller@atsec.com>
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 drivers/net/ethernet/dlink/dl2k.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1264,6 +1264,14 @@ rio_ioctl (struct net_device *dev, struc
 	struct netdev_desc *desc;
 	int i;
 
+	switch (cmd) {
+	case SIOCDEVPRIVATE + 2:
+	case SIOCDEVPRIVATE + 5:
+	case SIOCDEVPRIVATE + 6:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+	};
+
 	phy_addr = np->phy_addr;
 	switch (cmd) {
 	case SIOCDEVPRIVATE:

-- 
Jeff Mahoney
SUSE Labs
