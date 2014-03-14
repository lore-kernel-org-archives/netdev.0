From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/14] i40e: Let MDD events be handled by MDD handler
Date: Fri, 14 Mar 2014 16:34:33 -0700
Message-ID: <1394840075-6851-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26430 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584AbaCNXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:09 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We have a separate handler for MDD events, a generic reset is not required.

Change-ID: I77858e2d479e4e65c52aede67109464649ea0253
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 669715b..54e1462 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2892,8 +2892,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 			 icr0_remaining);
 		if ((icr0_remaining & I40E_PFINT_ICR0_PE_CRITERR_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_PCI_EXCEPTION_MASK) ||
-		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK) ||
-		    (icr0_remaining & I40E_PFINT_ICR0_MAL_DETECT_MASK)) {
+		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK)) {
 			dev_info(&pf->pdev->dev, "device will be reset\n");
 			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 			i40e_service_event_schedule(pf);
-- 
1.8.3.1
