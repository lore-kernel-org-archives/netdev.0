From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] fm10k: do not use enum as boolean
Date: Mon, 12 Oct 2015 22:53:18 -0700
Message-ID: <1444715598-20970-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47881 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbbJMFxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:25 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Check for actual value NETREG_UNINITIALIZED in case it ever changes from
the current value of zero.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 2f47bfe..537d81a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1905,7 +1905,7 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 	u32 reta, base;
 
 	/* If the netdev is initialized we have to maintain table if possible */
-	if (interface->netdev->reg_state) {
+	if (interface->netdev->reg_state != NETREG_UNINITIALIZED) {
 		for (i = FM10K_RETA_SIZE; i--;) {
 			reta = interface->reta[i];
 			if ((((reta << 24) >> 24) < rss_i) &&
-- 
2.4.3
