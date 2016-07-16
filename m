From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 09/10] net: phy: Re-attempt custom DT configuration after
 configuration
Date: Sat, 16 Jul 2016 15:29:07 +0100
Message-ID: <1468679348-10522-10-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

marvell,reg-init is generally used to apply a custom LED configuration
on boot. However this is then blatted in m88e1121_config_aneg when the
interface is brought up. Re-apply any custom configuration afterwards,
to keep custom LED configuration.

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 drivers/net/phy/marvell.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index c2ca347..b55e4e0 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -424,6 +424,10 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	phy_write(phydev, MII_MARVELL_PHY_PAGE, oldpage);
 
 	err = genphy_config_aneg(phydev);
+	if (err < 0)
+		return err;
+
+	err = marvell_of_reg_init(phydev);
 
 	return err;
 }
-- 
2.8.1
