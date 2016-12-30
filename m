From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: [PATCH v4 2/2] net: 3com: typhoon: typhoon_init_one: make return values more specific
Date: Fri, 30 Dec 2016 03:37:54 +0100
Message-ID: <1483065474-11512-3-git-send-email-thomas.preisner+linux@fau.de>
References: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
 <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de,
        thomas.preisner+linux@fau.de, sergei.shtylyov@cogentembedded.com,
        davem@davemloft.net
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:34737 "EHLO
        faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753401AbcL3CiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 21:38:08 -0500
In-Reply-To: <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases the return value of a failing function is not being used
and the function typhoon_init_one() returns another negative error code
instead.

Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
---
 drivers/net/ethernet/3com/typhoon.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 25f2e92..1986ad1 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2370,9 +2370,9 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * 4) Get the hardware address.
 	 * 5) Put the card to sleep.
 	 */
-	if (typhoon_reset(ioaddr, WaitSleep) < 0) {
+	err = typhoon_reset(ioaddr, WaitSleep);
+	if (err < 0) {
 		err_msg = "could not reset 3XP";
-		err = -EIO;
 		goto error_out_dma;
 	}
 
@@ -2386,16 +2386,16 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	typhoon_init_interface(tp);
 	typhoon_init_rings(tp);
 
-	if(typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST) < 0) {
+	err = typhoon_boot_3XP(tp, TYPHOON_STATUS_WAITING_FOR_HOST);
+	if (err < 0) {
 		err_msg = "cannot boot 3XP sleep image";
-		err = -EIO;
 		goto error_out_reset;
 	}
 
 	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
-	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
+	err = typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp);
+	if (err < 0) {
 		err_msg = "cannot read MAC address";
-		err = -EIO;
 		goto error_out_reset;
 	}
 
@@ -2430,9 +2430,9 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if(xp_resp[0].numDesc != 0)
 		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
 
-	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
+	err = typhoon_sleep(tp, PCI_D3hot, 0);
+	if (err < 0) {
 		err_msg = "cannot put adapter to sleep";
-		err = -EIO;
 		goto error_out_reset;
 	}
 
-- 
2.7.4
