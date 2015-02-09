From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: ignore bogus messages from FW
Date: Mon,  9 Feb 2015 02:43:53 -0800
Message-ID: <1423478641-3138-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760427AbbBIKoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:06 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Occasionally on shutdown, the FW will hand us a bunch of messages filled
with zeros, which can cause us to spin trying to handle them. Just
ignore these and get on with shutting down.

Change-ID: I347e9648f7153ad5a7b7e0847b87f7aad5f3e0da
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index cd71c47..38126f5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1631,7 +1631,7 @@ static void i40evf_adminq_task(struct work_struct *work)
 	v_msg = (struct i40e_virtchnl_msg *)&event.desc;
 	do {
 		ret = i40evf_clean_arq_element(hw, &event, &pending);
-		if (ret)
+		if (ret || !v_msg->v_opcode)
 			break; /* No event to process or error cleaning ARQ */
 
 		i40evf_virtchnl_completion(adapter, v_msg->v_opcode,
-- 
1.9.3
