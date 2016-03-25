From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next] phy: keep the BCMR_LOOPBACK bit while setup forced
 mode
Date: Fri, 25 Mar 2016 10:47:48 +0800
Message-ID: <56F4A6D4.2080908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When tested the PHY SGMII Loopback,:
1.set the LOOPBACK bit,
2.set the autoneg to AUTONEG_DISABLE, it calls the
genphy_setup_forced which will clear the bit.

So just keep the LOOPBACK bit while setup forced mode.

Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
---
 drivers/net/phy/phy_device.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e551f3a..8da4b80 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1124,7 +1124,9 @@ static int genphy_config_advert(struct phy_device *phydev)
 int genphy_setup_forced(struct phy_device *phydev)
 {
 	int ctl = 0;
+	int val = phy_read(phydev, MII_BMCR);

+	ctl |= val & BMCR_LOOPBACK;
 	phydev->pause = 0;
 	phydev->asym_pause = 0;

-- 
2.7.0
