From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 03/28] mISDN: Fixed false interruption of audio during bridging change.
Date: Sat, 17 Mar 2012 10:34:47 +0100
Message-ID: <20120423170549.670339FB8D@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:52532 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>
Transmitted audio data was interrupted if a bridge was enabled or disabled.
Now transmission seamlessly continues during that action.
Fix in hfcmulti.ko

Signed-off-by: Andreas Eversberg <jolly@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 0332231..c4e7fda 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3018,8 +3018,10 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 			HFC_outb(hc, A_CON_HDLC, 0x20 | V_HDLC_TRP | V_IFF);
 			HFC_outb(hc, A_SUBCH_CFG, 0);
 			HFC_outb(hc, A_IRQ_MSK, 0);
-			HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
-			HFC_wait(hc);
+			if (hc->chan[ch].protocol != protocol) {
+				HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
+				HFC_wait(hc);
+			}
 			HFC_outb(hc, R_SLOT, ((((ch / 4) * 8) +
 					       ((ch % 4) * 4) + 1) << 1) | 1);
 			HFC_outb(hc, A_SL_CFG, 0x80 | 0x20 | (ch << 1) | 1);
@@ -3039,8 +3041,10 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 			HFC_outb(hc, A_CON_HDLC, 0x20 | V_HDLC_TRP | V_IFF);
 			HFC_outb(hc, A_SUBCH_CFG, 0);
 			HFC_outb(hc, A_IRQ_MSK, 0);
-			HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
-			HFC_wait(hc);
+			if (hc->chan[ch].protocol != protocol) {
+				HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
+				HFC_wait(hc);
+			}
 			/* tx silence */
 			HFC_outb_nodebug(hc, A_FIFO_DATA0_NOINC, hc->silence);
 			HFC_outb(hc, R_SLOT, (((ch / 4) * 8) +
@@ -3059,8 +3063,10 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 					 V_HDLC_TRP | V_IFF);
 			HFC_outb(hc, A_SUBCH_CFG, 0);
 			HFC_outb(hc, A_IRQ_MSK, 0);
-			HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
-			HFC_wait(hc);
+			if (hc->chan[ch].protocol != protocol) {
+				HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
+				HFC_wait(hc);
+			}
 			/* tx silence */
 			HFC_outb_nodebug(hc, A_FIFO_DATA0_NOINC, hc->silence);
 			/* enable RX fifo */
@@ -3075,8 +3081,10 @@ mode_hfcmulti(struct hfc_multi *hc, int ch, int protocol, int slot_tx,
 					 V_HDLC_TRP);
 			HFC_outb(hc, A_SUBCH_CFG, 0);
 			HFC_outb(hc, A_IRQ_MSK, 0);
-			HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
-			HFC_wait(hc);
+			if (hc->chan[ch].protocol != protocol) {
+				HFC_outb(hc, R_INC_RES_FIFO, V_RES_F);
+				HFC_wait(hc);
+			}
 		}
 		if (hc->ctype != HFC_TYPE_E1) {
 			hc->hw.a_st_ctrl0[hc->chan[ch].port] |=
-- 
1.7.3.4
