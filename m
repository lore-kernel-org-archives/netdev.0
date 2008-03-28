From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/8] e1000e: Make arrays out of these Rx/Tx
	registers
Date: Fri, 28 Mar 2008 09:15:26 -0700
Message-ID: <20080328161526.6562.29621.stgit@localhost.localdomain>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080328161503.6562.44329.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

With multiple queues coming into the code these base control
registers need to be made into arrays.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |   24 ++++++++++++------------
 drivers/net/e1000e/es2lan.c  |   24 ++++++++++++------------
 drivers/net/e1000e/hw.h      |   10 ++++++----
 drivers/net/e1000e/ich8lan.c |   24 ++++++++++++------------
 drivers/net/e1000e/netdev.c  |   16 ++++++++--------
 5 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 9b46a00..85e4764 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -836,19 +836,19 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	ret_val = e1000_setup_link_82571(hw);
 
 	/* Set the transmit descriptor write-back policy */
-	reg_data = er32(TXDCTL);
+	reg_data = er32(TXDCTL(0));
 	reg_data = (reg_data & ~E1000_TXDCTL_WTHRESH) |
 		   E1000_TXDCTL_FULL_TX_DESC_WB |
 		   E1000_TXDCTL_COUNT_DESC;
-	ew32(TXDCTL, reg_data);
+	ew32(TXDCTL(0), reg_data);
 
 	/* ...for both queues. */
 	if (mac->type != e1000_82573) {
-		reg_data = er32(TXDCTL1);
+		reg_data = er32(TXDCTL(1));
 		reg_data = (reg_data & ~E1000_TXDCTL_WTHRESH) |
 			   E1000_TXDCTL_FULL_TX_DESC_WB |
 			   E1000_TXDCTL_COUNT_DESC;
-		ew32(TXDCTL1, reg_data);
+		ew32(TXDCTL(1), reg_data);
 	} else {
 		e1000e_enable_tx_pkt_filtering(hw);
 		reg_data = er32(GCR);
@@ -878,17 +878,17 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 	u32 reg;
 
 	/* Transmit Descriptor Control 0 */
-	reg = er32(TXDCTL);
+	reg = er32(TXDCTL(0));
 	reg |= (1 << 22);
-	ew32(TXDCTL, reg);
+	ew32(TXDCTL(0), reg);
 
 	/* Transmit Descriptor Control 1 */
-	reg = er32(TXDCTL1);
+	reg = er32(TXDCTL(1));
 	reg |= (1 << 22);
-	ew32(TXDCTL1, reg);
+	ew32(TXDCTL(1), reg);
 
 	/* Transmit Arbitration Control 0 */
-	reg = er32(TARC0);
+	reg = er32(TARC(0));
 	reg &= ~(0xF << 27); /* 30:27 */
 	switch (hw->mac.type) {
 	case e1000_82571:
@@ -898,10 +898,10 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 	default:
 		break;
 	}
-	ew32(TARC0, reg);
+	ew32(TARC(0), reg);
 
 	/* Transmit Arbitration Control 1 */
-	reg = er32(TARC1);
+	reg = er32(TARC(1));
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
@@ -911,7 +911,7 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 			reg &= ~(1 << 28);
 		else
 			reg |= (1 << 28);
-		ew32(TARC1, reg);
+		ew32(TARC(1), reg);
 		break;
 	default:
 		break;
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 2689e4b..10e17cf 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -792,16 +792,16 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	ret_val = e1000e_setup_link(hw);
 
 	/* Set the transmit descriptor write-back policy */
-	reg_data = er32(TXDCTL);
+	reg_data = er32(TXDCTL(0));
 	reg_data = (reg_data & ~E1000_TXDCTL_WTHRESH) |
 		   E1000_TXDCTL_FULL_TX_DESC_WB | E1000_TXDCTL_COUNT_DESC;
-	ew32(TXDCTL, reg_data);
+	ew32(TXDCTL(0), reg_data);
 
 	/* ...for both queues. */
-	reg_data = er32(TXDCTL1);
+	reg_data = er32(TXDCTL(1));
 	reg_data = (reg_data & ~E1000_TXDCTL_WTHRESH) |
 		   E1000_TXDCTL_FULL_TX_DESC_WB | E1000_TXDCTL_COUNT_DESC;
-	ew32(TXDCTL1, reg_data);
+	ew32(TXDCTL(1), reg_data);
 
 	/* Enable retransmit on late collisions */
 	reg_data = er32(TCTL);
@@ -846,29 +846,29 @@ static void e1000_initialize_hw_bits_80003es2lan(struct e1000_hw *hw)
 	u32 reg;
 
 	/* Transmit Descriptor Control 0 */
-	reg = er32(TXDCTL);
+	reg = er32(TXDCTL(0));
 	reg |= (1 << 22);
-	ew32(TXDCTL, reg);
+	ew32(TXDCTL(0), reg);
 
 	/* Transmit Descriptor Control 1 */
-	reg = er32(TXDCTL1);
+	reg = er32(TXDCTL(1));
 	reg |= (1 << 22);
-	ew32(TXDCTL1, reg);
+	ew32(TXDCTL(1), reg);
 
 	/* Transmit Arbitration Control 0 */
-	reg = er32(TARC0);
+	reg = er32(TARC(0));
 	reg &= ~(0xF << 27); /* 30:27 */
 	if (hw->phy.media_type != e1000_media_type_copper)
 		reg &= ~(1 << 20);
-	ew32(TARC0, reg);
+	ew32(TARC(0), reg);
 
 	/* Transmit Arbitration Control 1 */
-	reg = er32(TARC1);
+	reg = er32(TARC(1));
 	if (er32(TCTL) & E1000_TCTL_MULR)
 		reg &= ~(1 << 28);
 	else
 		reg |= (1 << 28);
-	ew32(TARC1, reg);
+	ew32(TARC(1), reg);
 }
 
 /**
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 0b4145a..53f1ac6 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -93,6 +93,8 @@ enum e1e_registers {
 	E1000_RDH      = 0x02810, /* Rx Descriptor Head - RW */
 	E1000_RDT      = 0x02818, /* Rx Descriptor Tail - RW */
 	E1000_RDTR     = 0x02820, /* Rx Delay Timer - RW */
+	E1000_RXDCTL_BASE = 0x02828, /* Rx Descriptor Control - RW */
+#define E1000_RXDCTL(_n)   (E1000_RXDCTL_BASE + (_n << 8))
 	E1000_RADV     = 0x0282C, /* RX Interrupt Absolute Delay Timer - RW */
 
 /* Convenience macros
@@ -111,11 +113,11 @@ enum e1e_registers {
 	E1000_TDH      = 0x03810, /* Tx Descriptor Head - RW */
 	E1000_TDT      = 0x03818, /* Tx Descriptor Tail - RW */
 	E1000_TIDV     = 0x03820, /* Tx Interrupt Delay Value - RW */
-	E1000_TXDCTL   = 0x03828, /* Tx Descriptor Control - RW */
+	E1000_TXDCTL_BASE = 0x03828, /* Tx Descriptor Control - RW */
+#define E1000_TXDCTL(_n)   (E1000_TXDCTL_BASE + (_n << 8))
 	E1000_TADV     = 0x0382C, /* Tx Interrupt Absolute Delay Val - RW */
-	E1000_TARC0    = 0x03840, /* Tx Arbitration Count (0) */
-	E1000_TXDCTL1  = 0x03928, /* Tx Descriptor Control (1) - RW */
-	E1000_TARC1    = 0x03940, /* Tx Arbitration Count (1) */
+	E1000_TARC_BASE = 0x03840, /* Tx Arbitration Count (0) */
+#define E1000_TARC(_n)   (E1000_TARC_BASE + (_n << 8))
 	E1000_CRCERRS  = 0x04000, /* CRC Error Count - R/clr */
 	E1000_ALGNERRC = 0x04004, /* Alignment Error Count - R/clr */
 	E1000_SYMERRS  = 0x04008, /* Symbol Error Count - R/clr */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index e358a77..bbb51e1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1753,18 +1753,18 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000_setup_link_ich8lan(hw);
 
 	/* Set the transmit descriptor write-back policy for both queues */
-	txdctl = er32(TXDCTL);
+	txdctl = er32(TXDCTL(0));
 	txdctl = (txdctl & ~E1000_TXDCTL_WTHRESH) |
 		 E1000_TXDCTL_FULL_TX_DESC_WB;
 	txdctl = (txdctl & ~E1000_TXDCTL_PTHRESH) |
 		 E1000_TXDCTL_MAX_TX_DESC_PREFETCH;
-	ew32(TXDCTL, txdctl);
-	txdctl = er32(TXDCTL1);
+	ew32(TXDCTL(0), txdctl);
+	txdctl = er32(TXDCTL(1));
 	txdctl = (txdctl & ~E1000_TXDCTL_WTHRESH) |
 		 E1000_TXDCTL_FULL_TX_DESC_WB;
 	txdctl = (txdctl & ~E1000_TXDCTL_PTHRESH) |
 		 E1000_TXDCTL_MAX_TX_DESC_PREFETCH;
-	ew32(TXDCTL1, txdctl);
+	ew32(TXDCTL(1), txdctl);
 
 	/*
 	 * ICH8 has opposite polarity of no_snoop bits.
@@ -1807,30 +1807,30 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL_EXT, reg);
 
 	/* Transmit Descriptor Control 0 */
-	reg = er32(TXDCTL);
+	reg = er32(TXDCTL(0));
 	reg |= (1 << 22);
-	ew32(TXDCTL, reg);
+	ew32(TXDCTL(0), reg);
 
 	/* Transmit Descriptor Control 1 */
-	reg = er32(TXDCTL1);
+	reg = er32(TXDCTL(1));
 	reg |= (1 << 22);
-	ew32(TXDCTL1, reg);
+	ew32(TXDCTL(1), reg);
 
 	/* Transmit Arbitration Control 0 */
-	reg = er32(TARC0);
+	reg = er32(TARC(0));
 	if (hw->mac.type == e1000_ich8lan)
 		reg |= (1 << 28) | (1 << 29);
 	reg |= (1 << 23) | (1 << 24) | (1 << 26) | (1 << 27);
-	ew32(TARC0, reg);
+	ew32(TARC(0), reg);
 
 	/* Transmit Arbitration Control 1 */
-	reg = er32(TARC1);
+	reg = er32(TARC(1));
 	if (er32(TCTL) & E1000_TCTL_MULR)
 		reg &= ~(1 << 28);
 	else
 		reg |= (1 << 28);
 	reg |= (1 << 24) | (1 << 26) | (1 << 30);
-	ew32(TARC1, reg);
+	ew32(TARC(1), reg);
 
 	/* Device Status */
 	if (hw->mac.type == e1000_ich8lan) {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d70bde0..b8bb4fe 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1639,24 +1639,24 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
 	if (adapter->flags & FLAG_TARC_SPEED_MODE_BIT) {
-		tarc = er32(TARC0);
+		tarc = er32(TARC(0));
 		/*
 		 * set the speed mode bit, we'll clear it if we're not at
 		 * gigabit link later
 		 */
 #define SPEED_MODE_BIT (1 << 21)
 		tarc |= SPEED_MODE_BIT;
-		ew32(TARC0, tarc);
+		ew32(TARC(0), tarc);
 	}
 
 	/* errata: program both queues to unweighted RR */
 	if (adapter->flags & FLAG_TARC_SET_BIT_ZERO) {
-		tarc = er32(TARC0);
+		tarc = er32(TARC(0));
 		tarc |= 1;
-		ew32(TARC0, tarc);
-		tarc = er32(TARC1);
+		ew32(TARC(0), tarc);
+		tarc = er32(TARC(1));
 		tarc |= 1;
-		ew32(TARC1, tarc);
+		ew32(TARC(1), tarc);
 	}
 
 	e1000e_config_collision_dist(hw);
@@ -2775,9 +2775,9 @@ static void e1000_watchdog_task(struct work_struct *work)
 			if ((adapter->flags & FLAG_TARC_SPEED_MODE_BIT) &&
 			    !txb2b) {
 				u32 tarc0;
-				tarc0 = er32(TARC0);
+				tarc0 = er32(TARC(0));
 				tarc0 &= ~SPEED_MODE_BIT;
-				ew32(TARC0, tarc0);
+				ew32(TARC(0), tarc0);
 			}
 
 			/*


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
