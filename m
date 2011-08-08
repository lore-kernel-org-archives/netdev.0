From: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
Subject: [PATCH 2/4][upstream] powerpc/p1010: Add description for FlexCAN functions
Date: Mon, 8 Aug 2011 20:30:18 +0530
Message-ID: <1312815618-25780-1-git-send-email-bhaskar.upadhaya@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
To: <netdev@vger.kernel.org>, <mkl@pengutronix.de>, <holt@sgi.com>,
	<wg@grandegger.com>, <davem@davemloft.net>,
	<linuxppc-release@linux.freescale.net>, <b22300@freescale.com>,
	<socketcan-
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:36258
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541Ab1HHPBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 11:01:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add description to the existing function of FlexCAN
Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
---
 Based on http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
 Branch master

 drivers/net/can/flexcan.c |  121 +++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 111 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 1767811..a24aa12 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -4,6 +4,7 @@
  * Copyright (c) 2005-2006 Varma Electronics Oy
  * Copyright (c) 2009 Sascha Hauer, Pengutronix
  * Copyright (c) 2010 Marc Kleine-Budde, Pengutronix
+ * Copyright 2011 Freescale Semiconductor, Inc.
  *
  * Based on code originally by Andrey Volkov <avolkov@varma-el.com>
  *
@@ -191,8 +192,11 @@ static struct can_bittiming_const flexcan_bittiming_const = {
 	.brp_inc = 1,
 };
 
-/*
- * Swtich transceiver on or off
+/**
+ * flexcan_transceiver_switch - Switches the transceiver
+ *				on/off
+ * @priv: pointer to private data
+ * @on: 1 == turns transceiver on, 0 == turn it off
  */
 static void flexcan_transceiver_switch(const struct flexcan_priv *priv, int on)
 {
@@ -200,6 +204,12 @@ static void flexcan_transceiver_switch(const struct flexcan_priv *priv, int on)
 		priv->pdata->transceiver_switch(on);
 }
 
+/**
+ * flexcan_has_and_handle_berr - returns 0/1 after checking the
+ * Error and Status register.
+ * @priv: pointer to private data
+ * @reg_esr: error and status register.
+ */
 static inline int flexcan_has_and_handle_berr(const struct flexcan_priv *priv,
 					      u32 reg_esr)
 {
@@ -207,6 +217,13 @@ static inline int flexcan_has_and_handle_berr(const struct flexcan_priv *priv,
 		(reg_esr & FLEXCAN_ESR_ERR_BUS);
 }
 
+/**
+ * flexcan_chip_enable - enables the flexCAN
+ * @priv: pointer to private data
+ *
+ * Enables FlexCAN by writing to the MDIS bit
+ * of MCR
+ */
 static inline void flexcan_chip_enable(struct flexcan_priv *priv)
 {
 	struct flexcan_regs __iomem *regs = priv->base;
@@ -219,6 +236,13 @@ static inline void flexcan_chip_enable(struct flexcan_priv *priv)
 	udelay(10);
 }
 
+/**
+ * flexcan_chip_disable - disables the flexCAN
+ * @priv: pointer to private data
+ *
+ * disables FlexCAN by writing to the MDIS bit
+ * of MCR
+ */
 static inline void flexcan_chip_disable(struct flexcan_priv *priv)
 {
 	struct flexcan_regs __iomem *regs = priv->base;
@@ -229,6 +253,14 @@ static inline void flexcan_chip_disable(struct flexcan_priv *priv)
 	writel(reg, &regs->mcr);
 }
 
+/**
+ * flexcan_get_berr_counter - gets the Rx/Tx Error counter
+ * @dev: dev pointer of FlexCAN
+ * @bec: buffer to be filled with Tx/Rx Error Counter
+ *
+ * fills the tx/rx error counter values from the ECR
+ * register of FlexCAN
+ */
 static int flexcan_get_berr_counter(const struct net_device *dev,
 				    struct can_berr_counter *bec)
 {
@@ -242,6 +274,17 @@ static int flexcan_get_berr_counter(const struct net_device *dev,
 	return 0;
 }
 
+/**
+ * flexcan_start_xmit -
+ * @skb: socket buffer to hold CAN frames
+ * @dev: dev pointer of FlexCAN
+ *
+ * validates the incomming socket buffer and also
+ * prepares the message buffer for transmission process
+ *
+ * Return value
+ *    - NETDEV_TX_OK
+ */
 static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
@@ -286,6 +329,16 @@ static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+/**
+ * do_bus_err - fills the FlexCAN Message buffer
+ *		depending on the Error and Status register
+ * @dev: dev pointer of FlexCAN
+ * @cf: can frame
+ * @reg_esr: error and status register
+ *
+ * checks the various error bits of Error and status
+ * register, and fills the message buffer of CAN frame accordingly
+ */
 static void do_bus_err(struct net_device *dev,
 		       struct can_frame *cf, u32 reg_esr)
 {
@@ -352,6 +405,16 @@ static int flexcan_poll_bus_err(struct net_device *dev, u32 reg_esr)
 	return 1;
 }
 
+/**
+ * do_state - updates the CAN frame depending on
+ *		CAN bus states
+ * @dev: dev pointer of FlexCAN
+ * @cf: can frame
+ * @new_state: CAN frame is filled in accordance with the new_state
+ *
+ * checks the new_state against various CAN bus states
+ * and fills the id and data fields of CAN frame accordingly
+ */
 static void do_state(struct net_device *dev,
 		     struct can_frame *cf, enum can_state new_state)
 {
@@ -418,6 +481,15 @@ static void do_state(struct net_device *dev,
 	}
 }
 
+/**
+ * flexcan_poll_state - polls FlexCAN state depending on the Fault
+ *			confinement state of ESR
+ * @dev: dev pointer of FlexCAN
+ * @reg_esr: Error and Status register
+ *
+ * polls for FlexCAN state ie busoff, error active,
+ * error passive or error warning depending on the fault confinement state
+ */
 static int flexcan_poll_state(struct net_device *dev, u32 reg_esr)
 {
 	struct flexcan_priv *priv = netdev_priv(dev);
@@ -504,6 +576,14 @@ static int flexcan_read_frame(struct net_device *dev)
 	return 1;
 }
 
+/**
+ * flexcan_poll - NAPI interface poll function
+ * @napi: napi pointer
+ * @quota: Number of packets to be processed
+ *
+ * checks whether the FIFO bits are set for Interrupt Flag1
+ * register and then process the received frames
+ */
 static int flexcan_poll(struct napi_struct *napi, int quota)
 {
 	struct net_device *dev = napi->dev;
@@ -543,6 +623,16 @@ static int flexcan_poll(struct napi_struct *napi, int quota)
 	return work_done;
 }
 
+/**
+ * flexcan_irq - ISR handler
+ * @irq: irq number
+ * @dev_id: device id
+ *
+ * handler gets called in the below context
+ * 1. When the frames are available in FIFO
+ * 2. FIFO Ovrflow
+ * 3. Transmission complete interrupt
+ */
 static irqreturn_t flexcan_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
@@ -594,6 +684,13 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+/**
+ * flexcan_set_bittiming - Sets bit-timing paramaters
+ * @dev: dev pointer of FlexCAN
+ *
+ * sets the bit-timing parameters of FlexCAN
+ * responsible for CAN clock generation.
+ */
 static void flexcan_set_bittiming(struct net_device *dev)
 {
 	const struct flexcan_priv *priv = netdev_priv(dev);
@@ -632,11 +729,15 @@ static void flexcan_set_bittiming(struct net_device *dev)
 		readl(&regs->mcr), readl(&regs->ctrl));
 }
 
-/*
- * flexcan_chip_start
- *
- * this functions is entered with clocks enabled
+/**
+ * flexcan_chip_start - performs the basic CAN initialization
+ * @dev: dev pointer of FlexCAN
  *
+ * function is entered with clocks enabled
+ * It does the following
+ * 1. Enabling the CAN module
+ * 2. Basic registers initialization
+ * 3. Enabling FIFO
  */
 static int flexcan_chip_start(struct net_device *dev)
 {
@@ -746,11 +847,11 @@ static int flexcan_chip_start(struct net_device *dev)
 	return err;
 }
 
-/*
- * flexcan_chip_stop
- *
- * this functions is entered with clocks enabled
+/**
+ * flexcan_chip_stop -
+ * @dev: dev pointer of FlexCAN
  *
+ * disables the CAN
  */
 static void flexcan_chip_stop(struct net_device *dev)
 {
-- 
1.5.6.5


