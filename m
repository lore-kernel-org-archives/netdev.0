From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6 3/5] bnx2x: Move to D0 before clearing MSI/MSI-X
 configuration.
Date: Sun, 9 Jan 2011 14:20:19 +0200
Message-ID: <1294575619.31551.17.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1833 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab1AIMU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 07:20:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move to D0 before clearing MSI/MSI-X configuration. Otherwise MSI/MSI-X
won't be cleared.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 2689f02..78cb2e0 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9106,9 +9106,15 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	/* Delete all NAPI objects */
 	bnx2x_del_all_napi(bp);
 
+	/* Power on: we can't let PCI layer write to us while we are in D3 */
+	bnx2x_set_power_state(bp, PCI_D0);
+
 	/* Disable MSI/MSI-X */
 	bnx2x_disable_msi(bp);
 
+	/* Power off */
+	bnx2x_set_power_state(bp, PCI_D3hot);
+
 	/* Make sure RESET task is not scheduled before continuing */
 	cancel_delayed_work_sync(&bp->reset_task);
 
-- 
1.7.0.4




