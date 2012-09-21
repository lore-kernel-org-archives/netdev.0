From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: janz-ican3: fix support for older hardware revisions
Date: Fri, 21 Sep 2012 13:05:34 +0200
Message-ID: <1348225535-24976-2-git-send-email-mkl@pengutronix.de>
References: <1348225535-24976-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1348225535-24976-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ira W. Snyder" <iws@ovro.caltech.edu>

The Revision 1.0 Janz CMOD-IO Carrier Board does not have support for
the reset registers. To support older hardware, the code is changed to
use the hardware reset register on the Janz VMOD-ICAN3 hardware itself.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/janz-ican3.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 98ee438..7edadee 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1391,7 +1391,6 @@ static irqreturn_t ican3_irq(int irq, void *dev_id)
  */
 static int ican3_reset_module(struct ican3_dev *mod)
 {
-	u8 val = 1 << mod->num;
 	unsigned long start;
 	u8 runold, runnew;
 
@@ -1405,8 +1404,7 @@ static int ican3_reset_module(struct ican3_dev *mod)
 	runold = ioread8(mod->dpm + TARGET_RUNNING);
 
 	/* reset the module */
-	iowrite8(val, &mod->ctrl->reset_assert);
-	iowrite8(val, &mod->ctrl->reset_deassert);
+	iowrite8(0x00, &mod->dpmctrl->hwreset);
 
 	/* wait until the module has finished resetting and is running */
 	start = jiffies;
-- 
1.7.10

