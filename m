From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] bgmac: Bind net_device with backing device structure
Date: Fri,  3 Jun 2016 10:07:00 -0700
Message-ID: <1464973621-14794-2-git-send-email-f.fainelli@gmail.com>
References: <1464973621-14794-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, zajec5@gmail.com, nbd@nbd.name,
	hauke@hauke-m.de, jon.mason@broadcom.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34979 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbcFCRHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:07:07 -0400
Received: by mail-pf0-f196.google.com with SMTP id f144so12019871pfa.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:07:07 -0700 (PDT)
In-Reply-To: <1464973621-14794-1-git-send-email-f.fainelli@gmail.com>
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
