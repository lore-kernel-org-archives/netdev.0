From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/5] net: mdio-octeon: use platform_{get,set}_drvdata()
Date: Mon, 02 Sep 2013 17:10:09 +0900
Message-ID: <001101cea7b3$d79f50d0$86ddf270$%han@samsung.com>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'David Daney' <david.daney@cavium.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:32887 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758161Ab3IBIKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 04:10:11 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH00N18NZV1AG0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 17:10:10 +0900 (KST)
In-reply-to: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data
using platform_device instead of using dev_{get,set}_drvdata()
with &pdev->dev, so we can directly pass a struct platform_device.
This is a purely cosmetic change.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/mdio-octeon.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 7f18f80..6aee02e 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -244,7 +244,7 @@ static int octeon_mdiobus_remove(struct platform_device *pdev)
 	struct octeon_mdiobus *bus;
 	union cvmx_smix_en smi_en;
 
-	bus = dev_get_drvdata(&pdev->dev);
+	bus = platform_get_drvdata(pdev);
 
 	mdiobus_unregister(bus->mii_bus);
 	mdiobus_free(bus->mii_bus);
-- 
1.7.10.4
