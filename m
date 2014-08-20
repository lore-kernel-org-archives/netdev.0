From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 4/8] staging: et131x: Use for loop to initialise contiguous
 macstat registers to zero
Date: Wed, 20 Aug 2014 23:17:54 +0100
Message-ID: <1408573078-9320-5-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Replace a long list of contiguous writel() calls with a for loop iterating
over the same address values.

Also remove redundant comments on the macstat registers, the variable names
are good enough.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 59 +++----------------------
 drivers/staging/et131x/et131x.h | 96 +----------------------------------------
 2 files changed, 7 insertions(+), 148 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 44cc684..fc18e8d 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -1257,60 +1257,13 @@ static void et1310_config_txmac_regs(struct et131x_adapter *adapter)
 
 static void et1310_config_macstat_regs(struct et131x_adapter *adapter)
 {
-	struct macstat_regs __iomem *macstat =
-		&adapter->regs->macstat;
+	struct macstat_regs __iomem *macstat = &adapter->regs->macstat;
+	u32 *reg;
 
-	/* Next we need to initialize all the macstat registers to zero on
-	 * the device.
-	 */
-	writel(0, &macstat->txrx_0_64_byte_frames);
-	writel(0, &macstat->txrx_65_127_byte_frames);
-	writel(0, &macstat->txrx_128_255_byte_frames);
-	writel(0, &macstat->txrx_256_511_byte_frames);
-	writel(0, &macstat->txrx_512_1023_byte_frames);
-	writel(0, &macstat->txrx_1024_1518_byte_frames);
-	writel(0, &macstat->txrx_1519_1522_gvln_frames);
-
-	writel(0, &macstat->rx_bytes);
-	writel(0, &macstat->rx_packets);
-	writel(0, &macstat->rx_fcs_errs);
-	writel(0, &macstat->rx_multicast_packets);
-	writel(0, &macstat->rx_broadcast_packets);
-	writel(0, &macstat->rx_control_frames);
-	writel(0, &macstat->rx_pause_frames);
-	writel(0, &macstat->rx_unknown_opcodes);
-	writel(0, &macstat->rx_align_errs);
-	writel(0, &macstat->rx_frame_len_errs);
-	writel(0, &macstat->rx_code_errs);
-	writel(0, &macstat->rx_carrier_sense_errs);
-	writel(0, &macstat->rx_undersize_packets);
-	writel(0, &macstat->rx_oversize_packets);
-	writel(0, &macstat->rx_fragment_packets);
-	writel(0, &macstat->rx_jabbers);
-	writel(0, &macstat->rx_drops);
-
-	writel(0, &macstat->tx_bytes);
-	writel(0, &macstat->tx_packets);
-	writel(0, &macstat->tx_multicast_packets);
-	writel(0, &macstat->tx_broadcast_packets);
-	writel(0, &macstat->tx_pause_frames);
-	writel(0, &macstat->tx_deferred);
-	writel(0, &macstat->tx_excessive_deferred);
-	writel(0, &macstat->tx_single_collisions);
-	writel(0, &macstat->tx_multiple_collisions);
-	writel(0, &macstat->tx_late_collisions);
-	writel(0, &macstat->tx_excessive_collisions);
-	writel(0, &macstat->tx_total_collisions);
-	writel(0, &macstat->tx_pause_honored_frames);
-	writel(0, &macstat->tx_drops);
-	writel(0, &macstat->tx_jabbers);
-	writel(0, &macstat->tx_fcs_errs);
-	writel(0, &macstat->tx_control_frames);
-	writel(0, &macstat->tx_oversize_frames);
-	writel(0, &macstat->tx_undersize_frames);
-	writel(0, &macstat->tx_fragments);
-	writel(0, &macstat->carry_reg1);
-	writel(0, &macstat->carry_reg2);
+	/* initialize all the macstat registers to zero on the device  */
+	for (reg = &macstat->txrx_0_64_byte_frames;
+	     reg <= &macstat->carry_reg2; reg++)
+		writel(0, reg);
 
 	/* Unmask any counters that we want to track the overflow of.
 	 * Initially this will be all counters.  It may become clear later
diff --git a/drivers/staging/et131x/et131x.h b/drivers/staging/et131x/et131x.h
index 1318439..95d6d45 100644
--- a/drivers/staging/et131x/et131x.h
+++ b/drivers/staging/et131x/et131x.h
@@ -1259,148 +1259,54 @@ struct mac_regs {					/* Location: */
 struct macstat_regs {			/* Location: */
 	u32 pad[32];			/*  0x6000 - 607C */
 
-	/* Tx/Rx 0-64 Byte Frame Counter */
+	/* counters */
 	u32 txrx_0_64_byte_frames;	/*  0x6080 */
-
-	/* Tx/Rx 65-127 Byte Frame Counter */
 	u32 txrx_65_127_byte_frames;	/*  0x6084 */
-
-	/* Tx/Rx 128-255 Byte Frame Counter */
 	u32 txrx_128_255_byte_frames;	/*  0x6088 */
-
-	/* Tx/Rx 256-511 Byte Frame Counter */
 	u32 txrx_256_511_byte_frames;	/*  0x608C */
-
-	/* Tx/Rx 512-1023 Byte Frame Counter */
 	u32 txrx_512_1023_byte_frames;	/*  0x6090 */
-
-	/* Tx/Rx 1024-1518 Byte Frame Counter */
 	u32 txrx_1024_1518_byte_frames;	/*  0x6094 */
-
-	/* Tx/Rx 1519-1522 Byte Good VLAN Frame Count */
 	u32 txrx_1519_1522_gvln_frames;	/*  0x6098 */
-
-	/* Rx Byte Counter */
 	u32 rx_bytes;			/*  0x609C */
-
-	/* Rx Packet Counter */
 	u32 rx_packets;			/*  0x60A0 */
-
-	/* Rx FCS Error Counter */
 	u32 rx_fcs_errs;		/*  0x60A4 */
-
-	/* Rx Multicast Packet Counter */
 	u32 rx_multicast_packets;	/*  0x60A8 */
-
-	/* Rx Broadcast Packet Counter */
 	u32 rx_broadcast_packets;	/*  0x60AC */
-
-	/* Rx Control Frame Packet Counter */
 	u32 rx_control_frames;		/*  0x60B0 */
-
-	/* Rx Pause Frame Packet Counter */
 	u32 rx_pause_frames;		/*  0x60B4 */
-
-	/* Rx Unknown OP Code Counter */
 	u32 rx_unknown_opcodes;		/*  0x60B8 */
-
-	/* Rx Alignment Error Counter */
 	u32 rx_align_errs;		/*  0x60BC */
-
-	/* Rx Frame Length Error Counter */
 	u32 rx_frame_len_errs;		/*  0x60C0 */
-
-	/* Rx Code Error Counter */
 	u32 rx_code_errs;		/*  0x60C4 */
-
-	/* Rx Carrier Sense Error Counter */
 	u32 rx_carrier_sense_errs;	/*  0x60C8 */
-
-	/* Rx Undersize Packet Counter */
 	u32 rx_undersize_packets;	/*  0x60CC */
-
-	/* Rx Oversize Packet Counter */
 	u32 rx_oversize_packets;	/*  0x60D0 */
-
-	/* Rx Fragment Counter */
 	u32 rx_fragment_packets;	/*  0x60D4 */
-
-	/* Rx Jabber Counter */
 	u32 rx_jabbers;			/*  0x60D8 */
-
-	/* Rx Drop */
 	u32 rx_drops;			/*  0x60DC */
-
-	/* Tx Byte Counter */
 	u32 tx_bytes;			/*  0x60E0 */
-
-	/* Tx Packet Counter */
 	u32 tx_packets;			/*  0x60E4 */
-
-	/* Tx Multicast Packet Counter */
 	u32 tx_multicast_packets;	/*  0x60E8 */
-
-	/* Tx Broadcast Packet Counter */
 	u32 tx_broadcast_packets;	/*  0x60EC */
-
-	/* Tx Pause Control Frame Counter */
 	u32 tx_pause_frames;		/*  0x60F0 */
-
-	/* Tx Deferral Packet Counter */
 	u32 tx_deferred;		/*  0x60F4 */
-
-	/* Tx Excessive Deferral Packet Counter */
 	u32 tx_excessive_deferred;	/*  0x60F8 */
-
-	/* Tx Single Collision Packet Counter */
 	u32 tx_single_collisions;	/*  0x60FC */
-
-	/* Tx Multiple Collision Packet Counter */
 	u32 tx_multiple_collisions;	/*  0x6100 */
-
-	/* Tx Late Collision Packet Counter */
 	u32 tx_late_collisions;		/*  0x6104 */
-
-	/* Tx Excessive Collision Packet Counter */
 	u32 tx_excessive_collisions;	/*  0x6108 */
-
-	/* Tx Total Collision Packet Counter */
 	u32 tx_total_collisions;	/*  0x610C */
-
-	/* Tx Pause Frame Honored Counter */
 	u32 tx_pause_honored_frames;	/*  0x6110 */
-
-	/* Tx Drop Frame Counter */
 	u32 tx_drops;			/*  0x6114 */
-
-	/* Tx Jabber Frame Counter */
 	u32 tx_jabbers;			/*  0x6118 */
-
-	/* Tx FCS Error Counter */
 	u32 tx_fcs_errs;		/*  0x611C */
-
-	/* Tx Control Frame Counter */
 	u32 tx_control_frames;		/*  0x6120 */
-
-	/* Tx Oversize Frame Counter */
 	u32 tx_oversize_frames;		/*  0x6124 */
-
-	/* Tx Undersize Frame Counter */
 	u32 tx_undersize_frames;	/*  0x6128 */
-
-	/* Tx Fragments Frame Counter */
 	u32 tx_fragments;		/*  0x612C */
-
-	/* Carry Register One Register */
 	u32 carry_reg1;			/*  0x6130 */
-
-	/* Carry Register Two Register */
 	u32 carry_reg2;			/*  0x6134 */
-
-	/* Carry Register One Mask Register */
 	u32 carry_reg1_mask;		/*  0x6138 */
-
-	/* Carry Register Two Mask Register */
 	u32 carry_reg2_mask;		/*  0x613C */
 };
 
-- 
2.1.0
