From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40e: Change BUG_ON to WARN_ON in service event complete
Date: Tue, 24 Nov 2015 16:04:33 -0800
Message-ID: <1448409886-90686-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754356AbbKYAEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:51 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

There's no need to kill the thread and eventually the kernel in this
case.  In fact, the remainder of the code won't hurt anything anyway,
so just complain that we're here and move along.

Prompted by a recent Linus diatribe.

Change-ID: Iec020d8bcfedffc1cd2553cc6905fd915bb3e670
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b825f97..7715c54 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5738,7 +5738,7 @@ static void i40e_handle_lan_overflow_event(struct i40e_pf *pf,
  **/
 static void i40e_service_event_complete(struct i40e_pf *pf)
 {
-	BUG_ON(!test_bit(__I40E_SERVICE_SCHED, &pf->state));
+	WARN_ON(!test_bit(__I40E_SERVICE_SCHED, &pf->state));
 
 	/* flush memory to make sure state is correct before next watchog */
 	smp_mb__before_atomic();
-- 
2.5.0
