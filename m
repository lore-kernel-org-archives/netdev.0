From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/10] i40e: return correct opcode to VF
Date: Thu, 22 Sep 2016 22:45:35 -0700
Message-ID: <1474609542-121940-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:58549 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757999AbcIWFpr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 01:45:47 -0400
In-Reply-To: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This conditional is backward, so the driver responds back to the VF with
the wrong opcode. Do the old switcheroo to fix this.

Change-ID: I384035b0fef8a3881c176de4b4672009b3400b25
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index da34235..611fc87 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2217,8 +2217,8 @@ static int i40e_vc_iwarp_qvmap_msg(struct i40e_vf *vf, u8 *msg, u16 msglen,
 error_param:
 	/* send the response to the VF */
 	return i40e_vc_send_resp_to_vf(vf,
-			       config ? I40E_VIRTCHNL_OP_RELEASE_IWARP_IRQ_MAP :
-			       I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP,
+			       config ? I40E_VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP :
+			       I40E_VIRTCHNL_OP_RELEASE_IWARP_IRQ_MAP,
 			       aq_ret);
 }
 
-- 
2.7.4
