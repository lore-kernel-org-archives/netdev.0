From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH next 1/2] net: can: mscan: add a comment on reg to idx mapping
Date: Fri, 23 Aug 2013 00:01:56 +0200
Message-ID: <1377208917-16698-1-git-send-email-agust@denx.de>
Cc: Gerhard Sittig <gsi@denx.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerhard Sittig <gsi@denx.de>

add a comment about the magic of deriving an MSCAN component index
from the peripheral's physical address / register offset

Cc: linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Gerhard Sittig <gsi@denx.de>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 5b0ee8e..bc422ba 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -148,7 +148,10 @@ static u32 mpc512x_can_get_clock(struct platform_device *ofdev,
 		goto exit_put;
 	}
 
-	/* Determine the MSCAN device index from the physical address */
+	/* Determine the MSCAN device index from the peripheral's
+	 * physical address. Register address offsets against the
+	 * IMMR base are:  0x1300, 0x1380, 0x2300, 0x2380
+	 */
 	pval = of_get_property(ofdev->dev.of_node, "reg", &plen);
 	BUG_ON(!pval || plen < sizeof(*pval));
 	clockidx = (*pval & 0x80) ? 1 : 0;
-- 
1.7.9.5

