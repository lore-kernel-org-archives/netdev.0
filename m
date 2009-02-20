From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] SMSC: timeout reaches -1
Date: Fri, 20 Feb 2009 09:51:36 +0100
Message-ID: <499E6F18.4080503@gmail.com>
References: <49993E2D.4030103@gmail.com> <20090220.004114.239993457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:38781 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbZBTIvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:51:39 -0500
Received: by ewy14 with SMTP id 14so744093ewy.13
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 00:51:37 -0800 (PST)
In-Reply-To: <20090220.004114.239993457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Mon, 16 Feb 2009 11:21:33 +0100
> 
>> With a postfix decrement timeouts will reach -1 rather than 0, so
>> the error path does not appear.
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Steve Glendinning submitted the smsc9420 side of this patch,
> please resubmit this with only the smsc911x.c part present.
> 
> Thanks.
> 
ok, here:

--------------------------->8-------------8<------------------------------
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
