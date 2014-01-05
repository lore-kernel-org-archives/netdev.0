From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: remove un-necessary io-write
Date: Sun,  5 Jan 2014 02:47:07 -0800
Message-ID: <1388918827-13430-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38263 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbaAEKrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:18 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Driver needs to clean PBA only when interrupts are turned off and we
are polling instead.

Change-Id: Ic0c1da761bd3abe7f73b1cc8bcddf8e3a232fd0f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4fcd55c..55fd23d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2769,10 +2769,6 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 	icr0 = rd32(hw, I40E_PFINT_ICR0);
 
-	val = rd32(hw, I40E_PFINT_DYN_CTL0);
-	val = val | I40E_PFINT_DYN_CTL0_CLEARPBA_MASK;
-	wr32(hw, I40E_PFINT_DYN_CTL0, val);
-
 	/* if sharing a legacy IRQ, we might get called w/o an intr pending */
 	if ((icr0 & I40E_PFINT_ICR0_INTEVENT_MASK) == 0)
 		return IRQ_NONE;
-- 
1.8.3.1
