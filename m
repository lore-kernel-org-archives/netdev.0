From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] i40e: fix PTP bug
Date: Fri, 15 Aug 2014 04:37:53 -0700
Message-ID: <1408102673-27206-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53798 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaHOLib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 07:38:31 -0400
In-Reply-To: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The receive hang detection routine was never being run when
PTP was enabled.

Change-ID: I200f35b0f3190d31b595df89d678f4c8a2131ba0
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index bb7fe98b..537b621 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -247,7 +247,7 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 	u32 prttsyn_stat;
 	int n;
 
-	if (pf->flags & I40E_FLAG_PTP)
+	if (!(pf->flags & I40E_FLAG_PTP))
 		return;
 
 	prttsyn_stat = rd32(hw, I40E_PRTTSYN_STAT_1);
-- 
1.9.3
