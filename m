From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/18] i40e: Remove MSIx only if created
Date: Tue,  5 Apr 2016 13:17:27 -0700
Message-ID: <1459887455-146634-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10824 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933584AbcDEURp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:45 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When cleaning up the interrupt handling, clean up the IRQs only if
we actually got them set up.  There are a couple of error recovery
paths that were violating this and causing the kernel a bit of
indigestion.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Reviewed-by: Williams, Mitch A <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 650336e..2464dca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4164,7 +4164,7 @@ static void i40e_clear_interrupt_scheme(struct i40e_pf *pf)
 	int i;
 
 	i40e_stop_misc_vector(pf);
-	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED && pf->msix_entries) {
 		synchronize_irq(pf->msix_entries[0].vector);
 		free_irq(pf->msix_entries[0].vector, pf);
 	}
-- 
2.5.5
