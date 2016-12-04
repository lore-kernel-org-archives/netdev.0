From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/3] net: ethoc: Demote packet dropped error message to debug
Date: Sun,  4 Dec 2016 12:40:30 -0800
Message-ID: <20161204204030.9853-4-f.fainelli@gmail.com>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
Cc: tremyfr@gmail.com, tklauser@distanz.ch, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36668 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbcLDUkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 15:40:39 -0500
Received: by mail-oi0-f65.google.com with SMTP id u15so34048866oie.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 12:40:38 -0800 (PST)
In-Reply-To: <20161204204030.9853-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spamming the console with: net eth1: packet dropped can happen
fairly frequently if the adapter is busy transmitting, demote the
message to a debug print.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8d0cb5ce87ee..45abc81f6f55 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -576,7 +576,7 @@ static irqreturn_t ethoc_interrupt(int irq, void *dev_id)
 
 	/* We always handle the dropped packet interrupt */
 	if (pending & INT_MASK_BUSY) {
-		dev_err(&dev->dev, "packet dropped\n");
+		dev_dbg(&dev->dev, "packet dropped\n");
 		dev->stats.rx_dropped++;
 	}
 
-- 
2.9.3
