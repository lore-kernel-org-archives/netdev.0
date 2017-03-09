From: Lev Urusov <urusov@granch.ru>
Subject: [PATCH] Fix bug while selecting sysfs node size
Date: Thu,  9 Mar 2017 08:43:49 +0700
Message-ID: <1489023829-2545-1-git-send-email-urusov@granch.ru>
Cc: Lev Urusov <urusov@granch.ru>,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy.granch.ru ([195.60.247.82]:51408 "EHLO proxy.granch.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750787AbdCICR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Mar 2017 21:17:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lev Urusov <urusov@granch.ru>

The driver will not be able to take into account the correct number
of device SPI registers if it is not equal to 128.

Signed-off-by: Lev Urusov <urusov@granch.ru>
---
 drivers/net/phy/spi_ks8995.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 93ffedf..f084725 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -491,8 +491,8 @@ static int ks8995_probe(struct spi_device *spi)
 	if (err)
 		return err;
 
-	ks->regs_attr.size = ks->chip->regs_size;
 	memcpy(&ks->regs_attr, &ks8995_registers_attr, sizeof(ks->regs_attr));
+	ks->regs_attr.size = ks->chip->regs_size;
 
 	err = ks8995_reset(ks);
 	if (err)
-- 
1.9.1
