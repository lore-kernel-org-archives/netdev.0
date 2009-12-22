From: akpm@linux-foundation.org
Subject: [patch 2/2] drivers/isdn: eliminate duplicated test
Date: Mon, 21 Dec 2009 16:25:32 -0800
Message-ID: <200912220025.nBM0PWwQ005143@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55385 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbZLVAZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 19:25:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The code checked slot_rx twice.  Check slot_tx by analogy with the bank
case.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E;
@@

(
*E && E
|
*E || E
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/hfcmulti.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hardware/mISDN/hfcmulti.c~drivers-isdn-eliminate-duplicated-test drivers/isdn/hardware/mISDN/hfcmulti.c
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c~drivers-isdn-eliminate-duplicated-test
+++ a/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3152,7 +3152,7 @@ static void
 hfcmulti_pcm(struct hfc_multi *hc, int ch, int slot_tx, int bank_tx,
     int slot_rx, int bank_rx)
 {
-	if (slot_rx < 0 || slot_rx < 0 || bank_tx < 0 || bank_rx < 0) {
+	if (slot_tx < 0 || slot_rx < 0 || bank_tx < 0 || bank_rx < 0) {
 		/* disable PCM */
 		mode_hfcmulti(hc, ch, hc->chan[ch].protocol, -1, 0, -1, 0);
 		return;
_
