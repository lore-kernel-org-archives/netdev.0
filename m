From: Sekhar Nori <nsekhar@ti.com>
Subject: [PATCH] net: ti: cpsw-common: dont print error if ti_cm_get_macid() fails
Date: Wed, 30 Aug 2017 13:37:13 +0530
Message-ID: <423afc6874d8911615c4df941957067aebfc09dd.1504080198.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
        Linux netdev Mailing List <netdev@vger.kernel.org>,
        Tony Lindgren <tony@atomide.com>, Sekhar Nori <nsekhar@ti.com>,
        Adam Ford <aford173@gmail.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:30095 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdH3IIH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 04:08:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is quite common for ti_cm_get_macid() to fail on some of the
platforms it is invoked on. They include any platform where
mac address is not part of SoC register space.

On these platforms, mac address is read and populated in
device-tree by bootloader. An example is TI DA850.

Downgrade the severity of message to "information", so it does
not spam logs when 'quiet' boot is desired.

Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/cpsw-common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw-common.c b/drivers/net/ethernet/ti/cpsw-common.c
index 56ba411421f0..38d1cc557c11 100644
--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -96,7 +96,7 @@ int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr)
 	if (of_machine_is_compatible("ti,dra7"))
 		return davinci_emac_3517_get_macid(dev, 0x514, slave, mac_addr);
 
-	dev_err(dev, "incompatible machine/device type for reading mac address\n");
+	dev_info(dev, "incompatible machine/device type for reading mac address\n");
 	return -ENOENT;
 }
 EXPORT_SYMBOL_GPL(ti_cm_get_macid);
-- 
2.9.0
