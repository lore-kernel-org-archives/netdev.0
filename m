From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 12/17] i40e: remove chatty log messages
Date: Fri,  3 Jan 2014 21:56:40 -0800
Message-ID: <1388815005-23166-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758AbaADF44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 00:56:56 -0500
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/intel/i40e/i40e_main.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a109ae4..82ed436 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2990,21 +2990,11 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
 		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
 			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
 
-		if (enable) {
-			/* is STAT set ? */
-			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "Tx %d already enabled\n", i);
-				continue;
-			}
-		} else {
-			/* is !STAT set ? */
-			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
-				dev_info(&pf->pdev->dev,
-					 "Tx %d already disabled\n", i);
-				continue;
-			}
-		}
+		/* Skip if the queue is already in the requested state */
+		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+			continue;
+		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
+			continue;
 
 		/* turn on/off the queue */
 		if (enable)
-- 
1.8.3.1
