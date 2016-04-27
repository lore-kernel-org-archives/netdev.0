From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/14] i40e: Code cleanup in i40e_add_fdir_ethtool
Date: Wed, 27 Apr 2016 13:15:44 -0700
Message-ID: <1461788153-12869-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1226 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261AbcD0UQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:29 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

A little bit of code cleanup in prep for more cloud filter work.

Change-ID: I0dc33ce0d4c207944336a07437640fef920c100c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8a83d45..8e56c43 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2506,7 +2506,6 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 
 	if (!vsi)
 		return -EINVAL;
-
 	pf = vsi->back;
 
 	if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
@@ -2564,15 +2563,18 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	input->src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
 
 	if (ntohl(fsp->m_ext.data[1])) {
-		if (ntohl(fsp->h_ext.data[1]) >= pf->num_alloc_vfs) {
-			netif_info(pf, drv, vsi->netdev, "Invalid VF id\n");
+		vf_id = ntohl(fsp->h_ext.data[1]);
+		if (vf_id >= pf->num_alloc_vfs) {
+			netif_info(pf, drv, vsi->netdev,
+				   "Invalid VF id %d\n", vf_id);
 			goto free_input;
 		}
-		vf_id = ntohl(fsp->h_ext.data[1]);
 		/* Find vsi id from vf id and override dest vsi */
 		input->dest_vsi = pf->vf[vf_id].lan_vsi_id;
 		if (input->q_index >= pf->vf[vf_id].num_queue_pairs) {
-			netif_info(pf, drv, vsi->netdev, "Invalid queue id\n");
+			netif_info(pf, drv, vsi->netdev,
+				   "Invalid queue id %d for VF %d\n",
+				   input->q_index, vf_id);
 			goto free_input;
 		}
 	}
-- 
2.5.5
