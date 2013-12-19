From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: remove chatty log messages
Date: Wed, 18 Dec 2013 22:34:46 -0800
Message-ID: <1387434891-19719-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43313 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521Ab3LSGfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:35:01 -0500
In-Reply-To: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Don't complain when we disable queues that are already disable, or
enable them when they're already enabled. This removes a bunch of bogus
log messages that we see at every VF reset.

Change-Id: Ia127be572abdccc48a53d8c43f8a07b8bb920de1
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9d37545..0ea1ca4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2988,21 +2988,11 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
 			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
 
-		if (enable) {
-			/* is STAT set ? */
-			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "Tx %d already enabled\n", i);
+		/* Skip if the queue is already in the requested state */
+		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
 				continue;
-			}
-		} else {
-			/* is !STAT set ? */
-			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "Tx %d already disabled\n", i);
+		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
 				continue;
-			}
-		}
 
 		/* turn on/off the queue */
 		if (enable)
-- 
1.8.3.1
