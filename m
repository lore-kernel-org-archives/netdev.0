From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e: change Rx hang message into a WARN_ONCE
Date: Sat, 14 May 2016 21:57:29 -0700
Message-ID: <1463288255-1654-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420AbcEOE5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:40 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Use WARN_ONCE in order to highlight the issue, but don't display
a warning every time. The user should be able to see the ethtool counter
we created if necessary to see how often it is occurring.

Change-ID: I40c4ea159819b64a7d33b7f5716749089791533a
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index a1b878a..ed39cba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -289,9 +289,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 		rd32(hw, I40E_PRTTSYN_RXTIME_H(3));
 		pf->last_rx_ptp_check = jiffies;
 		pf->rx_hwtstamp_cleared++;
-		dev_warn(&vsi->back->pdev->dev,
-			 "%s: clearing Rx timestamp hang\n",
-			 __func__);
+		WARN_ONCE(1, "Detected Rx timestamp register hang\n");
 	}
 }
 
-- 
2.5.5
