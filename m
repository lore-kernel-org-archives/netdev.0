From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: provide correct API version to older VF drivers
Date: Thu, 23 Jul 2015 06:52:42 -0700
Message-ID: <1437659564-48822-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7061 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbbGWNxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:53:00 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This driver fully supports VF drivers using both the 1.0 and 1.1
versions of the virtual channel API. However, VF drivers using
version 1.0 get upset if we provide them with a version other than
that, and refuse to play with us.

Correct this by checking the VFs API version at the time that we
store it off, and provide the correct version number back to the VF
so we can all get along.

Change-ID: I86dfe02e67b2bef336b4b49a1bb072f3e7229abc
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 176a289..51aff70 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1128,6 +1128,9 @@ static int i40e_vc_get_version_msg(struct i40e_vf *vf, u8 *msg)
 	};
 
 	vf->vf_ver = *(struct i40e_virtchnl_version_info *)msg;
+	/* VFs running the 1.0 API expect to get 1.0 back or they will cry. */
+	if (VF_IS_V10(vf))
+		info.minor = I40E_VIRTCHNL_VERSION_MINOR_NO_VF_CAPS;
 	return i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_VERSION,
 				      I40E_SUCCESS, (u8 *)&info,
 				      sizeof(struct
-- 
2.4.3
