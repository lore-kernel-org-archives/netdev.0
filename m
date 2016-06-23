From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: bgmac: Remove superflous netif_carrier_on()
Date: Thu, 23 Jun 2016 14:25:33 -0700
Message-ID: <1466717133-28111-4-git-send-email-f.fainelli@gmail.com>
References: <1466717133-28111-3-git-send-email-f.fainelli@gmail.com>
Cc: nbd@nbd.name, zajec5@gmail.com, davem@davemloft.net,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	bcm-kernel-feedback-list@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35888 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbcFWVZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 17:25:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id i123so7521524pfg.3
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 14:25:46 -0700 (PDT)
In-Reply-To: <1466717133-28111-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bgmac_open() calls phy_start() to initialize the PHY state machine,
which will set the interface's carrier state accordingly, no need to
force that as this could be conflicting with the PHY state determined by
PHYLIB.

Fixes: dd4544f05469 ("bgmac: driver for GBit MAC core on BCMA bus")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 85cd07f72ffb..a6333d38ecc0 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1313,8 +1313,6 @@ static int bgmac_open(struct net_device *net_dev)
 
 	phy_start(bgmac->phy_dev);
 
-	netif_carrier_on(net_dev);
-
 	netif_start_queue(net_dev);
 
 	return 0;
-- 
2.7.4
