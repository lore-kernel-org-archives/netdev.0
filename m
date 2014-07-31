From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] macvlan: Initialize vlan_features to turn on offload support.
Date: Thu, 31 Jul 2014 10:30:25 -0400
Message-ID: <1406817025-17738-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52545 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768AbaGaOab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 10:30:31 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6VEUVVW015155
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 10:30:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvlan devices do not initialize vlan_features.  As a result,
any vlan devices configured on top of macvlans perform very poorly.
Initialize vlan_features based on the vlan features of the lower-level
device.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 958df38..ef8a5c2 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -646,6 +646,7 @@ static int macvlan_init(struct net_device *dev)
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
 	dev->features		|= ALWAYS_ON_FEATURES;
+	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
-- 
1.9.3
