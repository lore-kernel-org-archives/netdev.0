From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] de2104x: fix panic on load
Date: Wed, 03 Nov 2010 23:25:32 +0100
Message-ID: <1288823132.2718.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51378 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0KCWZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 18:25:37 -0400
Received: by wwe15 with SMTP id 15so1302563wwe.1
        for <netdev@vger.kernel.org>; Wed, 03 Nov 2010 15:25:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its now illegal to call netif_stop_queue() before register_netdev()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tulip/de2104x.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 28e1ffb..c78a505 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -2021,7 +2021,6 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	de->media_timer.data = (unsigned long) de;
 
 	netif_carrier_off(dev);
-	netif_stop_queue(dev);
 
 	/* wake up device, assign resources */
 	rc = pci_enable_device(pdev);


