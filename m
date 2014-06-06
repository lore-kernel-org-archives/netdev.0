From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: print message for pre-production hardware
Date: Fri,  6 Jun 2014 02:04:12 -0700
Message-ID: <1402045462-10304-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47819 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbaFFJE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:04:56 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver and hardware are not expected to work correctly
with revision_id 0 hardware.  Don't prevent the user from
using it, but be sure to print a warning.

Change-ID: I3712d34752bfad458078a5f35dfd0aa0ae9fd20e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a08f5a0..105d754 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8298,6 +8298,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	i40e_verify_eeprom(pf);
 
+	/* Rev 0 hardware was never productized */
+	if (hw->revision_id < 1)
+		dev_warn(&pdev->dev, "This device is a pre-production adapter/LOM. Please be aware there may be issues with your hardware. If you are experiencing problems please contact your Intel or hardware representative who provided you with this hardware.\n");
+
 	i40e_clear_pxe_mode(hw);
 	err = i40e_get_capabilities(pf);
 	if (err)
-- 
1.9.3
