From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: bgmac: Start transmit queue in bgmac_open
Date: Thu, 23 Jun 2016 14:25:32 -0700
Message-ID: <1466717133-28111-3-git-send-email-f.fainelli@gmail.com>
Cc: nbd@nbd.name, zajec5@gmail.com, davem@davemloft.net,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35723 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbcFWVZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:25:43 -0400
Received: by mail-pa0-f68.google.com with SMTP id hf6so7316454pac.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 14:25:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not start the transmit queue in bgmac_open(). If the
queue was stopped prior to closing then re-opening the interface, we
would never be able to wake-up again.

Fixes: dd4544f05469 ("bgmac: driver for GBit MAC core on BCMA bus")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 70926c611f25..85cd07f72ffb 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1314,6 +1314,9 @@ static int bgmac_open(struct net_device *net_dev)
 	phy_start(bgmac->phy_dev);
 
 	netif_carrier_on(net_dev);
+
+	netif_start_queue(net_dev);
+
 	return 0;
 }
 
-- 
2.7.4
