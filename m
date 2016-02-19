From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e: Update feature flags to reflect newly enabled features
Date: Thu, 18 Feb 2016 16:31:19 -0800
Message-ID: <1455841881-128892-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36360 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965725AbcBSAbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:37 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Recent changes should have enabled support for IPv6 based tunnels and
support for TSO with outer UDP checksums.  As such we can update the
feature flags to reflect that.

In addition we can clean-up the flags that aren't needed such as SCTP and
RXCSUM since having the bits there doesn't add any value.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 955dc71..2f2b2d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9032,10 +9032,14 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	np = netdev_priv(netdev);
 	np->vsi = vsi;
 
-	netdev->hw_enc_features |= NETIF_F_IP_CSUM	  |
-				   NETIF_F_GSO_UDP_TUNNEL |
-				   NETIF_F_GSO_GRE	  |
-				   NETIF_F_TSO		  |
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM	       |
+				   NETIF_F_IPV6_CSUM	       |
+				   NETIF_F_TSO		       |
+				   NETIF_F_TSO6		       |
+				   NETIF_F_TSO_ECN	       |
+				   NETIF_F_GSO_GRE	       |
+				   NETIF_F_GSO_UDP_TUNNEL      |
+				   NETIF_F_GSO_UDP_TUNNEL_CSUM |
 				   0;
 
 	netdev->features = NETIF_F_SG		       |
@@ -9057,6 +9061,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
 		netdev->features |= NETIF_F_NTUPLE;
+	if (pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
+		netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
-- 
2.5.0
