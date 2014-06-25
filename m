From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/14] i40e: warn on newer/older firmware API rev
Date: Tue, 24 Jun 2014 18:26:15 -0700
Message-ID: <1403659585-32055-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8779 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253AbaFYB0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 21:26:37 -0400
In-Reply-To: <1403659585-32055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

If the firmware's API minor number is larger than the one expected, log
a warning and recommend driver SW update.
If the firmware's API major or minor number is smaller then the one expected
(n for major, n or n-1 for minor), log a warning and recommend NVM update.

Change-ID: If0b887e055478f8e435ba7fa28113b63a6f1bb35
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 80c5d55..4289ff1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8633,6 +8633,20 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_pf_reset;
 	}
 
+	if (hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR)
+		dev_info(&pdev->dev,
+			 "Note: FW API version %02x.%02x newer than expected %02x.%02x, recommend driver update.\n",
+			 hw->aq.api_maj_ver, hw->aq.api_min_ver,
+			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR);
+
+	if (hw->aq.api_maj_ver < I40E_FW_API_VERSION_MAJOR ||
+	    hw->aq.api_min_ver < (I40E_FW_API_VERSION_MINOR-1))
+		dev_info(&pdev->dev,
+			 "Note: FW API version %02x.%02x older than expected %02x.%02x, recommend nvm update.\n",
+			 hw->aq.api_maj_ver, hw->aq.api_min_ver,
+			 I40E_FW_API_VERSION_MAJOR, I40E_FW_API_VERSION_MINOR);
+
+
 	i40e_verify_eeprom(pf);
 
 	/* Rev 0 hardware was never productized */
-- 
1.9.3
