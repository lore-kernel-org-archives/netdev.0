From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40e: trivial: remove unnecessary local var
Date: Tue, 16 Feb 2016 21:34:21 -0800
Message-ID: <1455687262-20453-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:54509 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756432AbcBQFe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:29 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Probe routine already has too many locals, just convert one
used for kzalloc into a kcalloc, eliminating the local.

Change-ID: I349049872b71f858cbeb91ad7836e6767fc7b7d1
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reviewed-by: Anjali Singhai <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7323e32..a2643fe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10637,7 +10637,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u16 wol_nvm_bits;
 	u16 link_status;
 	int err;
-	u32 len;
 	u32 val;
 	u32 i;
 	u8 set_fc_aq_fail;
@@ -10896,8 +10895,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pf->num_alloc_vsi = pf->hw.func_caps.num_vsis;
 
 	/* Set up the *vsi struct and our local tracking of the MAIN PF vsi. */
-	len = sizeof(struct i40e_vsi *) * pf->num_alloc_vsi;
-	pf->vsi = kzalloc(len, GFP_KERNEL);
+	pf->vsi = kcalloc(pf->num_alloc_vsi, sizeof(struct i40e_vsi *),
+			  GFP_KERNEL);
 	if (!pf->vsi) {
 		err = -ENOMEM;
 		goto err_switch_setup;
-- 
2.5.0
