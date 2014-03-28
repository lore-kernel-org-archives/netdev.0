From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net 3/4] veth: Turn off vlan rx acceleration in vlan_features
Date: Thu, 27 Mar 2014 22:14:48 -0400
Message-ID: <1395972889-32289-4-git-send-email-vyasevic@redhat.com>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757249AbaC1COy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 22:14:54 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s2S2EscP031980
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 22:14:54 -0400
In-Reply-To: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For completeness, turn off vlan rx acceleration in vlan_features so
that it doesn't show up on q-in-q setups.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/veth.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5b37437..c0e7c64 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -286,7 +286,10 @@ static void veth_setup(struct net_device *dev)
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= VETH_FEATURES;
 	dev->vlan_features = dev->features &
-			     ~(NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX);
+			     ~(NETIF_F_HW_VLAN_CTAG_TX |
+			       NETIF_F_HW_VLAN_STAG_TX |
+			       NETIF_F_HW_VLAN_CTAG_RX |
+			       NETIF_F_HW_VLAN_STAG_RX);
 	dev->destructor = veth_dev_free;
 
 	dev->hw_features = VETH_FEATURES;
-- 
1.8.5.3
