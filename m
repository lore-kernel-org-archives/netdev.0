From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 1/4] phy: fix device reference leaks
Date: Thu,  3 Nov 2016 18:40:19 +0100
Message-ID: <1478194822-29545-2-git-send-email-johan@kernel.org>
References: <1478194822-29545-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478194822-29545-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by bus_find_device_by_name()
before returning from phy_connect() and phy_attach().

Note that both function still take a reference to the phy device
through phy_attach_direct().

Fixes: e13934563db0 ("[PATCH] PHY Layer fixup")
Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/phy_device.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e977ba931878..1a4bf8acad78 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -723,6 +723,7 @@ struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
 	phydev = to_phy_device(d);
 
 	rc = phy_connect_direct(dev, phydev, handler, interface);
+	put_device(d);
 	if (rc)
 		return ERR_PTR(rc);
 
@@ -953,6 +954,7 @@ struct phy_device *phy_attach(struct net_device *dev, const char *bus_id,
 	phydev = to_phy_device(d);
 
 	rc = phy_attach_direct(dev, phydev, phydev->dev_flags, interface);
+	put_device(d);
 	if (rc)
 		return ERR_PTR(rc);
 
-- 
2.7.3
