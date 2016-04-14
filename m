From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next] phy: make some bits preserved while setup forced
 mode
Date: Thu, 14 Apr 2016 15:43:52 +0800
Message-ID: <570F4A38.5090201@huawei.com>
References: <570E3488.9060403@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<andrew@lunn.ch>
To: David Miller <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570E3488.9060403@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When tested the PHY SGMII Loopback:
1.set the LOOPBACK bit,
2.set the autoneg to AUTONEG_DISABLE, it calls the
genphy_setup_forced which will clear the bit.

The BMCR_LOOPBACK bit should be preserved.

As Florian pointed out that other bits should be preserved too.
So I make the BMCR_ISOLATE and BMCR_PDOWN as well.

Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
---
the patch is evoluted from "phy: keep the BCMR_LOOPBACK bit
while setup forced mode".

---
 drivers/net/phy/phy_device.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d551df6..9b24d7e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -818,8 +818,9 @@ static int genphy_config_advert(struct phy_device *phydev)
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
-	int ctl = 0;
+	int ctl = phy_read(phydev, MII_BMCR);

+	ctl &= BMCR_LOOPBACK | BMCR_ISOLATE | BMCR_PDOWN;
 	phydev->pause = 0;
 	phydev->asym_pause = 0;

-- 
2.7.0
