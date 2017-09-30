From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40evf: lower message level
Date: Fri, 29 Sep 2017 17:44:59 -0700
Message-ID: <20170930004507.20072-8-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57175 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752640AbdI3Apu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:50 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We see this message regularly on VF reset or unload (which invokes a
reset). It's essentially meaningless unless it's happening constantly.
To prevent consternation, lower the log level to debug so it's not seen
under normal circumstance.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 85876f4fb1fb..2bb0fe00361f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -52,7 +52,7 @@ static int i40evf_send_pf_msg(struct i40evf_adapter *adapter,
 
 	err = i40e_aq_send_msg_to_pf(hw, op, 0, msg, len, NULL);
 	if (err)
-		dev_err(&adapter->pdev->dev, "Unable to send opcode %d to PF, err %s, aq_err %s\n",
+		dev_dbg(&adapter->pdev->dev, "Unable to send opcode %d to PF, err %s, aq_err %s\n",
 			op, i40evf_stat_str(hw, err),
 			i40evf_aq_str(hw, hw->aq.asq_last_status));
 	return err;
-- 
2.14.1
