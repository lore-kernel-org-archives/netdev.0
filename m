From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] smsc911x: timeout reaches -1
Date: Thu, 29 Jan 2009 16:12:03 +0100
Message-ID: <4981C743.90202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:17228 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbZA2PMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 10:12:05 -0500
Received: by ey-out-2122.google.com with SMTP id 25so209686eya.37
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 07:12:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a postfix decrement the timeout will reach -1 rather than 0,
so the warning will not be issued.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f513bdf..783c1a7 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -953,7 +953,7 @@ smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
 		do {
 			udelay(1);
 			val = smsc911x_reg_read(pdata, RX_DP_CTRL);
-		} while (timeout-- && (val & RX_DP_CTRL_RX_FFWD_));
+		} while (--timeout && (val & RX_DP_CTRL_RX_FFWD_));
 
 		if (unlikely(timeout == 0))
 			SMSC_WARNING(HW, "Timed out waiting for "
