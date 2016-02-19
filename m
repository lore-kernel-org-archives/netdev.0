From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: Do not drop support for IPv6 VXLAN or GENEVE tunnels
Date: Thu, 18 Feb 2016 16:31:18 -0800
Message-ID: <1455841881-128892-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965716AbcBSAbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:37 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

All of the documentation in the datasheets for the XL710 do not call out
any reason to exclude support for IPv6 based tunnels.  As such I am
dropping the code that was excluding these tunnel types from having their
port numbers recognized.  This way we can take advantage of things such as
checksum offload for inner headers over IPv6 based VXLAN or GENEVE
tunnels.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0fa52ed..955dc71 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8626,9 +8626,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	u8 next_idx;
 	u8 idx;
 
-	if (sa_family == AF_INET6)
-		return;
-
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -8668,9 +8665,6 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 	struct i40e_pf *pf = vsi->back;
 	u8 idx;
 
-	if (sa_family == AF_INET6)
-		return;
-
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -8707,9 +8701,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
 		return;
 
-	if (sa_family == AF_INET6)
-		return;
-
 	idx = i40e_get_udp_port_idx(pf, port);
 
 	/* Check if port already exists */
@@ -8751,9 +8742,6 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 	struct i40e_pf *pf = vsi->back;
 	u8 idx;
 
-	if (sa_family == AF_INET6)
-		return;
-
 	if (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE))
 		return;
 
-- 
2.5.0
