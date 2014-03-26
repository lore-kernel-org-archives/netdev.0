From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Add functionality for FD SB to drop packets
Date: Wed, 26 Mar 2014 11:03:24 -0700
Message-ID: <1395857013-7568-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18894 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbaCZSEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:23 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

With this change we can drop a flow if we wanted to.

Change-ID: I222b1ae960e61a31965bafe3159a95099e70c7d2
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 0461a72..aa123f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1513,11 +1513,16 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 
 	input->fd_id = fsp->location;
 
+	if (fsp->ring_cookie == RX_CLS_FLOW_DISC)
+		input->dest_ctl = I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET;
+	else
+		input->dest_ctl =
+			     I40E_FILTER_PROGRAM_DESC_DEST_DIRECT_PACKET_QINDEX;
+
 	input->q_index = fsp->ring_cookie;
 	input->flex_off = 0;
 	input->pctype = 0;
 	input->dest_vsi = vsi->id;
-	input->dest_ctl = I40E_FILTER_PROGRAM_DESC_DEST_DIRECT_PACKET_QINDEX;
 	input->fd_status = I40E_FILTER_PROGRAM_DESC_FD_STATUS_FD_ID;
 	input->cnt_index = 0;
 	input->flow_type = fsp->flow_type;
-- 
1.8.3.1
