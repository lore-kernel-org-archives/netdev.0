From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net] be2net: Fix incorrect setting of tunnel offload flag in netdev features
Date: Fri, 19 Dec 2014 10:00:18 +0530
Message-ID: <1418963418-18792-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:46766 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbaLRMEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 07:04:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An earlier commit to resolve an issue with encapsulation offloads missed
setting a bit in the outer netdev features flag. This results in loss of TSO
feature on a VxLAN interface.

Fixes: 630f4b70 ("Export tunnel offloads only when a VxLAN tunnel is created")

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2aacd47..1960731 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3138,6 +3138,7 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 
 	netdev->hw_enc_features = 0;
 	netdev->hw_features &= ~(NETIF_F_GSO_UDP_TUNNEL);
+	netdev->features &= ~(NETIF_F_GSO_UDP_TUNNEL);
 }
 #endif
 
@@ -4429,6 +4430,7 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 				   NETIF_F_TSO | NETIF_F_TSO6 |
 				   NETIF_F_GSO_UDP_TUNNEL;
 	netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	netdev->features |= NETIF_F_GSO_UDP_TUNNEL;
 
 	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
-- 
1.7.9.5
