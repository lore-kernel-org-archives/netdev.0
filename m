From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 4/6] net: emaclite: Do not use microblaze and ppc IO functions
Date: Thu, 30 May 2013 12:28:06 +0200
Message-ID: <f05f284653ddf7d812ba0a6bd0e271736e910a37.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-5484-1369909698-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>, renner@efe-gmbh.de,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34589 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968213Ab3E3K2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:28:22 -0400
Received: by mail-wg0-f53.google.com with SMTP id m15so66715wgh.32
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 03:28:20 -0700 (PDT)
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-5484-1369909698-0001

Emaclite can be used on ARM zynq where in_be32/out_be32 IO
functions are not present. Use standard __raw_readl/__raw_writel
IO functions instead.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2:
- Fix __raw_iowrite() to pass correct parameters

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 138 +++++++++++++-------------
 1 file changed, 69 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 93bb14e..9227ed7 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -159,34 +159,32 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
 	u32 reg_data;

 	/* Enable the Tx interrupts for the first Buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_TSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_TSR_OFFSET,
-		 reg_data | XEL_TSR_XMIT_IE_MASK);
+	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	__raw_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
+		     drvdata->base_addr + XEL_TSR_OFFSET);

 	/* Enable the Tx interrupts for the second Buffer if
 	 * configured in HW */
 	if (drvdata->tx_ping_pong != 0) {
-		reg_data = in_be32(drvdata->base_addr +
+		reg_data = __raw_readl(drvdata->base_addr +
 				   XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
-			 XEL_TSR_OFFSET,
-			 reg_data | XEL_TSR_XMIT_IE_MASK);
+		__raw_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
+			     drvdata->base_addr + XEL_BUFFER_OFFSET +
+			     XEL_TSR_OFFSET);
 	}

 	/* Enable the Rx interrupts for the first buffer */
-	out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
-		 XEL_RSR_RECV_IE_MASK);
+	__raw_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr + XEL_RSR_OFFSET);

 	/* Enable the Rx interrupts for the second Buffer if
 	 * configured in HW */
 	if (drvdata->rx_ping_pong != 0) {
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
-			 XEL_RSR_OFFSET,
-			 XEL_RSR_RECV_IE_MASK);
+		__raw_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr +
+			     XEL_BUFFER_OFFSET + XEL_RSR_OFFSET);
 	}

 	/* Enable the Global Interrupt Enable */
-	out_be32(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);
+	__raw_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
 }

 /**
@@ -201,37 +199,37 @@ static void xemaclite_disable_interrupts(struct net_local *drvdata)
 	u32 reg_data;

 	/* Disable the Global Interrupt Enable */
-	out_be32(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);
+	__raw_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);

 	/* Disable the Tx interrupts for the first buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_TSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_TSR_OFFSET,
-		 reg_data & (~XEL_TSR_XMIT_IE_MASK));
+	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	__raw_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
+		     drvdata->base_addr + XEL_TSR_OFFSET);

 	/* Disable the Tx interrupts for the second Buffer
 	 * if configured in HW */
 	if (drvdata->tx_ping_pong != 0) {
-		reg_data = in_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
 				   XEL_TSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
-			 XEL_TSR_OFFSET,
-			 reg_data & (~XEL_TSR_XMIT_IE_MASK));
+		__raw_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
+			     drvdata->base_addr + XEL_BUFFER_OFFSET +
+			     XEL_TSR_OFFSET);
 	}

 	/* Disable the Rx interrupts for the first buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_RSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
-		 reg_data & (~XEL_RSR_RECV_IE_MASK));
+	reg_data = __raw_readl(drvdata->base_addr + XEL_RSR_OFFSET);
+	__raw_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
+		     drvdata->base_addr + XEL_RSR_OFFSET);

 	/* Disable the Rx interrupts for the second buffer
 	 * if configured in HW */
 	if (drvdata->rx_ping_pong != 0) {

-		reg_data = in_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
 				   XEL_RSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
-			 XEL_RSR_OFFSET,
-			 reg_data & (~XEL_RSR_RECV_IE_MASK));
+		__raw_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
+			     drvdata->base_addr + XEL_BUFFER_OFFSET +
+			     XEL_RSR_OFFSET);
 	}
 }

@@ -351,7 +349,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 		byte_count = ETH_FRAME_LEN;

 	/* Check if the expected buffer is available */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
 	if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 	     XEL_TSR_XMIT_ACTIVE_MASK)) == 0) {

@@ -364,7 +362,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,

 		addr = (void __iomem __force *)((u32 __force)addr ^
 						 XEL_BUFFER_OFFSET);
-		reg_data = in_be32(addr + XEL_TSR_OFFSET);
+		reg_data = __raw_readl(addr + XEL_TSR_OFFSET);

 		if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 		     XEL_TSR_XMIT_ACTIVE_MASK)) != 0)
@@ -375,15 +373,16 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 	/* Write the frame to the buffer */
 	xemaclite_aligned_write(data, (u32 __force *) addr, byte_count);

-	out_be32(addr + XEL_TPLR_OFFSET, (byte_count & XEL_TPLR_LENGTH_MASK));
+	__raw_writel((byte_count & XEL_TPLR_LENGTH_MASK),
+		     addr + XEL_TPLR_OFFSET);

 	/* Update the Tx Status Register to indicate that there is a
 	 * frame to send. Set the XEL_TSR_XMIT_ACTIVE_MASK flag which
 	 * is used by the interrupt handler to check whether a frame
 	 * has been transmitted */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
 	reg_data |= (XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_XMIT_ACTIVE_MASK);
-	out_be32(addr + XEL_TSR_OFFSET, reg_data);
+	__raw_writel(reg_data, addr + XEL_TSR_OFFSET);

 	return 0;
 }
@@ -408,7 +407,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	addr = (drvdata->base_addr + drvdata->next_rx_buf_to_use);

 	/* Verify which buffer has valid data */
-	reg_data = in_be32(addr + XEL_RSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);

 	if ((reg_data & XEL_RSR_RECV_DONE_MASK) == XEL_RSR_RECV_DONE_MASK) {
 		if (drvdata->rx_ping_pong != 0)
@@ -425,14 +424,14 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 			return 0;	/* No data was available */

 		/* Verify that buffer has valid data */
-		reg_data = in_be32(addr + XEL_RSR_OFFSET);
+		reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
 		if ((reg_data & XEL_RSR_RECV_DONE_MASK) !=
 		     XEL_RSR_RECV_DONE_MASK)
 			return 0;	/* No data was available */
 	}

 	/* Get the protocol type of the ethernet frame that arrived */
-	proto_type = ((ntohl(in_be32(addr + XEL_HEADER_OFFSET +
+	proto_type = ((ntohl(__raw_readl(addr + XEL_HEADER_OFFSET +
 			XEL_RXBUFF_OFFSET)) >> XEL_HEADER_SHIFT) &
 			XEL_RPLR_LENGTH_MASK);

@@ -441,7 +440,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	if (proto_type > (ETH_FRAME_LEN + ETH_FCS_LEN)) {

 		if (proto_type == ETH_P_IP) {
-			length = ((ntohl(in_be32(addr +
+			length = ((ntohl(__raw_readl(addr +
 					XEL_HEADER_IP_LENGTH_OFFSET +
 					XEL_RXBUFF_OFFSET)) >>
 					XEL_HEADER_SHIFT) &
@@ -463,9 +462,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 				data, length);

 	/* Acknowledge the frame */
-	reg_data = in_be32(addr + XEL_RSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
 	reg_data &= ~XEL_RSR_RECV_DONE_MASK;
-	out_be32(addr + XEL_RSR_OFFSET, reg_data);
+	__raw_writel(reg_data, addr + XEL_RSR_OFFSET);

 	return length;
 }
@@ -492,14 +491,14 @@ static void xemaclite_update_address(struct net_local *drvdata,

 	xemaclite_aligned_write(address_ptr, (u32 __force *) addr, ETH_ALEN);

-	out_be32(addr + XEL_TPLR_OFFSET, ETH_ALEN);
+	__raw_writel(ETH_ALEN, addr + XEL_TPLR_OFFSET);

 	/* Update the MAC address in the EmacLite */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
-	out_be32(addr + XEL_TSR_OFFSET, reg_data | XEL_TSR_PROG_MAC_ADDR);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
+	__raw_writel(reg_data | XEL_TSR_PROG_MAC_ADDR, addr + XEL_TSR_OFFSET);

 	/* Wait for EmacLite to finish with the MAC address update */
-	while ((in_be32(addr + XEL_TSR_OFFSET) &
+	while ((__raw_readl(addr + XEL_TSR_OFFSET) &
 		XEL_TSR_PROG_MAC_ADDR) != 0)
 		;
 }
@@ -669,31 +668,32 @@ static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
 	u32 tx_status;

 	/* Check if there is Rx Data available */
-	if ((in_be32(base_addr + XEL_RSR_OFFSET) & XEL_RSR_RECV_DONE_MASK) ||
-			(in_be32(base_addr + XEL_BUFFER_OFFSET + XEL_RSR_OFFSET)
+	if ((__raw_readl(base_addr + XEL_RSR_OFFSET) &
+			 XEL_RSR_RECV_DONE_MASK) ||
+	    (__raw_readl(base_addr + XEL_BUFFER_OFFSET + XEL_RSR_OFFSET)
 			 & XEL_RSR_RECV_DONE_MASK))

 		xemaclite_rx_handler(dev);

 	/* Check if the Transmission for the first buffer is completed */
-	tx_status = in_be32(base_addr + XEL_TSR_OFFSET);
+	tx_status = __raw_readl(base_addr + XEL_TSR_OFFSET);
 	if (((tx_status & XEL_TSR_XMIT_BUSY_MASK) == 0) &&
 		(tx_status & XEL_TSR_XMIT_ACTIVE_MASK) != 0) {

 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
-		out_be32(base_addr + XEL_TSR_OFFSET, tx_status);
+		__raw_writel(tx_status, base_addr + XEL_TSR_OFFSET);

 		tx_complete = true;
 	}

 	/* Check if the Transmission for the second buffer is completed */
-	tx_status = in_be32(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
+	tx_status = __raw_readl(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
 	if (((tx_status & XEL_TSR_XMIT_BUSY_MASK) == 0) &&
 		(tx_status & XEL_TSR_XMIT_ACTIVE_MASK) != 0) {

 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
-		out_be32(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET,
-			 tx_status);
+		__raw_writel(tx_status, base_addr + XEL_BUFFER_OFFSET +
+			     XEL_TSR_OFFSET);

 		tx_complete = true;
 	}
@@ -726,7 +726,7 @@ static int xemaclite_mdio_wait(struct net_local *lp)
 	/* wait for the MDIO interface to not be busy or timeout
 	   after some time.
 	*/
-	while (in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
+	while (__raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
 			XEL_MDIOCTRL_MDIOSTS_MASK) {
 		if (end - jiffies <= 0) {
 			WARN_ON(1);
@@ -762,17 +762,17 @@ static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	 * MDIO Address register. Set the Status bit in the MDIO Control
 	 * register to start a MDIO read transaction.
 	 */
-	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
-		 XEL_MDIOADDR_OP_MASK |
-		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
-		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);
+	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	__raw_writel(XEL_MDIOADDR_OP_MASK |
+		     ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
+		     lp->base_addr + XEL_MDIOADDR_OFFSET);
+	__raw_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
+		     lp->base_addr + XEL_MDIOCTRL_OFFSET);

 	if (xemaclite_mdio_wait(lp))
 		return -ETIMEDOUT;

-	rc = in_be32(lp->base_addr + XEL_MDIORD_OFFSET);
+	rc = __raw_readl(lp->base_addr + XEL_MDIORD_OFFSET);

 	dev_dbg(&lp->ndev->dev,
 		"xemaclite_mdio_read(phy_id=%i, reg=%x) == %x\n",
@@ -809,13 +809,13 @@ static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
 	 * Data register. Finally, set the Status bit in the MDIO Control
 	 * register to start a MDIO write transaction.
 	 */
-	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
-		 ~XEL_MDIOADDR_OP_MASK &
-		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
-	out_be32(lp->base_addr + XEL_MDIOWR_OFFSET, val);
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
-		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);
+	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	__raw_writel(~XEL_MDIOADDR_OP_MASK &
+		     ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg),
+		     lp->base_addr + XEL_MDIOADDR_OFFSET);
+	__raw_writel(val, lp->base_addr + XEL_MDIOWR_OFFSET);
+	__raw_writel(ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK,
+		     lp->base_addr + XEL_MDIOCTRL_OFFSET);

 	return 0;
 }
@@ -872,8 +872,8 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
 	 * register.
 	 */
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
-		 XEL_MDIOCTRL_MDIOEN_MASK);
+	__raw_writel(XEL_MDIOCTRL_MDIOEN_MASK,
+		     lp->base_addr + XEL_MDIOCTRL_OFFSET);

 	bus = mdiobus_alloc();
 	if (!bus) {
@@ -1197,8 +1197,8 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 		dev_warn(dev, "No MAC address found\n");

 	/* Clear the Tx CSR's in case this is a restart */
-	out_be32(lp->base_addr + XEL_TSR_OFFSET, 0);
-	out_be32(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET, 0);
+	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
+	__raw_writel(0, lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);

 	/* Set the MAC address in the EmacLite device */
 	xemaclite_update_address(lp, ndev->dev_addr);
--
1.8.2.3


--=_mimegpg-monstr-desktop-5484-1369909698-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGnKcIACgkQykllyylKDCGApgCghcH/j8yHtTpBrJq2kWJoPOTJ
EFoAn1A6jTvmMJROI2nwW1ysFzmSYNUN
=DFdZ
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-5484-1369909698-0001--
