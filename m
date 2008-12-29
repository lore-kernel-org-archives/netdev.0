From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] smsc911x: compile fix re netif_rx signature changes
Date: Mon, 29 Dec 2008 14:57:06 +0300
Message-ID: <20081229115706.GA21117@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:45438 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042AbYL2LwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 06:52:04 -0500
Received: by ewy10 with SMTP id 10so4980465ewy.13
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2008 03:52:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/smsc911x.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1484,13 +1484,13 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	}
 
 	if (likely(intsts & inten & INT_STS_RSFL_)) {
-		if (likely(netif_rx_schedule_prep(dev, &pdata->napi))) {
+		if (likely(netif_rx_schedule_prep(&pdata->napi))) {
 			/* Disable Rx interrupts */
 			temp = smsc911x_reg_read(pdata, INT_EN);
 			temp &= (~INT_EN_RSFL_EN_);
 			smsc911x_reg_write(pdata, INT_EN, temp);
 			/* Schedule a NAPI poll */
-			__netif_rx_schedule(dev, &pdata->napi);
+			__netif_rx_schedule(&pdata->napi);
 		} else {
 			SMSC_WARNING(RX_ERR,
 				"netif_rx_schedule_prep failed");
