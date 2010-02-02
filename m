From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/2] netxen: fix tx timeout recovery for NX2031 chip
Date: Tue,  2 Feb 2010 06:16:20 -0800
Message-ID: <1265120181-1671-2-git-send-email-amit.salecha@qlogic.com>
References: <1265120181-1671-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Vernon Mauery <vernux@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52382 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756104Ab0BBOQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 09:16:22 -0500
In-Reply-To: <1265120181-1671-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NX2031, first try to scrub interrupt before requesting firmware
reset. Return statement was missing after scrubbbing interrupt.

Signed-off-by: Vernon Mauery <vernux@us.ibm.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9f9d608..5209095 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1941,7 +1941,7 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 		netif_wake_queue(adapter->netdev);
 
 		clear_bit(__NX_RESETTING, &adapter->state);
-
+		return;
 	} else {
 		clear_bit(__NX_RESETTING, &adapter->state);
 		if (!netxen_nic_reset_context(adapter)) {
-- 
1.5.6.1

