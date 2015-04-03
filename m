From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: Print some more info to help figure out the cause of HMC error
Date: Fri,  3 Apr 2015 05:04:46 -0700
Message-ID: <1428062698-16180-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbbDCMFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:33 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

HMC_ERRORINFO and HMC_ERRORDATA helps explain the cause of HMC error.

Change-ID: I053bbc175a5f4c5c3e9ec2ea7400d5c56aaa4ec1
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 845bcee..77e3b84 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3197,6 +3197,9 @@ static irqreturn_t i40e_intr(int irq, void *data)
 	if (icr0 & I40E_PFINT_ICR0_HMC_ERR_MASK) {
 		icr0 &= ~I40E_PFINT_ICR0_HMC_ERR_MASK;
 		dev_info(&pf->pdev->dev, "HMC error interrupt\n");
+		dev_info(&pf->pdev->dev, "HMC error info 0x%x, HMC error data 0x%x\n",
+			 rd32(hw, I40E_PFHMC_ERRORINFO),
+			 rd32(hw, I40E_PFHMC_ERRORDATA));
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_TIMESYNC_MASK) {
-- 
1.9.3
