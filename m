From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH] i40evf: Use le32_to_cpu before evaluating HW desc fields.
Date: Mon,  1 May 2017 16:15:59 -0700
Message-ID: <1493680559-6728-1-git-send-email-tushar.n.dave@oracle.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36425 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750749AbdEAXRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 19:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i40e hardware descriptor fields are in little-endian format. Driver
must use le32_to_cpu while evaluating these fields otherwise on
big-endian arch we end up evaluating incorrect values, cause errors
like:

i40evf 0001:04:02.0: Expected response 0 from PF, received 285212672
i40evf 0001:04:02.1: Expected response 0 from PF, received 285212672

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f35dcaa..2c1dfaf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1923,8 +1923,10 @@ static void i40evf_adminq_task(struct work_struct *work)
 		if (ret || !v_msg->v_opcode)
 			break; /* No event to process or error cleaning ARQ */
 
-		i40evf_virtchnl_completion(adapter, v_msg->v_opcode,
-					   v_msg->v_retval, event.msg_buf,
+		i40evf_virtchnl_completion(adapter,
+					   le32_to_cpu(v_msg->v_opcode),
+					   le32_to_cpu(v_msg->v_retval),
+					   event.msg_buf,
 					   event.msg_len);
 		if (pending != 0)
 			memset(event.msg_buf, 0, I40EVF_MAX_AQ_BUF_SIZE);
-- 
1.9.1
