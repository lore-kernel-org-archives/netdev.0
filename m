From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Remove 100 Mbps SGMII support for X722
Date: Sat, 24 Sep 2016 23:42:35 -0700
Message-ID: <1474785769-54665-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:18328 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751469AbcIYGmw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:52 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>

This patch fixes the problem where driver shows 100 Mbps as a supported speed,
and allows it to be configured for advertising on X722 devices. This patch
fixes the problem by not setting the 100 Mbps SGMII flag for X722 devices.

Without this patch, the user incorrectly thinks that 100 Mbps is supported
and hence might try to advertise it on X722 devices when it is actually not
a supported speed.

Change-ID: I8c3d7c4251a9402d98994ed29749b7b895a0f205
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 53cde5b..60f082e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8608,7 +8608,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_WB_ON_ITR_CAPABLE |
 			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
 			     I40E_FLAG_NO_PCI_LINK_CHECK |
-			     I40E_FLAG_100M_SGMII_CAPABLE |
 			     I40E_FLAG_USE_SET_LLDP_MIB |
 			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
 	} else if ((pf->hw.aq.api_maj_ver > 1) ||
-- 
2.7.4
