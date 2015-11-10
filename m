From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 4/6] net: dsa: mv88e6060: use the correct bit shift for mac0
Date: Tue, 10 Nov 2015 14:25:25 +0100
Message-ID: <5641F045.1060601@baylibre.com>
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

According to the mv88e6060 datasheet, the first mac byte must
be at position 9 instead of 8 since the bit 8 is used to select
if the mac address must differ for each port for Pause frames.
Use the correct shift and set the same mac address for all port.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 6a35e3f..449499d 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -188,7 +188,8 @@ static int mv88e6060_setup(struct dsa_switch *ds)

 static int mv88e6060_set_addr(struct dsa_switch *ds, u8 *addr)
 {
-	REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
+	/* Use the same MAC Address as FD Pause frames for all ports */
+	REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 9) | addr[1]);
 	REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
 	REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);

-- 
1.9.1
