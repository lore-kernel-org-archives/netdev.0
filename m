From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: reinit buffer size each time
Date: Sun,  5 Jan 2014 02:47:00 -0800
Message-ID: <1388918827-13430-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5665 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbaAEKrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:14 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When cleaning the ARQ, we must reinitialize the buffer size each time we
go through the loop, because i40e_clean_arq_element returns the message
length in the same field. Without this change, subsequent messages can
be truncated to the length of the previous message.

Change-Id: Ic9c32ff843faf0fc3196d21351a1c3a60c6158eb
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 94d0e45..7194277 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4493,12 +4493,12 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	if (!test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state))
 		return;
 
-	event.msg_size = I40E_MAX_AQ_BUF_SIZE;
 	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
 	if (!event.msg_buf)
 		return;
 
 	do {
+		event.msg_size = I40E_MAX_AQ_BUF_SIZE; /* reinit each time */
 		ret = i40e_clean_arq_element(hw, &event, &pending);
 		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
 			dev_info(&pf->pdev->dev, "No ARQ event found\n");
-- 
1.8.3.1
