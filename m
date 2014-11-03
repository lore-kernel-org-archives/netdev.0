From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: phy: spi_ks8995: remove sysfs bin file by registered attribute
Date: Tue,  4 Nov 2014 01:25:09 +0200
Message-ID: <1415057109-8506-1-git-send-email-vz@mleia.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:47985 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbaKCXZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 18:25:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a sysfs binary file is asked to be removed, it is found by
attribute name, so strictly speaking this change is not a fix, but
just in case when attribute name is changed in the driver or sysfs
internals are changed, it might be better to remove the previously
created file using right the same binary attribute.

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/spi_ks8995.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index eab57fc..4653015 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -353,7 +353,9 @@ static int ks8995_probe(struct spi_device *spi)
 
 static int ks8995_remove(struct spi_device *spi)
 {
-	sysfs_remove_bin_file(&spi->dev.kobj, &ks8995_registers_attr);
+	struct ks8995_switch *ks = spi_get_drvdata(spi);
+
+	sysfs_remove_bin_file(&spi->dev.kobj, &ks->regs_attr);
 
 	return 0;
 }
-- 
1.7.10.4
