From: Kjetil Oftedal <oftedal@gmail.com>
Subject: [PATCH] sunhme: Allow usage on SBI based SBus systems
Date: Mon, 7 Nov 2011 22:47:53 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1111072217540.4069@oizys.tordivel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sparclinux@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


To prevent the SBus driver for Sun Happy Meal cards from being loaded for 
PCI cards utilizing the same chipset, a filter was added to the probe 
function in commit 0b492fce3d72d982a7981905f85484a1e1ba7fde.

The filter was implemented by checking the name of the parent node in 
the OF tree. This patch extends this filter, so that the driver will 
load on SBus systems that are based upon SBI SBus Bridges.

Signed-off-by: Kjetil Oftedal <oftedal@gmail.com>
---
 drivers/net/ethernet/sun/sunhme.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index c517dac..cf14ab9 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2637,7 +2637,7 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	sbus_dp = op->dev.parent->of_node;
 
 	/* We can match PCI devices too, do not accept those here. */
-	if (strcmp(sbus_dp->name, "sbus"))
+	if (strcmp(sbus_dp->name, "sbus") && strcmp(sbus_dp->name, "sbi"))
 		return err;
 
 	if (is_qfe) {


