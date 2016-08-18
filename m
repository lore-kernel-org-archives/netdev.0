From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: fix memory leak
Date: Thu, 18 Aug 2016 14:57:32 -0700
Message-ID: <1471557456-136741-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16425 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754238AbcHSCq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 22:46:26 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When we allocate memory, we must free it. It's simple courtesy.

Change-ID: Id007294096fb53344f1a8b9a0f78eddf9853c5d6
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 5ea659c..68e3482 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2318,6 +2318,7 @@ err:
 	/* send the response back to the VF */
 	aq_ret = i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS,
 					aq_ret, (u8 *)vrh, len);
+	kfree(vrh);
 	return aq_ret;
 }
 
-- 
2.7.4
