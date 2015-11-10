From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 2/6] net: dsa: mv88e6060: use the correct InitReady bit
Date: Tue, 10 Nov 2015 16:51:19 +0100
Message-ID: <56421277.1030601@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the mv88e6060 datasheet, the InitReady bit position
is 11 and the polarity is inverted.
Use the bit correctly to detect the end of initialization.

Acked-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 6885ef5..eff5e18 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -102,7 +102,7 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0x8000) == 0x0000)
+		if (ret & 0x800)
 			break;

 		usleep_range(1000, 2000);
-- 
1.9.1
