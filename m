From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v3 3/8] net: can: c_can: Add RAMINIT register information to driver data
Date: Tue, 4 Nov 2014 12:20:56 +0200
Message-ID: <1415096461-25576-4-git-send-email-rogerq@ti.com>
References: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46360 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbaKDKV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 05:21:56 -0500
In-Reply-To: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some platforms (e.g. TI) need special RAMINIT register handling.
Provide a way to store RAMINIT register description in driver data.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/can/c_can/c_can.h          | 6 ++++++
 drivers/net/can/c_can/c_can_platform.c | 2 ++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 26c975d..c3b2108 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -171,6 +171,11 @@ enum c_can_dev_id {
 
 struct c_can_driver_data {
 	enum c_can_dev_id id;
+
+	/* RAMINIT register description. Optional. */
+	u8 raminit_start_bit;	/* START bit position in RAMINIT reg. */
+	u8 raminit_done_bit;	/* DONE bit position in RAMINIT reg. */
+	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
 };
 
 /* c_can private data structure */
@@ -196,6 +201,7 @@ struct c_can_priv {
 	u32 comm_rcv_high;
 	u32 rxmasked;
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
+	const struct c_can_driver_data *drvdata;
 };
 
 struct net_device *alloc_c_can_dev(void);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 1546c2b..11946e8 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -250,6 +250,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	}
 
 	priv = netdev_priv(dev);
+	priv->drvdata = drvdata;
+
 	switch (drvdata->id) {
 	case BOSCH_C_CAN:
 		priv->regs = reg_map_c_can;
-- 
1.8.3.2
