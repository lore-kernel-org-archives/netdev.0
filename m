From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] macvlan: Set IFF_UNICAST_FLT flag to prevent unnecessary promisc mode.
Date: Thu,  7 Mar 2013 15:21:48 -0500
Message-ID: <1362687708-8685-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756464Ab3CGUWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 15:22:02 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r27KM2So012157
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 7 Mar 2013 15:22:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvlan already supports hw address filters.  Set the IFF_UNICAST_FLT
so that it doesn't needlesly enter PROMISC mode when macvlans are
stacked.

Signed-of-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 417b2af..73abbc1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -660,6 +660,7 @@ void macvlan_common_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
-- 
1.7.7.6
