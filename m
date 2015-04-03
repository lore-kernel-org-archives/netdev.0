From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: stop flow director on shutdown
Date: Fri,  3 Apr 2015 05:04:54 -0700
Message-ID: <1428062698-16180-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40006 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbbDCMFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:37 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In some cases, the hardware would continue to try to access the FDIR
ring after entering D3Hot state, which would cause either PCIe errors or
NMIs, depending upon system configuration.

Explicitly stop FDIR in our shutdown routine to eliminate this
possibility.

Change-ID: Ib98060d6352ec595ab9a78bfe252675a9fa5d8bc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 15cee4d..5e79054 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10210,6 +10210,8 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	set_bit(__I40E_DOWN, &pf->state);
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
+	i40e_fdir_teardown(pf);
+
 	rtnl_lock();
 	i40e_prep_for_reset(pf);
 	rtnl_unlock();
-- 
1.9.3
