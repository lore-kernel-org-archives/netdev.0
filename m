From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: delay after VF reset
Date: Mon,  9 Feb 2015 02:43:49 -0800
Message-ID: <1423478641-3138-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38701 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760041AbbBIKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:05 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Delay a minimum of 10ms after VF reset, to allow the hardware's internal
FIFOs to flush.

Change-ID: I8a02ddb28c9f0d7303a1eb21d0b2443e5b4c1cda
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 044019b..4e4232a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -668,13 +668,13 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	/* poll VPGEN_VFRSTAT reg to make sure
 	 * that reset is complete
 	 */
-	for (i = 0; i < 100; i++) {
-		/* vf reset requires driver to first reset the
-		 * vf and then poll the status register to make sure
-		 * that the requested op was completed
-		 * successfully
+	for (i = 0; i < 10; i++) {
+		/* VF reset requires driver to first reset the VF and then
+		 * poll the status register to make sure that the reset
+		 * completed successfully. Due to internal HW FIFO flushes,
+		 * we must wait 10ms before the register will be valid.
 		 */
-		usleep_range(10, 20);
+		usleep_range(10000, 20000);
 		reg = rd32(hw, I40E_VPGEN_VFRSTAT(vf->vf_id));
 		if (reg & I40E_VPGEN_VFRSTAT_VFRD_MASK) {
 			rsd = true;
-- 
1.9.3
