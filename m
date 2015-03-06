From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] i40e: Fix mismatching type for ioremap_len
Date: Thu,  5 Mar 2015 19:02:35 -0800
Message-ID: <1425610955-11099-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58876 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521AbbCFDCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 22:02:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Ben Hutchings, ioremap uses unsigned long as
its parameter type, so we should be using that instead of u32
or int.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fb369f7..0937cf3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9456,10 +9456,10 @@ static void i40e_print_features(struct i40e_pf *pf)
 static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct i40e_aq_get_phy_abilities_resp abilities;
+	unsigned long ioremap_len;
 	struct i40e_pf *pf;
 	struct i40e_hw *hw;
 	static u16 pfs_found;
-	u32 ioremap_len;
 	u16 link_status;
 	int err = 0;
 	u32 len;
@@ -9509,7 +9509,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw = &pf->hw;
 	hw->back = pf;
 
-	ioremap_len = min_t(int, pci_resource_len(pdev, 0),
+	ioremap_len = min_t(unsigned long, pci_resource_len(pdev, 0),
 			    I40E_MAX_CSR_SPACE);
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0), ioremap_len);
-- 
1.9.3
