From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 2/3] of_mdio: fix device reference leak in of_phy_find_device
Date: Wed, 16 Nov 2016 15:20:37 +0100
Message-ID: <1479306038-27211-3-git-send-email-johan@kernel.org>
References: <1479306038-27211-1-git-send-email-johan@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306038-27211-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by bus_find_device() before
returning NULL from of_phy_find_device() when the found device is not a
PHY.

Fixes: 6ed742363b9c ("of: of_mdio: Ensure mdio device is a PHY")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/of/of_mdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 8f4648383fb2..5a3145a02547 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -292,6 +292,7 @@ struct phy_device *of_phy_find_device(struct device_node *phy_np)
 		mdiodev = to_mdio_device(d);
 		if (mdiodev->flags & MDIO_DEVICE_FLAG_PHY)
 			return to_phy_device(d);
+		put_device(d);
 	}
 
 	return NULL;
-- 
2.7.3
