From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 03/13] i40e: Don't check for Tx hang when PF down
Date: Thu, 26 Feb 2015 07:03:39 -0800
Message-ID: <1424963029-4612-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24849 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988AbbBZPEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:04:00 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch adds check to bail out if device is already down when checking
for Tx hang subtask.

Change-ID: I3853fb7a6d11cb9a4c349b687cb25c15b19977a0
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cbe281b..6bb6376 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5587,7 +5587,8 @@ static void i40e_check_hang_subtask(struct i40e_pf *pf)
 	int i, v;
 
 	/* If we're down or resetting, just bail */
-	if (test_bit(__I40E_CONFIG_BUSY, &pf->state))
+	if (test_bit(__I40E_DOWN, &pf->state) ||
+	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
 		return;
 
 	/* for each VSI/netdev
-- 
1.9.3
