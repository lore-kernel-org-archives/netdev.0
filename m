From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: Leave debug_mask cleared at init
Date: Wed,  6 Apr 2016 20:29:27 -0700
Message-ID: <1459999779-22254-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9491 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293AbcDGD3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:43 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Don't set our internal debug_mask at startup unless we get specific signal
to from the debug module parameter.

This should take care of the issue with all the device capabilities getting
printed even when we hadn't asked for the debug info.

Change-ID: I7fbc6bd8b11ed9b0631ec018ff36015a04100b6c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d6147f8..86abd08 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8438,7 +8438,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 
 	pf->msg_enable = netif_msg_init(I40E_DEFAULT_MSG_ENABLE,
 				(NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK));
-	pf->hw.debug_mask = pf->msg_enable | I40E_DEBUG_DIAG;
 	if (debug != -1 && debug != I40E_DEFAULT_MSG_ENABLE) {
 		if (I40E_DEBUG_USER & debug)
 			pf->hw.debug_mask = debug;
-- 
2.5.5
