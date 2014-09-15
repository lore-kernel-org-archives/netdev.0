From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: fix mii_bus to host_dev replacement
Date: Mon, 15 Sep 2014 14:48:08 -0700
Message-ID: <1410817688-19397-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:39280 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002AbaIOVsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:48:21 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so7434481pab.3
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:48:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_of_probe() still used cd->mii_bus instead of cd->host_dev when
building with CONFIG_OF=y. Fix this by making the replacement here as
well.

Fixes: b4d2394d01b ("dsa: Replace mii_bus with a generic host device")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b34d6978d773..6e40928ec0e7 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -440,7 +440,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 		cd = &pd->chip[chip_index];
 
 		cd->of_node = child;
-		cd->mii_bus = &mdio_bus->dev;
+		cd->host_dev = &mdio_bus->dev;
 
 		sw_addr = of_get_property(child, "reg", NULL);
 		if (!sw_addr)
-- 
1.9.1
