From: akpm@linux-foundation.org
Subject: [patch 4/4] mISDN: positive error return should be negative in mode_hfcmulti()
Date: Tue, 02 Feb 2010 14:43:47 -0800
Message-ID: <201002022243.o12MhlfZ019228@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51575 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757079Ab0BBWoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The error return should be negative.  Its only caller that acts upon its
return, handle_bmsg(), transmits the positive error but can also return
negative errors.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/hfcmulti.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hardware/mISDN/hfcmulti.c~misdn-positive-error-return-should-be-negative-in-mode_hfcmulti drivers/isdn/hardware/mISDN/hfcmulti.c
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c~misdn-positive-error-return-should-be-negative-in-mode_hfcmulti
+++ a/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2846,7 +2846,7 @@ mode_hfcmulti(struct hfc_multi *hc, int 
 	int conf;
 
 	if (ch < 0 || ch > 31)
-		return EINVAL;
+		return -EINVAL;
 	oslot_tx = hc->chan[ch].slot_tx;
 	oslot_rx = hc->chan[ch].slot_rx;
 	conf = hc->chan[ch].conf;
_
