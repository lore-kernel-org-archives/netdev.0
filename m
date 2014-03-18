From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/i40e: Avoid double setting of NETIF_F_SG for the HW encapsulation feature mask
Date: Tue, 18 Mar 2014 10:36:45 +0200
Message-ID: <1395131805-14146-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50181 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754270AbaCRIhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 04:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The networking core does it for the driver during registration time.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c66a11e..3daaf20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6578,10 +6578,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	np = netdev_priv(netdev);
 	np->vsi = vsi;
 
-	netdev->hw_enc_features = NETIF_F_IP_CSUM	 |
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM	 |
 				  NETIF_F_GSO_UDP_TUNNEL |
-				  NETIF_F_TSO		 |
-				  NETIF_F_SG;
+				  NETIF_F_TSO;
 
 	netdev->features = NETIF_F_SG		       |
 			   NETIF_F_IP_CSUM	       |
-- 
1.7.1
