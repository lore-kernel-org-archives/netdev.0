From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 09/11] net: emaclite: Do not use microblaze and ppc IO functions
Date: Wed, 29 May 2013 17:33:09 +0200
Message-ID: <146169cddc068c371889e699fde4fe5129f02201.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27655-1369841619-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27655-1369841619-0001

Emaclite can be used on ARM zynq where in_be32/out_be32 IO
functions are not present. Use standard __raw_readl/__raw_writel
IO functions instead.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 100 +++++++++++++-------------
 1 file changed, 51 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 93bb14e..0d8515b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -159,34 +159,34 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
 	u32 reg_data;

 	/* Enable the Tx interrupts for the first Buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_TSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_TSR_OFFSET,
+	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	__raw_writel(drvdata->base_addr + XEL_TSR_OFFSET,
 		 reg_data | XEL_TSR_XMIT_IE_MASK);

 	/* Enable the Tx interrupts for the second Buffer if
 	 * configured in HW */
 	if (drvdata->tx_ping_pong != 0) {
-		reg_data = in_be32(drvdata->base_addr +
+		reg_data = __raw_readl(drvdata->base_addr +
 				   XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		__raw_writel(drvdata->base_addr + XEL_BUFFER_OFFSET +
 			 XEL_TSR_OFFSET,
 			 reg_data | XEL_TSR_XMIT_IE_MASK);
 	}

 	/* Enable the Rx interrupts for the first buffer */
-	out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
+	__raw_writel(drvdata->base_addr + XEL_RSR_OFFSET,
 		 XEL_RSR_RECV_IE_MASK);

 	/* Enable the Rx interrupts for the second Buffer if
 	 * configured in HW */
 	if (drvdata->rx_ping_pong != 0) {
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		__raw_writel(drvdata->base_addr + XEL_BUFFER_OFFSET +
 			 XEL_RSR_OFFSET,
 			 XEL_RSR_RECV_IE_MASK);
 	}

 	/* Enable the Global Interrupt Enable */
-	out_be32(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);
+	__raw_writel(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);
 }

 /**
@@ -201,35 +201,35 @@ static void xemaclite_disable_interrupts(struct net_local *drvdata)
 	u32 reg_data;

 	/* Disable the Global Interrupt Enable */
-	out_be32(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);
+	__raw_writel(drvdata->base_addr + XEL_GIER_OFFSET, XEL_GIER_GIE_MASK);

 	/* Disable the Tx interrupts for the first buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_TSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_TSR_OFFSET,
+	reg_data = __raw_readl(drvdata->base_addr + XEL_TSR_OFFSET);
+	__raw_writel(drvdata->base_addr + XEL_TSR_OFFSET,
 		 reg_data & (~XEL_TSR_XMIT_IE_MASK));

 	/* Disable the Tx interrupts for the second Buffer
 	 * if configured in HW */
 	if (drvdata->tx_ping_pong != 0) {
-		reg_data = in_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
 				   XEL_TSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		__raw_writel(drvdata->base_addr + XEL_BUFFER_OFFSET +
 			 XEL_TSR_OFFSET,
 			 reg_data & (~XEL_TSR_XMIT_IE_MASK));
 	}

 	/* Disable the Rx interrupts for the first buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_RSR_OFFSET);
-	out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
+	reg_data = __raw_readl(drvdata->base_addr + XEL_RSR_OFFSET);
+	__raw_writel(drvdata->base_addr + XEL_RSR_OFFSET,
 		 reg_data & (~XEL_RSR_RECV_IE_MASK));

 	/* Disable the Rx interrupts for the second buffer
 	 * if configured in HW */
 	if (drvdata->rx_ping_pong != 0) {

-		reg_data = in_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
 				   XEL_RSR_OFFSET);
-		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
+		__raw_writel(drvdata->base_addr + XEL_BUFFER_OFFSET +
 			 XEL_RSR_OFFSET,
 			 reg_data & (~XEL_RSR_RECV_IE_MASK));
 	}
@@ -351,7 +351,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 		byte_count = ETH_FRAME_LEN;

 	/* Check if the expected buffer is available */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
 	if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 	     XEL_TSR_XMIT_ACTIVE_MASK)) == 0) {

@@ -364,7 +364,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,

 		addr = (void __iomem __force *)((u32 __force)addr ^
 						 XEL_BUFFER_OFFSET);
-		reg_data = in_be32(addr + XEL_TSR_OFFSET);
+		reg_data = __raw_readl(addr + XEL_TSR_OFFSET);

 		if ((reg_data & (XEL_TSR_XMIT_BUSY_MASK |
 		     XEL_TSR_XMIT_ACTIVE_MASK)) != 0)
@@ -375,15 +375,16 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
 	/* Write the frame to the buffer */
 	xemaclite_aligned_write(data, (u32 __force *) addr, byte_count);

-	out_be32(addr + XEL_TPLR_OFFSET, (byte_count & XEL_TPLR_LENGTH_MASK));
+	__raw_writel(addr + XEL_TPLR_OFFSET,
+		     (byte_count & XEL_TPLR_LENGTH_MASK));

 	/* Update the Tx Status Register to indicate that there is a
 	 * frame to send. Set the XEL_TSR_XMIT_ACTIVE_MASK flag which
 	 * is used by the interrupt handler to check whether a frame
 	 * has been transmitted */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
 	reg_data |= (XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_XMIT_ACTIVE_MASK);
-	out_be32(addr + XEL_TSR_OFFSET, reg_data);
+	__raw_writel(addr + XEL_TSR_OFFSET, reg_data);

 	return 0;
 }
@@ -408,7 +409,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	addr = (drvdata->base_addr + drvdata->next_rx_buf_to_use);

 	/* Verify which buffer has valid data */
-	reg_data = in_be32(addr + XEL_RSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);

 	if ((reg_data & XEL_RSR_RECV_DONE_MASK) == XEL_RSR_RECV_DONE_MASK) {
 		if (drvdata->rx_ping_pong != 0)
@@ -425,14 +426,14 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
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

@@ -441,7 +442,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 	if (proto_type > (ETH_FRAME_LEN + ETH_FCS_LEN)) {

 		if (proto_type == ETH_P_IP) {
-			length = ((ntohl(in_be32(addr +
+			length = ((ntohl(__raw_readl(addr +
 					XEL_HEADER_IP_LENGTH_OFFSET +
 					XEL_RXBUFF_OFFSET)) >>
 					XEL_HEADER_SHIFT) &
@@ -463,9 +464,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 				data, length);

 	/* Acknowledge the frame */
-	reg_data = in_be32(addr + XEL_RSR_OFFSET);
+	reg_data = __raw_readl(addr + XEL_RSR_OFFSET);
 	reg_data &= ~XEL_RSR_RECV_DONE_MASK;
-	out_be32(addr + XEL_RSR_OFFSET, reg_data);
+	__raw_writel(addr + XEL_RSR_OFFSET, reg_data);

 	return length;
 }
@@ -492,14 +493,14 @@ static void xemaclite_update_address(struct net_local *drvdata,

 	xemaclite_aligned_write(address_ptr, (u32 __force *) addr, ETH_ALEN);

-	out_be32(addr + XEL_TPLR_OFFSET, ETH_ALEN);
+	__raw_writel(addr + XEL_TPLR_OFFSET, ETH_ALEN);

 	/* Update the MAC address in the EmacLite */
-	reg_data = in_be32(addr + XEL_TSR_OFFSET);
-	out_be32(addr + XEL_TSR_OFFSET, reg_data | XEL_TSR_PROG_MAC_ADDR);
+	reg_data = __raw_readl(addr + XEL_TSR_OFFSET);
+	__raw_writel(addr + XEL_TSR_OFFSET, reg_data | XEL_TSR_PROG_MAC_ADDR);

 	/* Wait for EmacLite to finish with the MAC address update */
-	while ((in_be32(addr + XEL_TSR_OFFSET) &
+	while ((__raw_readl(addr + XEL_TSR_OFFSET) &
 		XEL_TSR_PROG_MAC_ADDR) != 0)
 		;
 }
@@ -669,30 +670,31 @@ static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
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
+		__raw_writel(base_addr + XEL_TSR_OFFSET, tx_status);

 		tx_complete = true;
 	}

 	/* Check if the Transmission for the second buffer is completed */
-	tx_status = in_be32(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
+	tx_status = __raw_readl(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
 	if (((tx_status & XEL_TSR_XMIT_BUSY_MASK) == 0) &&
 		(tx_status & XEL_TSR_XMIT_ACTIVE_MASK) != 0) {

 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
-		out_be32(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET,
+		__raw_writel(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET,
 			 tx_status);

 		tx_complete = true;
@@ -726,7 +728,7 @@ static int xemaclite_mdio_wait(struct net_local *lp)
 	/* wait for the MDIO interface to not be busy or timeout
 	   after some time.
 	*/
-	while (in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
+	while (__raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
 			XEL_MDIOCTRL_MDIOSTS_MASK) {
 		if (end - jiffies <= 0) {
 			WARN_ON(1);
@@ -762,17 +764,17 @@ static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	 * MDIO Address register. Set the Status bit in the MDIO Control
 	 * register to start a MDIO read transaction.
 	 */
-	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
+	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	__raw_writel(lp->base_addr + XEL_MDIOADDR_OFFSET,
 		 XEL_MDIOADDR_OP_MASK |
 		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+	__raw_writel(lp->base_addr + XEL_MDIOCTRL_OFFSET,
 		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);

 	if (xemaclite_mdio_wait(lp))
 		return -ETIMEDOUT;

-	rc = in_be32(lp->base_addr + XEL_MDIORD_OFFSET);
+	rc = __raw_readl(lp->base_addr + XEL_MDIORD_OFFSET);

 	dev_dbg(&lp->ndev->dev,
 		"xemaclite_mdio_read(phy_id=%i, reg=%x) == %x\n",
@@ -809,12 +811,12 @@ static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
 	 * Data register. Finally, set the Status bit in the MDIO Control
 	 * register to start a MDIO write transaction.
 	 */
-	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
-	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
+	ctrl_reg = __raw_readl(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	__raw_writel(lp->base_addr + XEL_MDIOADDR_OFFSET,
 		 ~XEL_MDIOADDR_OP_MASK &
 		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
-	out_be32(lp->base_addr + XEL_MDIOWR_OFFSET, val);
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+	__raw_writel(lp->base_addr + XEL_MDIOWR_OFFSET, val);
+	__raw_writel(lp->base_addr + XEL_MDIOCTRL_OFFSET,
 		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);

 	return 0;
@@ -872,7 +874,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
 	 * register.
 	 */
-	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+	__raw_writel(lp->base_addr + XEL_MDIOCTRL_OFFSET,
 		 XEL_MDIOCTRL_MDIOEN_MASK);

 	bus = mdiobus_alloc();
@@ -1197,8 +1199,8 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 		dev_warn(dev, "No MAC address found\n");

 	/* Clear the Tx CSR's in case this is a restart */
-	out_be32(lp->base_addr + XEL_TSR_OFFSET, 0);
-	out_be32(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET, 0);
+	__raw_writel(lp->base_addr + XEL_TSR_OFFSET, 0);
+	__raw_writel(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET, 0);

 	/* Set the MAC address in the EmacLite device */
 	xemaclite_update_address(lp, ndev->dev_addr);
--
1.8.2.3


--=_mimegpg-monstr-desktop-27655-1369841619-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH9MACgkQykllyylKDCHUsACeIFv7W0sL78i0hcEnNt5RxCYs
qrsAn2JPY5edc6oG2UKND95RjGktdCcP
=SeT1
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27655-1369841619-0001--
