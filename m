From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: don't allocate zero size
Date: Mon,  6 Jan 2014 04:30:28 -0800
Message-ID: <1389011436-18424-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572AbaAFMam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:42 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Shockingly, the compiler didn't flag this uninitialized variable. This
fixes a potential memory corruption condition where ARQ messages are
written to random memory locations.

Change-Id: Iac82f4562d2bf3f42df3f3b2163d9cbed2160135
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c0d7fe6..40484e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4492,6 +4492,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	if (!test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state))
 		return;
 
+	event.msg_size = I40E_MAX_AQ_BUF_SIZE;
 	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
 	if (!event.msg_buf)
 		return;
-- 
1.8.3.1
