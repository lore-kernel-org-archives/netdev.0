From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: drivers/net/tokenring/smctr.c: logical-bitwise or confusion?
Date: Mon, 10 Mar 2008 02:16:31 +0100
Message-ID: <47D48BEF.2070103@tiscali.nl>
References: <993737.45508.qm@web65610.mail.ac4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jschlst@samba.org, netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:57487 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbYCJBQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 21:16:40 -0400
In-Reply-To: <993737.45508.qm@web65610.mail.ac4.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> --- Roel Kluin <12o3l@tiscali.nl> wrote:
> 
>> drivers/net/tokenring/smctr.c:3416
>>
>> tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
>>
>> shouldn't this be a bit-wise or?
>> from drivers/net/tokenring/smctr.h:50:
>>
>> #define      IBM_PASS_SOURCE_ADDR    0x01
> 
> Probably a safe bet that is what they meant to have. Since
> as it stands, gcc will (correctly) optimize that into:
> 
> tsv->svv[0]= 1;
> 
> which probably isn't particularly useful.
> 
> Paul.

That was what I was thinking as well.
---
logical-bitwise | confusion

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index 8909050..8ae5837 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3413,7 +3413,7 @@ static int smctr_make_tx_status_code(struct net_device *dev,
         tsv->svi = TRANSMIT_STATUS_CODE;
         tsv->svl = S_TRANSMIT_STATUS_CODE;
 
-        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
+        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) | IBM_PASS_SOURCE_ADDR);
 
         /* Stripped frame status of Transmitted Frame */
         tsv->svv[1] = tx_fstatus & 0xff;
