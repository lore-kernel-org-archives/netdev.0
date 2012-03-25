From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN device stop
Date: Sun, 25 Mar 2012 18:43:57 -0400
Message-ID: <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:46149 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757133Ab2CYW75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2012 18:59:57 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id q2PMi52f006663 for <netdev@vger.kernel.org>; Sun, 25 Mar 2012 18:44:05 -0400
In-Reply-To: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VLAN device is stopped which has VLAN_FLAG_GVRP set, the VLAN
ID attribute that was previously declared by GVRP must be withdrawn.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/8021q/vlan_dev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9988d4a..df86dd0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -319,6 +319,9 @@ static int vlan_dev_stop(struct net_device *dev)
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 
+	if (vlan->flags & VLAN_FLAG_GVRP)
+		vlan_gvrp_request_leave(dev);
+
 	dev_mc_unsync(real_dev, dev);
 	dev_uc_unsync(real_dev, dev);
 	if (dev->flags & IFF_ALLMULTI)
-- 
1.7.1
