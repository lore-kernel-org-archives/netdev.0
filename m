From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/25] fm10k: remove extraneous "Reset interface" message
Date: Tue, 14 Apr 2015 16:50:57 -0700
Message-ID: <1429055471-401-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20409 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbbDNXvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:23 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we already print this message when a reset is requested via the
RESET_REQUESTED flag, we do not need to print it before setting the
flag.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index e2c27ba..5022a45 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1191,7 +1191,6 @@ void fm10k_tx_timeout_reset(struct fm10k_intfc *interface)
 {
 	/* Do the reset outside of interrupt context */
 	if (!test_bit(__FM10K_DOWN, &interface->state)) {
-		netdev_err(interface->netdev, "Reset interface\n");
 		interface->tx_timeout_count++;
 		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
 		fm10k_service_event_schedule(interface);
-- 
1.9.3
