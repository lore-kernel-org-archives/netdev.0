From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: negate PHY int mask bits
Date: Wed, 17 Feb 2016 09:51:39 -0800
Message-ID: <1455731506-62165-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28480 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161621AbcBQRvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:51 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The PHY interrupt mask bits mask out the events we don't want,
so we need to negate the bitmask of events we want.

Change-ID: I273244da5a8d285b6abc84fd68a90f1e6fa0393e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ac89739..e147db2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6826,12 +6826,12 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	if (ret)
 		goto end_core_reset;
 
-	/* driver is only interested in link up/down and module qualification
-	 * reports from firmware
+	/* The driver only wants link up/down and module qualification
+	 * reports from firmware.  Note the negative logic.
 	 */
 	ret = i40e_aq_set_phy_int_mask(&pf->hw,
-				       I40E_AQ_EVENT_LINK_UPDOWN |
-				       I40E_AQ_EVENT_MODULE_QUAL_FAIL, NULL);
+				       ~(I40E_AQ_EVENT_LINK_UPDOWN |
+					 I40E_AQ_EVENT_MODULE_QUAL_FAIL), NULL);
 	if (ret)
 		dev_info(&pf->pdev->dev, "set phy mask fail, err %s aq_err %s\n",
 			 i40e_stat_str(&pf->hw, ret),
@@ -10961,12 +10961,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	/* driver is only interested in link up/down and module qualification
-	 * reports from firmware
+	/* The driver only wants link up/down and module qualification
+	 * reports from firmware.  Note the negative logic.
 	 */
 	err = i40e_aq_set_phy_int_mask(&pf->hw,
-				       I40E_AQ_EVENT_LINK_UPDOWN |
-				       I40E_AQ_EVENT_MODULE_QUAL_FAIL, NULL);
+				       ~(I40E_AQ_EVENT_LINK_UPDOWN |
+					 I40E_AQ_EVENT_MODULE_QUAL_FAIL), NULL);
 	if (err)
 		dev_info(&pf->pdev->dev, "set phy mask fail, err %s aq_err %s\n",
 			 i40e_stat_str(&pf->hw, err),
-- 
2.5.0
