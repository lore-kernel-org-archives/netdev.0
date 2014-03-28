From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net 2/4] ifb: Remove vlan acceleration from vlan_features
Date: Thu, 27 Mar 2014 22:14:47 -0400
Message-ID: <1395972889-32289-3-git-send-email-vyasevic@redhat.com>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757010AbaC1COx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 22:14:53 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2S2ErMv006901
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 22:14:53 -0400
In-Reply-To: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not include vlan acceleration features in vlan_features as that
precludes correct Q-in-Q operation.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ifb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index c14d39b..d7b2e94 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -180,7 +180,8 @@ static void ifb_setup(struct net_device *dev)
 	dev->tx_queue_len = TX_Q_LIMIT;
 
 	dev->features |= IFB_FEATURES;
-	dev->vlan_features |= IFB_FEATURES;
+	dev->vlan_features |= IFB_FEATURES & ~(NETIF_F_HW_VLAN_CTAG_TX |
+					       NETIF_F_HW_VLAN_STAG_TX);
 
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-- 
1.8.5.3
