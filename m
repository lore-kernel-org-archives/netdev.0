From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v2] net: ll_temac: Use of_property_read_u32 instead of open-coding it
Date: Wed, 23 Sep 2015 09:20:02 +0200
Message-ID: <1442992802-6112-1-git-send-email-tklauser@distanz.ch>
References: <1442922117-18420-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442922117-18420-1-git-send-email-tklauser@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use of_property_read_u32 to read the "clock-frequency" property instead
of using of_get_property with return value checks.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Reviewed-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
---
v2: Resending with Cc to netdev

 drivers/net/ethernet/xilinx/ll_temac_mdio.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_mdio.c b/drivers/net/=
ethernet/xilinx/ll_temac_mdio.c
index 8cf9d4f..415de1e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_mdio.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
@@ -59,16 +59,15 @@ static int temac_mdio_write(struct mii_bus *bus, in=
t phy_id, int reg, u16 val)
 int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 {
 	struct mii_bus *bus;
-	const u32 *bus_hz;
+	u32 bus_hz;
 	int clk_div;
-	int rc, size;
+	int rc;
 	struct resource res;
=20
 	/* Calculate a reasonable divisor for the clock rate */
 	clk_div =3D 0x3f; /* worst-case default setting */
-	bus_hz =3D of_get_property(np, "clock-frequency", &size);
-	if (bus_hz && size >=3D sizeof(*bus_hz)) {
-		clk_div =3D (*bus_hz) / (2500 * 1000 * 2) - 1;
+	if (of_property_read_u32(np, "clock-frequency", &bus_hz) =3D=3D 0) {
+		clk_div =3D bus_hz / (2500 * 1000 * 2) - 1;
 		if (clk_div < 1)
 			clk_div =3D 1;
 		if (clk_div > 0x3f)
--=20
2.5.0
