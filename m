From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v2] geneve: remove vlan-related feature assignment
Date: Fri, 18 Sep 2015 16:20:32 -0400
Message-ID: <1442607632-16580-1-git-send-email-linville@tuxdriver.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
Cc: davem@davemloft.net, Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47474 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbbIRUaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 16:30:17 -0400
In-Reply-To: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code handling vlan tag insertion was dropped in commit 371bd1061d29
("geneve: Consolidate Geneve functionality in single module.").  Now we
need to drop the related vlan feature bits in the netdev structure.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
v2 -- replace earlier patch "geneve: restore vlan bits in xmit path"

 drivers/net/geneve.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 549febac0579..63fc4eb85cbe 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -748,12 +748,8 @@ static void geneve_setup(struct net_device *dev)
 	dev->features    |= NETIF_F_RXCSUM;
 	dev->features    |= NETIF_F_GSO_SOFTWARE;
 
-	dev->vlan_features = dev->features;
-	dev->features    |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
-
 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
-	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
-- 
2.4.3
