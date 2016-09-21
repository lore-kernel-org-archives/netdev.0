From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: return correct opcode to VF
Date: Tue, 20 Sep 2016 20:43:43 -0700
Message-ID: <1474429432-102772-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33017 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753090AbcIUDn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:57 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index f98aa84..9ecf8f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2308,8 +2308,8 @@ static int i40e_vc_iwarp_qvmap_msg(struct i40e_vf *vf, u8 *msg, u16 msglen,
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
