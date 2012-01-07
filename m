From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] r6040: fix typo in use of MCR0 register bits
Date: Sat,  7 Jan 2012 13:13:17 -0200
Message-ID: <1325949197-10143-1-git-send-email-cesarb@cesarb.net>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4e16d6ebd65b4f2c4e3f780b4c5704beef64019c (r6040: define more MCR0
register bits) added #define values for MCR0 register bits and converted
uses of hardcoded magic values to uses of these defines.

However, one of the conversions looks suspicious:

 #define MCR0		0x00	/* Control register 0 */
+#define  MCR0_RCVEN	0x0002	/* Receive enable */
+#define  MCR0_XMTEN	0x1000	/* Transmission enable */

 	/* Init RDC private data */
-	lp->mcr0 = 0x1002;
+	lp->mcr0 = MCR0_XMTEN | MCR0;

I believe what was meant here was MCR0_XMTEN | MCR0_RCVEN, which makes
sense and matches the original values.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 drivers/net/ethernet/rdc/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 87aa439..cb0eca8 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1160,7 +1160,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->dev = dev;
 
 	/* Init RDC private data */
-	lp->mcr0 = MCR0_XMTEN | MCR0;
+	lp->mcr0 = MCR0_XMTEN | MCR0_RCVEN;
 
 	/* The RDC-specific entries in the device structure. */
 	dev->netdev_ops = &r6040_netdev_ops;
-- 
1.7.7.5
