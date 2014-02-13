From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 08/15] i40e: reset VFs after PF reset
Date: Thu, 13 Feb 2014 03:48:46 -0800
Message-ID: <1392292133-32120-9-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29634 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754322AbaBMLvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:13 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Reset all of the VFs after a PF reset, so that they are in a known
state, and the VF driver can detect the reset and reinit itself.

Change-ID: I93c5b3a0f8b1371d0da078f92de948b9d3a6413f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8e44411..21d46f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5332,6 +5332,11 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	/* restart the VSIs that were rebuilt and running before the reset */
 	i40e_pf_unquiesce_all_vsi(pf);
 
+	if (pf->num_alloc_vfs) {
+		for (v = 0; v < pf->num_alloc_vfs; v++)
+			i40e_reset_vf(&pf->vf[v], true);
+	}
+
 	/* tell the firmware that we're starting */
 	dv.major_version = DRV_VERSION_MAJOR;
 	dv.minor_version = DRV_VERSION_MINOR;
-- 
1.8.5.GIT
