From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 6/9] net: phy: micrel: add led-mode sanity check
Date: Tue, 11 Nov 2014 20:00:12 +0100
Message-ID: <1415732415-10363-7-git-send-email-johan@kernel.org>
References: <1415732415-10363-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415732415-10363-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure never to update more than two bits when setting the led mode,
something which could for example change the reference-clock setting.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 16135ac18bfe..1b3985cdc64c 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -173,6 +173,11 @@ static int kszphy_setup_led(struct phy_device *phydev,
 	if (of_property_read_u32(of_node, "micrel,led-mode", &val))
 		return 0;
 
+	if (val > 3) {
+		dev_err(&phydev->dev, "invalid led mode: 0x%02x\n", val);
+		return -EINVAL;
+	}
+
 	temp = phy_read(phydev, reg);
 	if (temp < 0)
 		return temp;
-- 
2.0.4
