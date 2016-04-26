From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40evf: Don't Panic
Date: Tue, 26 Apr 2016 13:55:37 -0700
Message-ID: <1461704148-114349-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:22840 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbcDZUzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:55:52 -0400
In-Reply-To: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Under some circumstances the driver remove function may be called before
the driver is fully initialized. So we can't assume that we know where
our towel is at, or that all of the data structures are initialized.

To ensure that we don't panic, check that the vsi_res pointer is valid
before dereferencing it. Then drink beer and eat peanuts.

Change-ID: If697b4db57348e39f9538793e16aa755e3e1af03
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index e657ecc..017c83b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -256,8 +256,10 @@ struct i40evf_adapter {
 	bool netdev_registered;
 	bool link_up;
 	enum i40e_virtchnl_ops current_op;
-#define CLIENT_ENABLED(_a) ((_a)->vf_res->vf_offload_flags & \
-			    I40E_VIRTCHNL_VF_OFFLOAD_IWARP)
+#define CLIENT_ENABLED(_a) ((_a)->vf_res ? \
+			    (_a)->vf_res->vf_offload_flags & \
+				I40E_VIRTCHNL_VF_OFFLOAD_IWARP : \
+			    0)
 #define RSS_AQ(_a) ((_a)->vf_res->vf_offload_flags & \
 		    I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ)
 #define VLAN_ALLOWED(_a) ((_a)->vf_res->vf_offload_flags & \
-- 
2.5.5
