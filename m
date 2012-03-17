From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 08/28] mISDN: Fix division by zero
Date: Sat, 17 Mar 2012 11:03:31 +0100
Message-ID: <20120423170549.E7B489FB98@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:52887 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If DTMF debug is set and tresh goes under 100, the printk will cause
a division by zero.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/dsp_dtmf.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_dtmf.c b/drivers/isdn/mISDN/dsp_dtmf.c
index 887860b..642f30b 100644
--- a/drivers/isdn/mISDN/dsp_dtmf.c
+++ b/drivers/isdn/mISDN/dsp_dtmf.c
@@ -222,16 +222,25 @@ coefficients:
 		goto storedigit;
 	}
 
-	if (dsp_debug & DEBUG_DSP_DTMFCOEFF)
+	if (dsp_debug & DEBUG_DSP_DTMFCOEFF) {
+		s32 tresh_100 = tresh/100;
+
+		if (tresh_100 == 0) {
+			tresh_100 = 1;
+			printk(KERN_DEBUG
+				"tresh(%d) too small set tresh/100 to 1\n",
+				tresh);
+		}
 		printk(KERN_DEBUG "a %3d %3d %3d %3d %3d %3d %3d %3d"
 		       " tr:%3d r %3d %3d %3d %3d %3d %3d %3d %3d\n",
 		       result[0] / 10000, result[1] / 10000, result[2] / 10000,
 		       result[3] / 10000, result[4] / 10000, result[5] / 10000,
 		       result[6] / 10000, result[7] / 10000, tresh / 10000,
-		       result[0] / (tresh / 100), result[1] / (tresh / 100),
-		       result[2] / (tresh / 100), result[3] / (tresh / 100),
-		       result[4] / (tresh / 100), result[5] / (tresh / 100),
-		       result[6] / (tresh / 100), result[7] / (tresh / 100));
+		       result[0] / (tresh_100), result[1] / (tresh_100),
+		       result[2] / (tresh_100), result[3] / (tresh_100),
+		       result[4] / (tresh_100), result[5] / (tresh_100),
+		       result[6] / (tresh_100), result[7] / (tresh_100));
+	}
 
 	/* calc digit (lowgroup/highgroup) */
 	lowgroup = -1;
-- 
1.7.3.4
