From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40e: suspend scheduling during driver unload
Date: Fri, 19 Feb 2016 01:54:09 -0800
Message-ID: <1455875651-21696-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pandi Kumar Maharajan <pandi.maharajan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8261 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427400AbcBSJy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:26 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pandi Kumar Maharajan <pandi.maharajan@intel.com>

We need to suspend scheduling or any pending service task during driver
unload process, so that new task will not be scheduled. This patch sets
the suspend flag bit during reload which avoids service task execution.

Change-ID: I017c57b5d6656564556e3c5387da671369a572ac
Signed-off-by: Pandi Kumar Maharajan <pandi.maharajan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 87325db..9076b29 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11215,6 +11215,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), 0);
 
 	/* no more scheduling of any task */
+	set_bit(__I40E_SUSPENDED, &pf->state);
 	set_bit(__I40E_DOWN, &pf->state);
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
-- 
2.5.0
