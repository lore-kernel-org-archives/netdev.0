From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/14] i40e: Use DEBUG_FD message level for an FD message
Date: Fri, 28 Mar 2014 07:08:11 -0700
Message-ID: <1396015695-25283-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17012 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbaC1OJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 10:09:12 -0400
In-Reply-To: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We don't need to print this info unless at FD message level.

Change-ID: I329efdd8e754a0ea0669ec04d12e03db02e6b76e
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index de25a32..a329aac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -482,8 +482,9 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		}
 	} else if (error ==
 			  (0x1 << I40E_RX_PROG_STATUS_DESC_NO_FD_ENTRY_SHIFT)) {
-		netdev_info(rx_ring->vsi->netdev, "ntuple filter loc = %d, could not be removed\n",
-			    rx_desc->wb.qword0.hi_dword.fd_id);
+		if (I40E_DEBUG_FD & pf->hw.debug_mask)
+			dev_info(&pdev->dev, "ntuple filter loc = %d, could not be removed\n",
+				 rx_desc->wb.qword0.hi_dword.fd_id);
 	}
 }
 
-- 
1.9.0
