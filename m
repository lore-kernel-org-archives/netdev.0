From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 3/8] net: can: c_can: Add RAMINIT register information to driver data
Date: Fri, 7 Nov 2014 16:49:17 +0200
Message-ID: <1415371762-29885-4-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some platforms (e.g. TI) need special RAMINIT register handling.
Provide a way to store RAMINIT register description in driver data.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.h          | 6 ++++++
 drivers/net/can/c_can/c_can_platform.c | 1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 26c975d..3c305a1 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -171,6 +171,12 @@ enum c_can_dev_id {
 
 struct c_can_driver_data {
 	enum c_can_dev_id id;
+
+	/* RAMINIT register description. Optional. */
+	u8 num_can;		/* Number of CAN instances on the SoC */
+	u8 *raminit_start_bits;	/* Array of START bit positions */
+	u8 *raminit_done_bits;	/* Array of DONE bit positions */
+	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
 };
 
 /* c_can private data structure */
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 1546c2b..20deb67 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -250,6 +250,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
+
 	switch (drvdata->id) {
 	case BOSCH_C_CAN:
 		priv->regs = reg_map_c_can;
-- 
1.8.3.2

