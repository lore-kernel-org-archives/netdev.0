From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/7] tg3: PCI command adjustment
Date: Fri, 19 Oct 2007 14:36:53 -0700
Message-ID: <1192829814.22064.558.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3022 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762473AbXJSVhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the way the driver works with the PCI command
register.  It adjusts the access size from dwords to words.  This patch
is done both as a PCI configuration space cleanup and as preparatory
work for PCI error recovery.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 68472ce..9920751 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5029,10 +5029,7 @@ static int tg3_poll_fw(struct tg3 *tp)
 /* Save PCI command register before chip reset */
 static void tg3_save_pci_state(struct tg3 *tp)
 {
-	u32 val;
-
-	pci_read_config_dword(tp->pdev, TG3PCI_COMMAND, &val);
-	tp->pci_cmd = val;
+	pci_read_config_word(tp->pdev, PCI_COMMAND, &tp->pci_cmd);
 }
 
 /* Restore PCI state after chip reset */
@@ -5055,7 +5052,7 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 		       PCISTATE_ALLOW_APE_SHMEM_WR;
 	pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE, val);
 
-	pci_write_config_dword(tp->pdev, TG3PCI_COMMAND, tp->pci_cmd);
+	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
 		pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 495a1df..1d5b2a3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2421,7 +2421,7 @@ struct tg3 {
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 
 	u32				led_ctrl;
-	u32				pci_cmd;
+	u16				pci_cmd;
 
 	char				board_part_number[24];
 #define TG3_VER_SIZE 32


