From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/15] i40e: limit sriov to partition 1 of NPAR configurations
Date: Tue, 13 Jan 2015 11:58:13 -0800
Message-ID: <1421179093-10932-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45007 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753871AbbAMT6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:19 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure we only allow SR/IOV on the master PF of a port in multifunction
mode.  This should be the case anyway based on the num_vfs configured in
the NVM, but this will help make sure there's no question.  If we're not
in multifunction mode the partition_id will always be 1.

Change-ID: I8b2592366fe6782f15301bde2ebd1d4da240109d
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 80430b0..f3b036d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7319,7 +7319,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 
 #endif /* I40E_FCOE */
 #ifdef CONFIG_PCI_IOV
-	if (pf->hw.func_caps.num_vfs) {
+	if (pf->hw.func_caps.num_vfs && pf->hw.partition_id == 1) {
 		pf->num_vf_qps = I40E_DEFAULT_QUEUES_PER_VF;
 		pf->flags |= I40E_FLAG_SRIOV_ENABLED;
 		pf->num_req_vfs = min_t(int,
-- 
1.9.3
