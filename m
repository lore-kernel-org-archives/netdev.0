From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e/i40evf: enable prefetch of Tx descriptors during cleanup
Date: Sat,  7 Mar 2015 07:03:21 -0800
Message-ID: <1425740603-11280-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52869 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbbCGPDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Mar 2015 10:03:32 -0500
In-Reply-To: <1425740603-11280-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Performance can be improved a bit by imitating ixgbe and using
prefetch to get us the next Tx descriptor.

Change-ID: Ice7ffd4cd0ce87c35295059bdb7972a7f53723aa
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a60b840..f5a50b9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -770,6 +770,8 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 			tx_desc = I40E_TX_DESC(tx_ring, 0);
 		}
 
+		prefetch(tx_desc);
+
 		/* update budget accounting */
 		budget--;
 	} while (likely(budget));
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 1c2637b..d9f3db5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -289,6 +289,8 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 			tx_desc = I40E_TX_DESC(tx_ring, 0);
 		}
 
+		prefetch(tx_desc);
+
 		/* update budget accounting */
 		budget--;
 	} while (likely(budget));
-- 
1.9.3
