From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e: keep service tasks out of reset process
Date: Fri, 20 Jun 2014 00:49:44 -0700
Message-ID: <1403250588-14356-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934734AbaFTHt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:58 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure the service tasks don't try to meddle with the
device while a reset is in progress.  Odd things can happen
such as funky stats values.

Change-ID: I6929cb9d6d96839c9279362ca7c0e3fe6c8fcc66
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 394253e..ebbf37b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5961,6 +5961,12 @@ static void i40e_service_task(struct work_struct *work)
 					  service_task);
 	unsigned long start_time = jiffies;
 
+	/* don't bother with service tasks if a reset is in progress */
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state)) {
+		i40e_service_event_complete(pf);
+		return;
+	}
+
 	i40e_reset_subtask(pf);
 	i40e_handle_mdd_event(pf);
 	i40e_vc_process_vflr_event(pf);
-- 
1.9.3
