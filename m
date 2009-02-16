From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] SMSC: timeout reaches -1
Date: Mon, 16 Feb 2009 11:21:33 +0100
Message-ID: <49993E2D.4030103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:34426 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbZBPKVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 05:21:36 -0500
Received: by ewy14 with SMTP id 14so1835880ewy.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 02:21:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a postfix decrement timeouts will reach -1 rather than 0, so
the error path does not appear.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 783c1a7..9a78dae 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1624,7 +1624,7 @@ static int smsc911x_eeprom_send_cmd(struct smsc911x_data *pdata, u32 op)
 	do {
 		msleep(1);
 		e2cmd = smsc911x_reg_read(pdata, E2P_CMD);
-	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (timeout--));
+	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (--timeout));
 
 	if (!timeout) {
 		SMSC_TRACE(DRV, "TIMED OUT");
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index a1e4b38..83938e1 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -341,7 +341,7 @@ static int smsc9420_eeprom_send_cmd(struct smsc9420_pdata *pd, u32 op)
 	do {
 		msleep(1);
 		e2cmd = smsc9420_reg_read(pd, E2P_CMD);
-	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (timeout--));
+	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (--timeout));
 
 	if (!timeout) {
 		smsc_info(HW, "TIMED OUT");
