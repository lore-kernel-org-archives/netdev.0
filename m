From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 1/3] bgmac: Bind net_device with backing device structure
Date: Tue,  7 Jun 2016 15:06:13 -0700
Message-ID: <1465337175-22368-2-git-send-email-f.fainelli@gmail.com>
References: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Cc: ben@decadent.org.uk, zajec5@gmail.com, hauke@hauke-m.de,
	jon.mason@broadcom.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35374 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbcFGWG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:06:26 -0400
Received: by mail-pa0-f66.google.com with SMTP id gp3so14978518pac.2
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:06:26 -0700 (PDT)
In-Reply-To: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing different helpers to be utilized against
network devices created by the bgmac driver, make sure that we bind the
net_device with core->dev.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index ee5f431ab32a..156fa6323745 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1588,6 +1588,7 @@ static int bgmac_probe(struct bcma_device *core)
 	bgmac->net_dev = net_dev;
 	bgmac->core = core;
 	bcma_set_drvdata(core, bgmac);
+	SET_NETDEV_DEV(net_dev, &core->dev);
 
 	/* Defaults */
 	memcpy(bgmac->net_dev->dev_addr, mac, ETH_ALEN);
-- 
2.7.4
