From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: remove interrupt on AQ error
Date: Thu,  9 Jan 2014 04:52:18 -0800
Message-ID: <1389271944-26227-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55960 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbaAIMwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:37 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Since nearly everything we do is synchronous, using the interrupt-on-error bit
is unnecessary and causing unneeded interrupts.  If anyone wants to use the bit
they can turn it on in individual AQ requests using the cmd_details parameter.

Change-ID: I4690a9c561d3e0836aeadb4f88f8a8702b1d1366
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 2b76aba..c75aa2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -864,7 +864,7 @@ void i40e_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
 	/* zero out the desc */
 	memset((void *)desc, 0, sizeof(struct i40e_aq_desc));
 	desc->opcode = cpu_to_le16(opcode);
-	desc->flags = cpu_to_le16(I40E_AQ_FLAG_EI | I40E_AQ_FLAG_SI);
+	desc->flags = cpu_to_le16(I40E_AQ_FLAG_SI);
 }
 
 /**
-- 
1.8.3.1
