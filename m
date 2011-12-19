From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 14/15] module_param: make bool parameters really bool (net & drivers/net)
Date: Mon, 19 Dec 2011 16:08:06 +1030
Message-ID: <87liq9nmtd.fsf@rustcorp.com.au>
References: <877h1ysenl.fsf@rustcorp.com.au> <1323920752.29500.11.camel@joe2Laptop> <87k45xqvfs.fsf@rustcorp.com.au> <1323995620.18603.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323995620.18603.4.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Dec 2011 16:33:40 -0800, Joe Perches <joe@perches.com> wrote:
> On Fri, 2011-12-16 at 09:44 +1030, Rusty Russell wrote:
> > I could, but as I was touching 457 files, so I was aiming for minimal
> > changes.
> 
> > Dave, did you want a true/false cleanup too?
> 
> Hi Rusty.
> 
> Did you perform these transforms via spatch?
> If not, here's a trivial spatch script for those files.
> 
> $ cat bool.cocci
> @@
> bool b
> @@
> -b = 0
> +b = false
> @@
> bool b
> @@
> -b = 1
> +b = true

Nice!

You missed a semicolon on each 'bool b;' line, then it worked.

Dave, here's the fixes from drivers/net and net/ *before* my patches
come into play:

From: Rusty Russell <rusty@rustcorp.com.au>
Subject: net: fix assignment of 0/1 to bool variables.

DaveM said:
   Please, this kind of stuff rots forever and not using bool properly
   drives me crazy.

Joe Perches <joe@perches.com> gave me the spatch script:

	@@
	bool b;
	@@
	-b = 0
	+b = false
	@@
	bool b;
	@@
	-b = 1
	+b = true

I merely installed coccinelle, read the documentation and took credit.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/ethernet/broadcom/tg3.c                   |    8 -
 drivers/net/ethernet/brocade/bna/bnad.c               |    6 -
 drivers/net/ethernet/dec/tulip/de4x5.c                |    4 
 drivers/net/ethernet/intel/e1000/e1000_main.c         |   10 -
 drivers/net/ethernet/intel/e1000e/netdev.c            |   24 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c           |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c       |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c          |   12 +-
 drivers/net/ethernet/sfc/falcon.c                     |    2 
 drivers/net/ethernet/sfc/mtd.c                        |    6 -
 drivers/net/ethernet/sfc/siena.c                      |    2 
 drivers/net/ethernet/tile/tilepro.c                   |    4 
 drivers/net/ethernet/xilinx/xilinx_emaclite.c         |    6 -
 drivers/net/wimax/i2400m/tx.c                         |    8 -
 drivers/net/wireless/ath/ath5k/reset.c                |    4 
 drivers/net/wireless/ath/ath6kl/init.c                |    2 
 drivers/net/wireless/ath/ath9k/eeprom_def.c           |    2 
 drivers/net/wireless/ath/ath9k/xmit.c                 |    4 
 drivers/net/wireless/b43/dma.c                        |   14 +-
 drivers/net/wireless/b43/leds.c                       |   16 +-
 drivers/net/wireless/b43/lo.c                         |    8 -
 drivers/net/wireless/b43/main.c                       |  100 +++++++++---------
 drivers/net/wireless/b43/phy_common.c                 |    8 -
 drivers/net/wireless/b43/phy_g.c                      |   34 +++---
 drivers/net/wireless/b43/phy_lp.c                     |    8 -
 drivers/net/wireless/b43/phy_n.c                      |    4 
 drivers/net/wireless/b43/pio.c                        |    6 -
 drivers/net/wireless/b43/xmit.c                       |    4 
 drivers/net/wireless/b43legacy/dma.c                  |   16 +-
 drivers/net/wireless/b43legacy/leds.c                 |    4 
 drivers/net/wireless/b43legacy/main.c                 |   64 +++++------
 drivers/net/wireless/b43legacy/radio.c                |   20 +--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c   |    4 
 drivers/net/wireless/brcm80211/brcmsmac/dma.c         |    4 
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c |    2 
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c |   32 ++---
 drivers/net/wireless/iwlwifi/iwl-agn.c                |    2 
 drivers/net/wireless/iwmc3200wifi/main.c              |    2 
 drivers/net/wireless/iwmc3200wifi/rx.c                |   12 +-
 drivers/net/wireless/libertas/if_cs.c                 |    4 
 drivers/net/wireless/libertas_tf/main.c               |    4 
 drivers/net/wireless/mac80211_hwsim.c                 |    4 
 drivers/net/wireless/mwifiex/cfg80211.c               |    6 -
 drivers/net/wireless/mwl8k.c                          |    8 -
 drivers/net/wireless/rtlwifi/base.c                   |    2 
 drivers/net/wireless/rtlwifi/pci.c                    |    6 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c           |    4 
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c           |    2 
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c           |    4 
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c           |    4 
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c           |    4 
 drivers/net/wireless/wl12xx/sdio_test.c               |   12 +-
 net/dccp/feat.c                                       |   16 +-
 net/dccp/options.c                                    |    2 
 net/ipv4/tcp_timer.c                                  |    4 
 net/mac80211/rc80211_pid_algo.c                       |    4 
 net/mac80211/scan.c                                   |    2 
 net/netfilter/ipvs/ip_vs_pe_sip.c                     |    4 
 net/rfkill/rfkill-regulator.c                         |    6 -
 net/rxrpc/ar-ack.c                                    |   14 +-
 net/rxrpc/ar-output.c                                 |    4 
 62 files changed, 297 insertions(+), 297 deletions(-)

diff -u -p a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
--- a/drivers/net/ethernet/brocade/bna/bnad.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/ethernet/brocade/bna/bnad.c 2011-12-19 13:20:51.852430982 +1030
@@ -723,7 +723,7 @@ void
 bnad_cb_ethport_link_status(struct bnad *bnad,
 			enum bna_link_status link_status)
 {
-	bool link_up = 0;
+	bool link_up = false;
 
 	link_up = (link_status == BNA_LINK_UP) || (link_status == BNA_CEE_UP);
 
@@ -3186,7 +3186,7 @@ bnad_pci_init(struct bnad *bnad,
 		goto disable_device;
 	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
 	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		*using_dac = 1;
+		*using_dac = true;
 	} else {
 		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
 		if (err) {
@@ -3195,7 +3195,7 @@ bnad_pci_init(struct bnad *bnad,
 			if (err)
 				goto release_regions;
 		}
-		*using_dac = 0;
+		*using_dac = false;
 	}
 	pci_set_master(pdev);
 	return 0;
diff -u -p a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
--- a/drivers/net/ethernet/broadcom/tg3.c 2011-11-08 09:11:59.000000000 +1030
+++ b/drivers/net/ethernet/broadcom/tg3.c 2011-12-19 13:21:27.712431901 +1030
@@ -6443,13 +6443,13 @@ static bool tg3_tx_frag_set(struct tg3_n
 	bool hwbug = false;
 
 	if (tg3_flag(tp, SHORT_DMA_BUG) && len <= 8)
-		hwbug = 1;
+		hwbug = true;
 
 	if (tg3_4g_overflow_test(map, len))
-		hwbug = 1;
+		hwbug = true;
 
 	if (tg3_40bit_overflow_test(tp, map, len))
-		hwbug = 1;
+		hwbug = true;
 
 	if (tg3_flag(tp, 4K_FIFO_LIMIT)) {
 		u32 prvidx = *entry;
@@ -6482,7 +6482,7 @@ static bool tg3_tx_frag_set(struct tg3_n
 				*budget -= 1;
 				*entry = NEXT_TX(*entry);
 			} else {
-				hwbug = 1;
+				hwbug = true;
 				tnapi->tx_buffers[prvidx].fragmented = false;
 			}
 		}
diff -u -p a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c 2011-12-19 13:21:34.488432075 +1030
@@ -662,7 +662,7 @@ static void xemaclite_rx_handler(struct
  */
 static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
 {
-	bool tx_complete = 0;
+	bool tx_complete = false;
 	struct net_device *dev = dev_id;
 	struct net_local *lp = netdev_priv(dev);
 	void __iomem *base_addr = lp->base_addr;
@@ -683,7 +683,7 @@ static irqreturn_t xemaclite_interrupt(i
 		tx_status &= ~XEL_TSR_XMIT_ACTIVE_MASK;
 		out_be32(base_addr + XEL_TSR_OFFSET, tx_status);
 
-		tx_complete = 1;
+		tx_complete = true;
 	}
 
 	/* Check if the Transmission for the second buffer is completed */
@@ -695,7 +695,7 @@ static irqreturn_t xemaclite_interrupt(i
 		out_be32(base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET,
 			 tx_status);
 
-		tx_complete = 1;
+		tx_complete = true;
 	}
 
 	/* If there was a Tx interrupt, call the Tx Handler */
diff -u -p a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
--- a/drivers/net/ethernet/tile/tilepro.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/tile/tilepro.c 2011-12-19 13:21:38.836432185 +1030
@@ -1256,7 +1256,7 @@ static void tile_net_stop_aux(struct net
 			  sizeof(dummy), NETIO_IPP_STOP_SHIM_OFF) < 0)
 		panic("Failed to stop LIPP/LEPP!\n");
 
-	priv->partly_opened = 0;
+	priv->partly_opened = false;
 }
 
 
@@ -1507,7 +1507,7 @@ static int tile_net_open(struct net_devi
 		       priv->network_cpus_count, priv->network_cpus_credits);
 #endif
 
-		priv->partly_opened = 1;
+		priv->partly_opened = true;
 
 	} else {
 		/* FIXME: Is this possible? */
diff -u -p a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
--- a/drivers/net/ethernet/dec/tulip/de4x5.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c 2011-12-19 13:21:44.996432344 +1030
@@ -5196,7 +5196,7 @@ de4x5_parse_params(struct net_device *de
     struct de4x5_private *lp = netdev_priv(dev);
     char *p, *q, t;
 
-    lp->params.fdx = 0;
+    lp->params.fdx = false;
     lp->params.autosense = AUTO;
 
     if (args == NULL) return;
@@ -5206,7 +5206,7 @@ de4x5_parse_params(struct net_device *de
 	t = *q;
 	*q = '\0';
 
-	if (strstr(p, "fdx") || strstr(p, "FDX")) lp->params.fdx = 1;
+	if (strstr(p, "fdx") || strstr(p, "FDX")) lp->params.fdx = true;
 
 	if (strstr(p, "autosense") || strstr(p, "AUTOSENSE")) {
 	    if (strstr(p, "TP")) {
diff -u -p a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c 2011-12-19 13:21:49.912432469 +1030
@@ -4019,7 +4019,7 @@ void ixgbe_down(struct ixgbe_adapter *ad
 
 		/* Mark all the VFs as inactive */
 		for (i = 0 ; i < adapter->num_vfs; i++)
-			adapter->vfinfo[i].clear_to_send = 0;
+			adapter->vfinfo[i].clear_to_send = false;
 
 		/* ping all the active vfs to let them know we are going down */
 		ixgbe_ping_all_vfs(adapter);
diff -u -p a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c 2011-12-19 13:21:51.424432508 +1030
@@ -1214,7 +1214,7 @@ s32 ixgbe_read_i2c_byte_generic(struct i
 	u32 max_retry = 10;
 	u32 retry = 0;
 	u16 swfw_mask = 0;
-	bool nack = 1;
+	bool nack = true;
 	*data = 0;
 
 	if (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)
@@ -1421,7 +1421,7 @@ static void ixgbe_i2c_stop(struct ixgbe_
 static s32 ixgbe_clock_in_i2c_byte(struct ixgbe_hw *hw, u8 *data)
 {
 	s32 i;
-	bool bit = 0;
+	bool bit = false;
 
 	for (i = 7; i >= 0; i--) {
 		ixgbe_clock_in_i2c_bit(hw, &bit);
@@ -1443,7 +1443,7 @@ static s32 ixgbe_clock_out_i2c_byte(stru
 	s32 status = 0;
 	s32 i;
 	u32 i2cctl;
-	bool bit = 0;
+	bool bit = false;
 
 	for (i = 7; i >= 0; i--) {
 		bit = (data >> i) & 0x1;
@@ -1473,7 +1473,7 @@ static s32 ixgbe_get_i2c_ack(struct ixgb
 	u32 i = 0;
 	u32 i2cctl = IXGBE_READ_REG(hw, IXGBE_I2CCTL);
 	u32 timeout = 10;
-	bool ack = 1;
+	bool ack = true;
 
 	ixgbe_raise_i2c_clk(hw, &i2cctl);
 
@@ -1646,9 +1646,9 @@ static bool ixgbe_get_i2c_data(u32 *i2cc
 	bool data;
 
 	if (*i2cctl & IXGBE_I2C_DATA_IN)
-		data = 1;
+		data = true;
 	else
-		data = 0;
+		data = false;
 
 	return data;
 }
diff -u -p a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c 2011-12-19 13:21:51.876432519 +1030
@@ -2599,7 +2599,7 @@ s32 ixgbe_enable_rx_dma_generic(struct i
 s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
 {
 	ixgbe_link_speed speed = 0;
-	bool link_up = 0;
+	bool link_up = false;
 	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
diff -u -p a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
--- a/drivers/net/ethernet/intel/e1000e/netdev.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c 2011-12-19 13:21:53.888432571 +1030
@@ -875,7 +875,7 @@ static bool e1000_clean_rx_irq(struct e1
 	u32 length, staterr;
 	unsigned int i;
 	int cleaned_count = 0;
-	bool cleaned = 0;
+	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
@@ -904,7 +904,7 @@ static bool e1000_clean_rx_irq(struct e1
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = 1;
+		cleaned = true;
 		cleaned_count++;
 		dma_unmap_single(&pdev->dev,
 				 buffer_info->dma,
@@ -1150,7 +1150,7 @@ static bool e1000_clean_tx_irq(struct e1
 		 * Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i
 		 */
-		adapter->detect_tx_hung = 0;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
 			       + (adapter->tx_timeout_factor * HZ)) &&
@@ -1185,7 +1185,7 @@ static bool e1000_clean_rx_irq_ps(struct
 	unsigned int i, j;
 	u32 length, staterr;
 	int cleaned_count = 0;
-	bool cleaned = 0;
+	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
@@ -1211,7 +1211,7 @@ static bool e1000_clean_rx_irq_ps(struct
 
 		next_buffer = &rx_ring->buffer_info[i];
 
-		cleaned = 1;
+		cleaned = true;
 		cleaned_count++;
 		dma_unmap_single(&pdev->dev, buffer_info->dma,
 				 adapter->rx_ps_bsize0, DMA_FROM_DEVICE);
@@ -4183,7 +4183,7 @@ static void e1000_print_link_info(struct
 static bool e1000e_has_link(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	bool link_active = 0;
+	bool link_active = false;
 	s32 ret_val = 0;
 
 	/*
@@ -4198,7 +4198,7 @@ static bool e1000e_has_link(struct e1000
 			ret_val = hw->mac.ops.check_for_link(hw);
 			link_active = !hw->mac.get_link_status;
 		} else {
-			link_active = 1;
+			link_active = true;
 		}
 		break;
 	case e1000_media_type_fiber:
@@ -4297,7 +4297,7 @@ static void e1000_watchdog_task(struct w
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
-			bool txb2b = 1;
+			bool txb2b = true;
 
 			/* Cancel scheduled suspend requests. */
 			pm_runtime_resume(netdev->dev.parent);
@@ -4333,11 +4333,11 @@ static void e1000_watchdog_task(struct w
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				txb2b = 0;
+				txb2b = false;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
-				txb2b = 0;
+				txb2b = false;
 				adapter->tx_timeout_factor = 10;
 				break;
 			}
@@ -4473,7 +4473,7 @@ link_up:
 	e1000e_flush_descriptors(adapter);
 
 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = 1;
+	adapter->detect_tx_hung = true;
 
 	/*
 	 * With 82571 controllers, LAA may be overwritten due to controller
@@ -6135,7 +6135,7 @@ static int __devinit e1000_probe(struct
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
-	adapter->fc_autoneg = 1;
+	adapter->fc_autoneg = true;
 	adapter->hw.fc.requested_mode = e1000_fc_default;
 	adapter->hw.fc.current_mode = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
diff -u -p a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c 2011-12-19 13:21:55.904432623 +1030
@@ -228,7 +228,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	if (IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_PCIX_MODE) {
 		err = pci_enable_msi(adapter->pdev);
 		if (!err) {
-			adapter->have_msi = 1;
+			adapter->have_msi = true;
 			irq_flags = 0;
 		}
 		/* proceed to try to request regular interrupt */
diff -u -p a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c 2011-12-19 13:21:57.640432667 +1030
@@ -1182,7 +1182,7 @@ static int __devinit e1000_probe(struct
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
 		else
-			adapter->quad_port_a = 1;
+			adapter->quad_port_a = true;
 		/* Reset for multiple quad port adapters */
 		if (++global_quad_port_a == 4)
 			global_quad_port_a = 0;
@@ -1676,7 +1676,7 @@ static void e1000_configure_tx(struct e1
 	 * need this to apply a workaround later in the send path. */
 	if (hw->mac_type == e1000_82544 &&
 	    hw->bus_type == e1000_bus_type_pcix)
-		adapter->pcix_82544 = 1;
+		adapter->pcix_82544 = true;
 
 	ew32(TCTL, tctl);
 
@@ -1999,7 +1999,7 @@ static void e1000_clean_tx_ring(struct e
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-	tx_ring->last_tx_tso = 0;
+	tx_ring->last_tx_tso = false;
 
 	writel(0, hw->hw_addr + tx_ring->tdh);
 	writel(0, hw->hw_addr + tx_ring->tdt);
@@ -2848,7 +2848,7 @@ static int e1000_tx_map(struct e1000_ada
 		 * DMA'd to the controller */
 		if (!skb->data_len && tx_ring->last_tx_tso &&
 		    !skb_is_gso(skb)) {
-			tx_ring->last_tx_tso = 0;
+			tx_ring->last_tx_tso = false;
 			size -= 4;
 		}
 
@@ -3216,7 +3216,7 @@ static netdev_tx_t e1000_xmit_frame(stru
 
 	if (likely(tso)) {
 		if (likely(hw->mac_type != e1000_82544))
-			tx_ring->last_tx_tso = 1;
+			tx_ring->last_tx_tso = true;
 		tx_flags |= E1000_TX_FLAGS_TSO;
 	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
diff -u -p a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
--- a/drivers/net/ethernet/sfc/siena.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/sfc/siena.c 2011-12-19 13:22:00.428432738 +1030
@@ -232,7 +232,7 @@ static int siena_probe_nvconfig(struct e
 static int siena_probe_nic(struct efx_nic *efx)
 {
 	struct siena_nic_data *nic_data;
-	bool already_attached = 0;
+	bool already_attached = false;
 	efx_oword_t reg;
 	int rc;
 
diff -u -p a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
--- a/drivers/net/ethernet/sfc/falcon.c 2011-10-31 13:28:01.000000000 +1030
+++ b/drivers/net/ethernet/sfc/falcon.c 2011-12-19 13:22:01.600432768 +1030
@@ -610,7 +610,7 @@ static void falcon_stats_complete(struct
 	if (!nic_data->stats_pending)
 		return;
 
-	nic_data->stats_pending = 0;
+	nic_data->stats_pending = false;
 	if (*nic_data->stats_dma_done == FALCON_STATS_DONE) {
 		rmb(); /* read the done flag before the stats */
 		efx->mac_op->update_stats(efx);
diff -u -p a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
--- a/drivers/net/ethernet/sfc/mtd.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/ethernet/sfc/mtd.c 2011-12-19 13:22:02.460432790 +1030
@@ -496,7 +496,7 @@ static int siena_mtd_erase(struct mtd_in
 		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
 		if (rc)
 			goto out;
-		part->mcdi.updating = 1;
+		part->mcdi.updating = true;
 	}
 
 	/* The MCDI interface can in fact do multiple erase blocks at once;
@@ -528,7 +528,7 @@ static int siena_mtd_write(struct mtd_in
 		rc = efx_mcdi_nvram_update_start(efx, part->mcdi.nvram_type);
 		if (rc)
 			goto out;
-		part->mcdi.updating = 1;
+		part->mcdi.updating = true;
 	}
 
 	while (offset < end) {
@@ -553,7 +553,7 @@ static int siena_mtd_sync(struct mtd_inf
 	int rc = 0;
 
 	if (part->mcdi.updating) {
-		part->mcdi.updating = 0;
+		part->mcdi.updating = false;
 		rc = efx_mcdi_nvram_update_finish(efx, part->mcdi.nvram_type);
 	}
 
diff -u -p a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
--- a/drivers/net/wimax/i2400m/tx.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wimax/i2400m/tx.c 2011-12-19 13:22:07.120432910 +1030
@@ -562,7 +562,7 @@ void i2400m_tx_new(struct i2400m *i2400m
 {
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_msg_hdr *tx_msg;
-	bool try_head = 0;
+	bool try_head = false;
 	BUG_ON(i2400m->tx_msg != NULL);
 	/*
 	 * In certain situations, TX queue might have enough space to
@@ -580,7 +580,7 @@ try_head:
 	else if (tx_msg == TAIL_FULL) {
 		i2400m_tx_skip_tail(i2400m);
 		d_printf(2, dev, "new TX message: tail full, trying head\n");
-		try_head = 1;
+		try_head = true;
 		goto try_head;
 	}
 	memset(tx_msg, 0, I2400M_TX_PLD_SIZE);
@@ -720,7 +720,7 @@ int i2400m_tx(struct i2400m *i2400m, con
 	unsigned long flags;
 	size_t padded_len;
 	void *ptr;
-	bool try_head = 0;
+	bool try_head = false;
 	unsigned is_singleton = pl_type == I2400M_PT_RESET_WARM
 		|| pl_type == I2400M_PT_RESET_COLD;
 
@@ -771,7 +771,7 @@ try_new:
 		d_printf(2, dev, "pl append: tail full\n");
 		i2400m_tx_close(i2400m);
 		i2400m_tx_skip_tail(i2400m);
-		try_head = 1;
+		try_head = true;
 		goto try_new;
 	} else if (ptr == NULL) {	/* All full */
 		result = -ENOSPC;
diff -u -p a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
--- a/drivers/net/wireless/libertas_tf/main.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/libertas_tf/main.c 2011-12-19 13:22:13.096433063 +1030
@@ -719,11 +719,11 @@ void lbtf_bcn_sent(struct lbtf_private *
 		return;
 
 	if (skb_queue_empty(&priv->bc_ps_buf)) {
-		bool tx_buff_bc = 0;
+		bool tx_buff_bc = false;
 
 		while ((skb = ieee80211_get_buffered_bc(priv->hw, priv->vif))) {
 			skb_queue_tail(&priv->bc_ps_buf, skb);
-			tx_buff_bc = 1;
+			tx_buff_bc = true;
 		}
 		if (tx_buff_bc) {
 			ieee80211_stop_queues(priv->hw);
diff -u -p a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
--- a/drivers/net/wireless/mwifiex/cfg80211.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/mwifiex/cfg80211.c 2011-12-19 13:22:19.348433223 +1030
@@ -753,7 +753,7 @@ mwifiex_cfg80211_disconnect(struct wiphy
 	if (priv->disconnect)
 		return -EBUSY;
 
-	priv->disconnect = 1;
+	priv->disconnect = true;
 	if (mwifiex_deauthenticate(priv, NULL))
 		return -EFAULT;
 
@@ -1054,7 +1054,7 @@ mwifiex_cfg80211_leave_ibss(struct wiphy
 	if (priv->disconnect)
 		return -EBUSY;
 
-	priv->disconnect = 1;
+	priv->disconnect = true;
 
 	wiphy_dbg(wiphy, "info: disconnecting from essid %pM\n",
 			priv->cfg_bssid);
@@ -1498,6 +1498,6 @@ mwifiex_cfg80211_results(struct work_str
 
 	if (priv->disconnect) {
 		memset(priv->cfg_bssid, 0, ETH_ALEN);
-		priv->disconnect = 0;
+		priv->disconnect = false;
 	}
 }
diff -u -p a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
--- a/drivers/net/wireless/b43legacy/dma.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/b43legacy/dma.c 2011-12-19 13:22:20.264433247 +1030
@@ -715,7 +715,7 @@ struct b43legacy_dmaring *b43legacy_setu
 	ring->mmio_base = b43legacy_dmacontroller_base(type, controller_index);
 	ring->index = controller_index;
 	if (for_tx) {
-		ring->tx = 1;
+		ring->tx = true;
 		ring->current_slot = -1;
 	} else {
 		if (ring->index == 0) {
@@ -806,7 +806,7 @@ void b43legacy_dma_free(struct b43legacy
 static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 {
 	u64 orig_mask = mask;
-	bool fallback = 0;
+	bool fallback = false;
 	int err;
 
 	/* Try to set the DMA mask. If it fails, try falling back to a
@@ -820,12 +820,12 @@ static int b43legacy_dma_set_mask(struct
 		}
 		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_BIT_MASK(32);
-			fallback = 1;
+			fallback = true;
 			continue;
 		}
 		if (mask == DMA_BIT_MASK(32)) {
 			mask = DMA_BIT_MASK(30);
-			fallback = 1;
+			fallback = true;
 			continue;
 		}
 		b43legacyerr(dev->wl, "The machine/kernel does not support "
@@ -858,7 +858,7 @@ int b43legacy_dma_init(struct b43legacy_
 #ifdef CONFIG_B43LEGACY_PIO
 		b43legacywarn(dev->wl, "DMA for this device not supported. "
 			"Falling back to PIO\n");
-		dev->__using_pio = 1;
+		dev->__using_pio = true;
 		return -EAGAIN;
 #else
 		b43legacyerr(dev->wl, "DMA for this device not supported and "
@@ -1068,7 +1068,7 @@ static int dma_tx_fragment(struct b43leg
 	memset(meta, 0, sizeof(*meta));
 
 	meta->skb = skb;
-	meta->is_last_fragment = 1;
+	meta->is_last_fragment = true;
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
@@ -1187,7 +1187,7 @@ int b43legacy_dma_tx(struct b43legacy_wl
 	    should_inject_overflow(ring)) {
 		/* This TX ring is full. */
 		ieee80211_stop_queue(dev->wl->hw, txring_to_priority(ring));
-		ring->stopped = 1;
+		ring->stopped = true;
 		if (b43legacy_debug(dev, B43legacy_DBG_DMAVERBOSE))
 			b43legacydbg(dev->wl, "Stopped TX ring %d\n",
 			       ring->index);
@@ -1286,7 +1286,7 @@ void b43legacy_dma_handle_txstatus(struc
 	if (ring->stopped) {
 		B43legacy_WARN_ON(free_slots(ring) < SLOTS_PER_PACKET);
 		ieee80211_wake_queue(dev->wl->hw, txring_to_priority(ring));
-		ring->stopped = 0;
+		ring->stopped = false;
 		if (b43legacy_debug(dev, B43legacy_DBG_DMAVERBOSE))
 			b43legacydbg(dev->wl, "Woke up TX ring %d\n",
 			       ring->index);
diff -u -p a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wireless/b43legacy/radio.c
--- a/drivers/net/wireless/b43legacy/radio.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43legacy/radio.c 2011-12-19 13:22:20.964433265 +1030
@@ -1067,7 +1067,7 @@ b43legacy_radio_interference_mitigation_
 		if (b43legacy_phy_read(dev, 0x0033) & 0x0800)
 			break;
 
-		phy->aci_enable = 1;
+		phy->aci_enable = true;
 
 		phy_stacksave(B43legacy_PHY_RADIO_BITFIELD);
 		phy_stacksave(B43legacy_PHY_G_CRS);
@@ -1279,7 +1279,7 @@ b43legacy_radio_interference_mitigation_
 		if (!(b43legacy_phy_read(dev, 0x0033) & 0x0800))
 			break;
 
-		phy->aci_enable = 0;
+		phy->aci_enable = false;
 
 		phy_stackrestore(B43legacy_PHY_RADIO_BITFIELD);
 		phy_stackrestore(B43legacy_PHY_G_CRS);
@@ -1346,10 +1346,10 @@ int b43legacy_radio_set_interference_mit
 	    (phy->rev == 0) || (!phy->gmode))
 		return -ENODEV;
 
-	phy->aci_wlan_automatic = 0;
+	phy->aci_wlan_automatic = false;
 	switch (mode) {
 	case B43legacy_RADIO_INTERFMODE_AUTOWLAN:
-		phy->aci_wlan_automatic = 1;
+		phy->aci_wlan_automatic = true;
 		if (phy->aci_enable)
 			mode = B43legacy_RADIO_INTERFMODE_MANUALWLAN;
 		else
@@ -1371,8 +1371,8 @@ int b43legacy_radio_set_interference_mit
 								currentmode);
 
 	if (mode == B43legacy_RADIO_INTERFMODE_NONE) {
-		phy->aci_enable = 0;
-		phy->aci_hw_rssi = 0;
+		phy->aci_enable = false;
+		phy->aci_hw_rssi = false;
 	} else
 		b43legacy_radio_interference_mitigation_enable(dev, mode);
 	phy->interfmode = mode;
@@ -2102,7 +2102,7 @@ void b43legacy_radio_turn_on(struct b43l
 					    phy->radio_off_context.rfover);
 			b43legacy_phy_write(dev, B43legacy_PHY_RFOVERVAL,
 					    phy->radio_off_context.rfoverval);
-			phy->radio_off_context.valid = 0;
+			phy->radio_off_context.valid = false;
 		}
 		channel = phy->channel;
 		err = b43legacy_radio_selectchannel(dev,
@@ -2113,7 +2113,7 @@ void b43legacy_radio_turn_on(struct b43l
 	default:
 		B43legacy_BUG_ON(1);
 	}
-	phy->radio_on = 1;
+	phy->radio_on = true;
 }
 
 void b43legacy_radio_turn_off(struct b43legacy_wldev *dev, bool force)
@@ -2131,14 +2131,14 @@ void b43legacy_radio_turn_off(struct b43
 		if (!force) {
 			phy->radio_off_context.rfover = rfover;
 			phy->radio_off_context.rfoverval = rfoverval;
-			phy->radio_off_context.valid = 1;
+			phy->radio_off_context.valid = true;
 		}
 		b43legacy_phy_write(dev, B43legacy_PHY_RFOVER, rfover | 0x008C);
 		b43legacy_phy_write(dev, B43legacy_PHY_RFOVERVAL,
 				    rfoverval & 0xFF73);
 	} else
 		b43legacy_phy_write(dev, 0x0015, 0xAA00);
-	phy->radio_on = 0;
+	phy->radio_on = false;
 	b43legacydbg(dev->wl, "Radio initialized\n");
 }
 
diff -u -p a/drivers/net/wireless/b43legacy/leds.c b/drivers/net/wireless/b43legacy/leds.c
--- a/drivers/net/wireless/b43legacy/leds.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43legacy/leds.c 2011-12-19 13:22:21.536433279 +1030
@@ -203,11 +203,11 @@ void b43legacy_leds_init(struct b43legac
 		if (sprom[i] == 0xFF) {
 			/* There is no LED information in the SPROM
 			 * for this LED. Hardcode it here. */
-			activelow = 0;
+			activelow = false;
 			switch (i) {
 			case 0:
 				behaviour = B43legacy_LED_ACTIVITY;
-				activelow = 1;
+				activelow = true;
 				if (bus->boardinfo.vendor == PCI_VENDOR_ID_COMPAQ)
 					behaviour = B43legacy_LED_RADIO_ALL;
 				break;
diff -u -p a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
--- a/drivers/net/wireless/b43legacy/main.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/b43legacy/main.c 2011-12-19 13:22:22.200433296 +1030
@@ -722,9 +722,9 @@ void b43legacy_wireless_core_reset(struc
 	macctl &= ~B43legacy_MACCTL_GMODE;
 	if (flags & B43legacy_TMSLOW_GMODE) {
 		macctl |= B43legacy_MACCTL_GMODE;
-		dev->phy.gmode = 1;
+		dev->phy.gmode = true;
 	} else
-		dev->phy.gmode = 0;
+		dev->phy.gmode = false;
 	macctl |= B43legacy_MACCTL_IHR_ENABLED;
 	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
 }
@@ -811,7 +811,7 @@ static void b43legacy_calculate_link_qua
 	if (dev->noisecalc.calculation_running)
 		return;
 	dev->noisecalc.channel_at_start = dev->phy.channel;
-	dev->noisecalc.calculation_running = 1;
+	dev->noisecalc.calculation_running = true;
 	dev->noisecalc.nr_samples = 0;
 
 	b43legacy_generate_noise_sample(dev);
@@ -873,7 +873,7 @@ static void handle_irq_noise(struct b43l
 
 		dev->stats.link_noise = average;
 drop_calculation:
-		dev->noisecalc.calculation_running = 0;
+		dev->noisecalc.calculation_running = false;
 		return;
 	}
 generate_new:
@@ -889,7 +889,7 @@ static void handle_irq_tbtt_indication(s
 			b43legacy_power_saving_ctl_bits(dev, -1, -1);
 	}
 	if (b43legacy_is_mode(dev->wl, NL80211_IFTYPE_ADHOC))
-		dev->dfq_valid = 1;
+		dev->dfq_valid = true;
 }
 
 static void handle_irq_atim_end(struct b43legacy_wldev *dev)
@@ -898,7 +898,7 @@ static void handle_irq_atim_end(struct b
 		b43legacy_write32(dev, B43legacy_MMIO_MACCMD,
 				  b43legacy_read32(dev, B43legacy_MMIO_MACCMD)
 				  | B43legacy_MACCMD_DFQ_VALID);
-		dev->dfq_valid = 0;
+		dev->dfq_valid = false;
 	}
 }
 
@@ -971,7 +971,7 @@ static void b43legacy_write_beacon_templ
 	unsigned int i, len, variable_len;
 	const struct ieee80211_mgmt *bcn;
 	const u8 *ie;
-	bool tim_found = 0;
+	bool tim_found = false;
 	unsigned int rate;
 	u16 ctl;
 	int antenna;
@@ -1019,7 +1019,7 @@ static void b43legacy_write_beacon_templ
 			/* A valid TIM is at least 4 bytes long. */
 			if (ie_len < 4)
 				break;
-			tim_found = 1;
+			tim_found = true;
 
 			tim_position = sizeof(struct b43legacy_plcp_hdr6);
 			tim_position += offsetof(struct ieee80211_mgmt,
@@ -1172,7 +1172,7 @@ static void b43legacy_upload_beacon0(str
 	 *        but we don't use that feature anyway. */
 	b43legacy_write_probe_resp_template(dev, 0x268, 0x4A,
 				      &__b43legacy_ratetable[3]);
-	wl->beacon0_uploaded = 1;
+	wl->beacon0_uploaded = true;
 }
 
 static void b43legacy_upload_beacon1(struct b43legacy_wldev *dev)
@@ -1182,7 +1182,7 @@ static void b43legacy_upload_beacon1(str
 	if (wl->beacon1_uploaded)
 		return;
 	b43legacy_write_beacon_template(dev, 0x468, 0x1A);
-	wl->beacon1_uploaded = 1;
+	wl->beacon1_uploaded = true;
 }
 
 static void handle_irq_beacon(struct b43legacy_wldev *dev)
@@ -1212,7 +1212,7 @@ static void handle_irq_beacon(struct b43
 	if (unlikely(wl->beacon_templates_virgin)) {
 		/* We never uploaded a beacon before.
 		 * Upload both templates now, but only mark one valid. */
-		wl->beacon_templates_virgin = 0;
+		wl->beacon_templates_virgin = false;
 		b43legacy_upload_beacon0(dev);
 		b43legacy_upload_beacon1(dev);
 		cmd = b43legacy_read32(dev, B43legacy_MMIO_MACCMD);
@@ -1275,8 +1275,8 @@ static void b43legacy_update_templates(s
 	if (wl->current_beacon)
 		dev_kfree_skb_any(wl->current_beacon);
 	wl->current_beacon = beacon;
-	wl->beacon0_uploaded = 0;
-	wl->beacon1_uploaded = 0;
+	wl->beacon0_uploaded = false;
+	wl->beacon1_uploaded = false;
 	ieee80211_queue_work(wl->hw, &wl->beacon_update_trigger);
 }
 
@@ -2510,7 +2510,7 @@ static int find_wldev_for_phymode(struct
 		if (d->phy.possible_phymodes & phymode) {
 			/* Ok, this device supports the PHY-mode.
 			 * Set the gmode bit. */
-			*gmode = 1;
+			*gmode = true;
 			*dev = d;
 
 			return 0;
@@ -2546,7 +2546,7 @@ static int b43legacy_switch_phymode(stru
 	struct b43legacy_wldev *uninitialized_var(up_dev);
 	struct b43legacy_wldev *down_dev;
 	int err;
-	bool gmode = 0;
+	bool gmode = false;
 	int prev_status;
 
 	err = find_wldev_for_phymode(wl, new_mode, &up_dev, &gmode);
@@ -3044,12 +3044,12 @@ static void setup_struct_phy_for_init(st
 
 	/* Assume the radio is enabled. If it's not enabled, the state will
 	 * immediately get fixed on the first periodic work run. */
-	dev->radio_hw_enable = 1;
+	dev->radio_hw_enable = true;
 
 	phy->savedpctlreg = 0xFFFF;
-	phy->aci_enable = 0;
-	phy->aci_wlan_automatic = 0;
-	phy->aci_hw_rssi = 0;
+	phy->aci_enable = false;
+	phy->aci_wlan_automatic = false;
+	phy->aci_hw_rssi = false;
 
 	lo = phy->_lo_pairs;
 	if (lo)
@@ -3081,7 +3081,7 @@ static void setup_struct_phy_for_init(st
 static void setup_struct_wldev_for_init(struct b43legacy_wldev *dev)
 {
 	/* Flags */
-	dev->dfq_valid = 0;
+	dev->dfq_valid = false;
 
 	/* Stats */
 	memset(&dev->stats, 0, sizeof(dev->stats));
@@ -3187,9 +3187,9 @@ static void prepare_phy_data_for_init(st
 	phy->lofcal = 0xFFFF;
 	phy->initval = 0xFFFF;
 
-	phy->aci_enable = 0;
-	phy->aci_wlan_automatic = 0;
-	phy->aci_hw_rssi = 0;
+	phy->aci_enable = false;
+	phy->aci_wlan_automatic = false;
+	phy->aci_hw_rssi = false;
 
 	phy->antenna_diversity = 0xFFFF;
 	memset(phy->minlowsig, 0xFF, sizeof(phy->minlowsig));
@@ -3355,7 +3355,7 @@ static int b43legacy_op_add_interface(st
 	b43legacydbg(wl, "Adding Interface type %d\n", vif->type);
 
 	dev = wl->current_dev;
-	wl->operating = 1;
+	wl->operating = true;
 	wl->vif = vif;
 	wl->if_type = vif->type;
 	memcpy(wl->mac_addr, vif->addr, ETH_ALEN);
@@ -3389,7 +3389,7 @@ static void b43legacy_op_remove_interfac
 	B43legacy_WARN_ON(wl->vif != vif);
 	wl->vif = NULL;
 
-	wl->operating = 0;
+	wl->operating = false;
 
 	spin_lock_irqsave(&wl->irq_lock, flags);
 	b43legacy_adjust_opmode(dev);
@@ -3413,10 +3413,10 @@ static int b43legacy_op_start(struct iee
 	memset(wl->bssid, 0, ETH_ALEN);
 	memset(wl->mac_addr, 0, ETH_ALEN);
 	wl->filter_flags = 0;
-	wl->beacon0_uploaded = 0;
-	wl->beacon1_uploaded = 0;
-	wl->beacon_templates_virgin = 1;
-	wl->radio_enabled = 1;
+	wl->beacon0_uploaded = false;
+	wl->beacon1_uploaded = false;
+	wl->beacon_templates_virgin = true;
+	wl->radio_enabled = true;
 
 	mutex_lock(&wl->mutex);
 
@@ -3455,7 +3455,7 @@ static void b43legacy_op_stop(struct iee
 	if (b43legacy_status(dev) >= B43legacy_STAT_STARTED)
 		b43legacy_wireless_core_stop(dev);
 	b43legacy_wireless_core_exit(dev);
-	wl->radio_enabled = 0;
+	wl->radio_enabled = false;
 	mutex_unlock(&wl->mutex);
 }
 
@@ -3614,7 +3614,7 @@ static int b43legacy_wireless_core_attac
 		have_bphy = 1;
 
 	dev->phy.gmode = (have_gphy || have_bphy);
-	dev->phy.radio_on = 1;
+	dev->phy.radio_on = true;
 	tmp = dev->phy.gmode ? B43legacy_TMSLOW_GMODE : 0;
 	b43legacy_wireless_core_reset(dev, tmp);
 
@@ -3705,7 +3705,7 @@ static int b43legacy_one_core_attach(str
 		     (void (*)(unsigned long))b43legacy_interrupt_tasklet,
 		     (unsigned long)wldev);
 	if (modparam_pio)
-		wldev->__using_pio = 1;
+		wldev->__using_pio = true;
 	INIT_LIST_HEAD(&wldev->list);
 
 	err = b43legacy_wireless_core_attach(wldev);
diff -u -p a/drivers/net/wireless/ath/ath5k/reset.c b/drivers/net/wireless/ath/ath5k/reset.c
--- a/drivers/net/wireless/ath/ath5k/reset.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/ath/ath5k/reset.c 2011-12-19 13:22:24.384433352 +1030
@@ -1047,7 +1047,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah,
 	 */
 	if (fast && (ah->ah_radio != AR5K_RF2413) &&
 	(ah->ah_radio != AR5K_RF5413))
-		fast = 0;
+		fast = false;
 
 	/* Disable sleep clock operation
 	 * to avoid register access delay on certain
@@ -1073,7 +1073,7 @@ int ath5k_hw_reset(struct ath5k_hw *ah,
 	if (ret && fast) {
 		ATH5K_DBG(ah, ATH5K_DEBUG_RESET,
 			"DMA didn't stop, falling back to normal reset\n");
-		fast = 0;
+		fast = false;
 		/* Non fatal, just continue with
 		 * normal reset */
 		ret = 0;
diff -u -p a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
--- a/drivers/net/wireless/ath/ath9k/xmit.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/ath/ath9k/xmit.c 2011-12-19 13:22:33.224433577 +1030
@@ -1911,7 +1911,7 @@ int ath_tx_start(struct ieee80211_hw *hw
 	if (txq == sc->tx.txq_map[q] &&
 	    ++txq->pending_frames > ATH_MAX_QDEPTH && !txq->stopped) {
 		ieee80211_stop_queue(sc->hw, q);
-		txq->stopped = 1;
+		txq->stopped = true;
 	}
 	spin_unlock_bh(&txq->axq_lock);
 
@@ -1970,7 +1970,7 @@ static void ath_tx_complete(struct ath_s
 
 		if (txq->stopped && txq->pending_frames < ATH_MAX_QDEPTH) {
 			ieee80211_wake_queue(sc->hw, q);
-			txq->stopped = 0;
+			txq->stopped = false;
 		}
 		spin_unlock_bh(&txq->axq_lock);
 	}
diff -u -p a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c 2011-12-19 13:22:39.848433748 +1030
@@ -385,7 +385,7 @@ static int ath9k_hw_def_check_eeprom(str
 	if ((ah->hw_version.devid == AR9280_DEVID_PCI) &&
 	    ((eep->baseEepHeader.version & 0xff) > 0x0a) &&
 	    (eep->baseEepHeader.pwdclkind == 0))
-		ah->need_an_top2_fixup = 1;
+		ah->need_an_top2_fixup = true;
 
 	if ((common->bus_ops->ath_bus_type == ATH_USB) &&
 	    (AR_SREV_9280(ah)))
diff -u -p a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
--- a/drivers/net/wireless/ath/ath6kl/init.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/ath/ath6kl/init.c 2011-12-19 13:22:40.680433769 +1030
@@ -453,7 +453,7 @@ static int ath6kl_target_config_wlan_par
 			ath6kl_dbg(ATH6KL_DBG_TRC, "failed to request P2P "
 				   "capabilities (%d) - assuming P2P not "
 				   "supported\n", ret);
-			ar->p2p = 0;
+			ar->p2p = false;
 		}
 	}
 
diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c 2011-12-19 13:22:46.204433910 +1030
@@ -98,9 +98,9 @@ int rtl92c_init_sw_vars(struct ieee80211
 
 	rtl8192ce_bt_reg_init(hw);
 
-	rtlpriv->dm.dm_initialgain_enable = 1;
+	rtlpriv->dm.dm_initialgain_enable = true;
 	rtlpriv->dm.dm_flag = 0;
-	rtlpriv->dm.disable_framebursting = 0;
+	rtlpriv->dm.disable_framebursting = false;
 	rtlpriv->dm.thermalvalue = 0;
 	rtlpci->transmit_config = CFENDFORM | BIT(12) | BIT(13);
 
diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c 2011-12-19 13:22:48.932433981 +1030
@@ -2435,7 +2435,7 @@ bool rtl92cu_gpio_radio_on_off_checking(
 			 "%x\n", ppsc->hwradiooff, e_rfpowerstate_toset));
 	}
 	if (actuallyset) {
-		ppsc->hwradiooff = 1;
+		ppsc->hwradiooff = true;
 		if (e_rfpowerstate_toset == ERFON) {
 			if ((ppsc->reg_rfps_level  & RT_RF_OFF_LEVL_ASPM) &&
 			     RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_ASPM))
diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c 2011-12-19 13:22:49.604433997 +1030
@@ -57,9 +57,9 @@ static int rtl92cu_init_sw_vars(struct i
 	const struct firmware *firmware;
 	int err;
 
-	rtlpriv->dm.dm_initialgain_enable = 1;
+	rtlpriv->dm.dm_initialgain_enable = true;
 	rtlpriv->dm.dm_flag = 0;
-	rtlpriv->dm.disable_framebursting = 0;
+	rtlpriv->dm.disable_framebursting = false;
 	rtlpriv->dm.thermalvalue = 0;
 	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
 	rtlpriv->rtlhal.pfirmware = vmalloc(0x4000);
diff -u -p a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
--- a/drivers/net/wireless/rtlwifi/pci.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/pci.c 2011-12-19 13:22:50.800434029 +1030
@@ -78,7 +78,7 @@ static void _rtl_pci_update_default_sett
 	u8 init_aspm;
 
 	ppsc->reg_rfps_level = 0;
-	ppsc->support_aspm = 0;
+	ppsc->support_aspm = false;
 
 	/*Update PCI ASPM setting */
 	ppsc->const_amdpci_aspm = rtlpci->const_amdpci_aspm;
@@ -570,9 +570,9 @@ static void _rtl_pci_tx_isr(struct ieee8
 		if (ieee80211_is_nullfunc(fc)) {
 			if (ieee80211_has_pm(fc)) {
 				rtlpriv->mac80211.offchan_delay = true;
-				rtlpriv->psc.state_inap = 1;
+				rtlpriv->psc.state_inap = true;
 			} else {
-				rtlpriv->psc.state_inap = 0;
+				rtlpriv->psc.state_inap = false;
 			}
 		}
 
diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c 2011-12-19 13:22:55.252434143 +1030
@@ -98,9 +98,9 @@ static int rtl92s_init_sw_vars(struct ie
 	int err = 0;
 	u16 earlyrxthreshold = 7;
 
-	rtlpriv->dm.dm_initialgain_enable = 1;
+	rtlpriv->dm.dm_initialgain_enable = true;
 	rtlpriv->dm.dm_flag = 0;
-	rtlpriv->dm.disable_framebursting = 0;
+	rtlpriv->dm.disable_framebursting = false;
 	rtlpriv->dm.thermalvalue = 0;
 	rtlpriv->dm.useramask = true;
 
diff -u -p a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
--- a/drivers/net/wireless/rtlwifi/base.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/base.c 2011-12-19 13:22:58.184434218 +1030
@@ -396,7 +396,7 @@ void rtl_init_rfkill(struct ieee80211_hw
 	u8 valid = 0;
 
 	/*set init state to on */
-	rtlpriv->rfkill.rfkill_state = 1;
+	rtlpriv->rfkill.rfkill_state = true;
 	wiphy_rfkill_set_hw_state(hw->wiphy, 0);
 
 	radio_state = rtlpriv->cfg->ops->radio_onoff_checking(hw, &valid);
diff -u -p a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c 2011-12-19 13:23:02.968434340 +1030
@@ -99,9 +99,9 @@ static int rtl92d_init_sw_vars(struct ie
 
 	rtlpriv->dm.dm_initialgain_enable = true;
 	rtlpriv->dm.dm_flag = 0;
-	rtlpriv->dm.disable_framebursting = 0;
+	rtlpriv->dm.disable_framebursting = false;
 	rtlpriv->dm.thermalvalue = 0;
-	rtlpriv->dm.useramask = 1;
+	rtlpriv->dm.useramask = true;
 
 	/* dual mac */
 	if (rtlpriv->rtlhal.current_bandtype == BAND_ON_5G)
diff -u -p a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
--- a/drivers/net/wireless/b43/dma.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/b43/dma.c 2011-12-19 13:23:03.864434363 +1030
@@ -890,7 +890,7 @@ struct b43_dmaring *b43_setup_dmaring(st
 	else
 		ring->ops = &dma32_ops;
 	if (for_tx) {
-		ring->tx = 1;
+		ring->tx = true;
 		ring->current_slot = -1;
 	} else {
 		if (ring->index == 0) {
@@ -1061,7 +1061,7 @@ void b43_dma_free(struct b43_wldev *dev)
 static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
 {
 	u64 orig_mask = mask;
-	bool fallback = 0;
+	bool fallback = false;
 	int err;
 
 	/* Try to set the DMA mask. If it fails, try falling back to a
@@ -1075,12 +1075,12 @@ static int b43_dma_set_mask(struct b43_w
 		}
 		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_BIT_MASK(32);
-			fallback = 1;
+			fallback = true;
 			continue;
 		}
 		if (mask == DMA_BIT_MASK(32)) {
 			mask = DMA_BIT_MASK(30);
-			fallback = 1;
+			fallback = true;
 			continue;
 		}
 		b43err(dev->wl, "The machine/kernel does not support "
@@ -1307,7 +1307,7 @@ static int dma_tx_fragment(struct b43_dm
 	memset(meta, 0, sizeof(*meta));
 
 	meta->skb = skb;
-	meta->is_last_fragment = 1;
+	meta->is_last_fragment = true;
 	priv_info->bouncebuffer = NULL;
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
@@ -1466,7 +1466,7 @@ int b43_dma_tx(struct b43_wldev *dev, st
 	    should_inject_overflow(ring)) {
 		/* This TX ring is full. */
 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
-		ring->stopped = 1;
+		ring->stopped = true;
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
 			b43dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
 		}
@@ -1585,7 +1585,7 @@ void b43_dma_handle_txstatus(struct b43_
 	if (ring->stopped) {
 		B43_WARN_ON(free_slots(ring) < TX_SLOTS_PER_FRAME);
 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
-		ring->stopped = 0;
+		ring->stopped = false;
 		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
 			b43dbg(dev->wl, "Woke up TX ring %d\n", ring->index);
 		}
diff -u -p a/drivers/net/wireless/b43/lo.c b/drivers/net/wireless/b43/lo.c
--- a/drivers/net/wireless/b43/lo.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43/lo.c 2011-12-19 13:23:04.300434374 +1030
@@ -826,7 +826,7 @@ void b43_gphy_dc_lt_init(struct b43_wlde
 	const struct b43_rfatt *rfatt;
 	const struct b43_bbatt *bbatt;
 	u64 power_vector;
-	bool table_changed = 0;
+	bool table_changed = false;
 
 	BUILD_BUG_ON(B43_DC_LT_SIZE != 32);
 	B43_WARN_ON(lo->rfatt_list.len * lo->bbatt_list.len > 64);
@@ -876,7 +876,7 @@ void b43_gphy_dc_lt_init(struct b43_wlde
 			lo->dc_lt[idx] = (lo->dc_lt[idx] & 0xFF00)
 					 | (val & 0x00FF);
 		}
-		table_changed = 1;
+		table_changed = true;
 	}
 	if (table_changed) {
 		/* The table changed in memory. Update the hardware table. */
@@ -938,7 +938,7 @@ void b43_lo_g_maintanance_work(struct b4
 	unsigned long now;
 	unsigned long expire;
 	struct b43_lo_calib *cal, *tmp;
-	bool current_item_expired = 0;
+	bool current_item_expired = false;
 	bool hwpctl;
 
 	if (!lo)
@@ -968,7 +968,7 @@ void b43_lo_g_maintanance_work(struct b4
 		if (b43_compare_bbatt(&cal->bbatt, &gphy->bbatt) &&
 		    b43_compare_rfatt(&cal->rfatt, &gphy->rfatt)) {
 			B43_WARN_ON(current_item_expired);
-			current_item_expired = 1;
+			current_item_expired = true;
 		}
 		if (b43_debug(dev, B43_DBG_LO)) {
 			b43dbg(dev->wl, "LO: Item BB(%u), RF(%u,%u), "
diff -u -p a/drivers/net/wireless/b43/phy_lp.c b/drivers/net/wireless/b43/phy_lp.c
--- a/drivers/net/wireless/b43/phy_lp.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43/phy_lp.c 2011-12-19 13:23:05.520434405 +1030
@@ -736,9 +736,9 @@ static void lpphy_set_deaf(struct b43_wl
 	struct b43_phy_lp *lpphy = dev->phy.lp;
 
 	if (user)
-		lpphy->crs_usr_disable = 1;
+		lpphy->crs_usr_disable = true;
 	else
-		lpphy->crs_sys_disable = 1;
+		lpphy->crs_sys_disable = true;
 	b43_phy_maskset(dev, B43_LPPHY_CRSGAIN_CTL, 0xFF1F, 0x80);
 }
 
@@ -747,9 +747,9 @@ static void lpphy_clear_deaf(struct b43_
 	struct b43_phy_lp *lpphy = dev->phy.lp;
 
 	if (user)
-		lpphy->crs_usr_disable = 0;
+		lpphy->crs_usr_disable = false;
 	else
-		lpphy->crs_sys_disable = 0;
+		lpphy->crs_sys_disable = false;
 
 	if (!lpphy->crs_usr_disable && !lpphy->crs_sys_disable) {
 		if (b43_current_band(dev->wl) == IEEE80211_BAND_2GHZ)
diff -u -p a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
--- a/drivers/net/wireless/b43/xmit.c 2011-11-21 11:21:33.000000000 +1030
+++ b/drivers/net/wireless/b43/xmit.c 2011-12-19 13:23:06.592434432 +1030
@@ -874,7 +874,7 @@ bool b43_fill_txstatus_report(struct b43
 			      struct ieee80211_tx_info *report,
 			      const struct b43_txstatus *status)
 {
-	bool frame_success = 1;
+	bool frame_success = true;
 	int retry_limit;
 
 	/* preserve the confiured retry limit before clearing the status
@@ -890,7 +890,7 @@ bool b43_fill_txstatus_report(struct b43
 		/* The frame was not ACKed... */
 		if (!(report->flags & IEEE80211_TX_CTL_NO_ACK)) {
 			/* ...but we expected an ACK. */
-			frame_success = 0;
+			frame_success = false;
 		}
 	}
 	if (status->frame_count == 0) {
diff -u -p a/drivers/net/wireless/b43/phy_common.c b/drivers/net/wireless/b43/phy_common.c
--- a/drivers/net/wireless/b43/phy_common.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/b43/phy_common.c 2011-12-19 13:23:07.276434450 +1030
@@ -145,7 +145,7 @@ void b43_radio_lock(struct b43_wldev *de
 
 #if B43_DEBUG
 	B43_WARN_ON(dev->phy.radio_locked);
-	dev->phy.radio_locked = 1;
+	dev->phy.radio_locked = true;
 #endif
 
 	macctl = b43_read32(dev, B43_MMIO_MACCTL);
@@ -163,7 +163,7 @@ void b43_radio_unlock(struct b43_wldev *
 
 #if B43_DEBUG
 	B43_WARN_ON(!dev->phy.radio_locked);
-	dev->phy.radio_locked = 0;
+	dev->phy.radio_locked = false;
 #endif
 
 	/* Commit any write */
@@ -178,7 +178,7 @@ void b43_phy_lock(struct b43_wldev *dev)
 {
 #if B43_DEBUG
 	B43_WARN_ON(dev->phy.phy_locked);
-	dev->phy.phy_locked = 1;
+	dev->phy.phy_locked = true;
 #endif
 	B43_WARN_ON(dev->dev->core_rev < 3);
 
@@ -190,7 +190,7 @@ void b43_phy_unlock(struct b43_wldev *de
 {
 #if B43_DEBUG
 	B43_WARN_ON(!dev->phy.phy_locked);
-	dev->phy.phy_locked = 0;
+	dev->phy.phy_locked = false;
 #endif
 	B43_WARN_ON(dev->dev->core_rev < 3);
 
diff -u -p a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
--- a/drivers/net/wireless/b43/leds.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43/leds.c 2011-12-19 13:23:07.716434462 +1030
@@ -74,7 +74,7 @@ static void b43_led_update(struct b43_wl
 	if (radio_enabled)
 		turn_on = atomic_read(&led->state) != LED_OFF;
 	else
-		turn_on = 0;
+		turn_on = false;
 	if (turn_on == led->hw_state)
 		return;
 	led->hw_state = turn_on;
@@ -225,11 +225,11 @@ static void b43_led_get_sprominfo(struct
 	if (sprom[led_index] == 0xFF) {
 		/* There is no LED information in the SPROM
 		 * for this LED. Hardcode it here. */
-		*activelow = 0;
+		*activelow = false;
 		switch (led_index) {
 		case 0:
 			*behaviour = B43_LED_ACTIVITY;
-			*activelow = 1;
+			*activelow = true;
 			if (dev->dev->board_vendor == PCI_VENDOR_ID_COMPAQ)
 				*behaviour = B43_LED_RADIO_ALL;
 			break;
@@ -267,11 +267,11 @@ void b43_leds_init(struct b43_wldev *dev
 	if (led->wl) {
 		if (dev->phy.radio_on && b43_is_hw_radio_enabled(dev)) {
 			b43_led_turn_on(dev, led->index, led->activelow);
-			led->hw_state = 1;
+			led->hw_state = true;
 			atomic_set(&led->state, 1);
 		} else {
 			b43_led_turn_off(dev, led->index, led->activelow);
-			led->hw_state = 0;
+			led->hw_state = false;
 			atomic_set(&led->state, 0);
 		}
 	}
@@ -280,19 +280,19 @@ void b43_leds_init(struct b43_wldev *dev
 	led = &dev->wl->leds.led_tx;
 	if (led->wl) {
 		b43_led_turn_off(dev, led->index, led->activelow);
-		led->hw_state = 0;
+		led->hw_state = false;
 		atomic_set(&led->state, 0);
 	}
 	led = &dev->wl->leds.led_rx;
 	if (led->wl) {
 		b43_led_turn_off(dev, led->index, led->activelow);
-		led->hw_state = 0;
+		led->hw_state = false;
 		atomic_set(&led->state, 0);
 	}
 	led = &dev->wl->leds.led_assoc;
 	if (led->wl) {
 		b43_led_turn_off(dev, led->index, led->activelow);
-		led->hw_state = 0;
+		led->hw_state = false;
 		atomic_set(&led->state, 0);
 	}
 
diff -u -p a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/b43/phy_g.c
--- a/drivers/net/wireless/b43/phy_g.c 2011-07-26 13:50:42.000000000 +0930
+++ b/drivers/net/wireless/b43/phy_g.c 2011-12-19 13:23:08.324434477 +1030
@@ -897,7 +897,7 @@ b43_radio_interference_mitigation_enable
 		if (b43_phy_read(dev, 0x0033) & 0x0800)
 			break;
 
-		gphy->aci_enable = 1;
+		gphy->aci_enable = true;
 
 		phy_stacksave(B43_PHY_RADIO_BITFIELD);
 		phy_stacksave(B43_PHY_G_CRS);
@@ -1038,7 +1038,7 @@ b43_radio_interference_mitigation_disabl
 		if (!(b43_phy_read(dev, 0x0033) & 0x0800))
 			break;
 
-		gphy->aci_enable = 0;
+		gphy->aci_enable = false;
 
 		phy_stackrestore(B43_PHY_RADIO_BITFIELD);
 		phy_stackrestore(B43_PHY_G_CRS);
@@ -1956,10 +1956,10 @@ static void b43_phy_init_pctl(struct b43
 			bbatt.att = 11;
 			if (phy->radio_rev == 8) {
 				rfatt.att = 15;
-				rfatt.with_padmix = 1;
+				rfatt.with_padmix = true;
 			} else {
 				rfatt.att = 9;
-				rfatt.with_padmix = 0;
+				rfatt.with_padmix = false;
 			}
 			b43_set_txpower_g(dev, &bbatt, &rfatt, 0);
 		}
@@ -2137,7 +2137,7 @@ static void default_radio_attenuation(st
 	struct b43_bus_dev *bdev = dev->dev;
 	struct b43_phy *phy = &dev->phy;
 
-	rf->with_padmix = 0;
+	rf->with_padmix = false;
 
 	if (dev->dev->board_vendor == SSB_BOARDVENDOR_BCM &&
 	    dev->dev->board_type == SSB_BOARD_BCM4309G) {
@@ -2221,7 +2221,7 @@ static void default_radio_attenuation(st
 			return;
 		case 8:
 			rf->att = 0xA;
-			rf->with_padmix = 1;
+			rf->with_padmix = true;
 			return;
 		case 9:
 		default:
@@ -2389,7 +2389,7 @@ static int b43_gphy_init_tssi2dbm_table(
 	B43_WARN_ON((dev->dev->chip_id == 0x4301) &&
 		    (phy->radio_ver != 0x2050)); /* Not supported anymore */
 
-	gphy->dyn_tssi_tbl = 0;
+	gphy->dyn_tssi_tbl = false;
 
 	if (pab0 != 0 && pab1 != 0 && pab2 != 0 &&
 	    pab0 != -1 && pab1 != -1 && pab2 != -1) {
@@ -2404,7 +2404,7 @@ static int b43_gphy_init_tssi2dbm_table(
 							       pab1, pab2);
 		if (!gphy->tssi2dbm)
 			return -ENOMEM;
-		gphy->dyn_tssi_tbl = 1;
+		gphy->dyn_tssi_tbl = true;
 	} else {
 		/* pabX values not set in SPROM. */
 		gphy->tgt_idle_tssi = 52;
@@ -2504,7 +2504,7 @@ static void b43_gphy_op_free(struct b43_
 
 	if (gphy->dyn_tssi_tbl)
 		kfree(gphy->tssi2dbm);
-	gphy->dyn_tssi_tbl = 0;
+	gphy->dyn_tssi_tbl = false;
 	gphy->tssi2dbm = NULL;
 
 	kfree(gphy);
@@ -2531,10 +2531,10 @@ static int b43_gphy_op_prepare_hardware(
 	if (phy->rev == 1) {
 		/* Workaround: Temporarly disable gmode through the early init
 		 * phase, as the gmode stuff is not needed for phy rev 1 */
-		phy->gmode = 0;
+		phy->gmode = false;
 		b43_wireless_core_reset(dev, 0);
 		b43_phy_initg(dev);
-		phy->gmode = 1;
+		phy->gmode = true;
 		b43_wireless_core_reset(dev, 1);
 	}
 
@@ -2613,7 +2613,7 @@ static void b43_gphy_op_software_rfkill(
 				      gphy->radio_off_context.rfover);
 			b43_phy_write(dev, B43_PHY_RFOVERVAL,
 				      gphy->radio_off_context.rfoverval);
-			gphy->radio_off_context.valid = 0;
+			gphy->radio_off_context.valid = false;
 		}
 		channel = phy->channel;
 		b43_gphy_channel_switch(dev, 6, 1);
@@ -2626,7 +2626,7 @@ static void b43_gphy_op_software_rfkill(
 		rfoverval = b43_phy_read(dev, B43_PHY_RFOVERVAL);
 		gphy->radio_off_context.rfover = rfover;
 		gphy->radio_off_context.rfoverval = rfoverval;
-		gphy->radio_off_context.valid = 1;
+		gphy->radio_off_context.valid = true;
 		b43_phy_write(dev, B43_PHY_RFOVER, rfover | 0x008C);
 		b43_phy_write(dev, B43_PHY_RFOVERVAL, rfoverval & 0xFF73);
 	}
@@ -2711,10 +2711,10 @@ static int b43_gphy_op_interf_mitigation
 	if ((phy->rev == 0) || (!phy->gmode))
 		return -ENODEV;
 
-	gphy->aci_wlan_automatic = 0;
+	gphy->aci_wlan_automatic = false;
 	switch (mode) {
 	case B43_INTERFMODE_AUTOWLAN:
-		gphy->aci_wlan_automatic = 1;
+		gphy->aci_wlan_automatic = true;
 		if (gphy->aci_enable)
 			mode = B43_INTERFMODE_MANUALWLAN;
 		else
@@ -2735,8 +2735,8 @@ static int b43_gphy_op_interf_mitigation
 		b43_radio_interference_mitigation_disable(dev, currentmode);
 
 	if (mode == B43_INTERFMODE_NONE) {
-		gphy->aci_enable = 0;
-		gphy->aci_hw_rssi = 0;
+		gphy->aci_enable = false;
+		gphy->aci_hw_rssi = false;
 	} else
 		b43_radio_interference_mitigation_enable(dev, mode);
 	gphy->interfmode = mode;
diff -u -p a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/phy_n.c
--- a/drivers/net/wireless/b43/phy_n.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/b43/phy_n.c 2011-12-19 13:23:10.480434532 +1030
@@ -3258,7 +3258,7 @@ static int b43_nphy_cal_tx_iq_lo(struct
 
 	if (dev->phy.rev >= 4) {
 		avoid = nphy->hang_avoid;
-		nphy->hang_avoid = 0;
+		nphy->hang_avoid = false;
 	}
 
 	b43_ntab_read_bulk(dev, B43_NTAB16(7, 0x110), 2, save);
@@ -3368,7 +3368,7 @@ static int b43_nphy_cal_tx_iq_lo(struct
 
 			if (phy6or5x && updated[core] == 0) {
 				b43_nphy_update_tx_cal_ladder(dev, core);
-				updated[core] = 1;
+				updated[core] = true;
 			}
 
 			tmp = (params[core].ncorr[type] << 8) | 0x66;
diff -u -p a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
--- a/drivers/net/wireless/b43/pio.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/b43/pio.c 2011-12-19 13:23:15.428434659 +1030
@@ -539,7 +539,7 @@ int b43_pio_tx(struct b43_wldev *dev, st
 		/* Not enough memory on the queue. */
 		err = -EBUSY;
 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
-		q->stopped = 1;
+		q->stopped = true;
 		goto out;
 	}
 
@@ -566,7 +566,7 @@ int b43_pio_tx(struct b43_wldev *dev, st
 	    (q->free_packet_slots == 0)) {
 		/* The queue is full. */
 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
-		q->stopped = 1;
+		q->stopped = true;
 	}
 
 out:
@@ -601,7 +601,7 @@ void b43_pio_handle_txstatus(struct b43_
 
 	if (q->stopped) {
 		ieee80211_wake_queue(dev->wl->hw, q->queue_prio);
-		q->stopped = 0;
+		q->stopped = false;
 	}
 }
 
diff -u -p a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
--- a/drivers/net/wireless/b43/main.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/b43/main.c 2011-12-19 13:23:17.828434721 +1030
@@ -1122,17 +1122,17 @@ void b43_power_saving_ctl_bits(struct b4
 	B43_WARN_ON((ps_flags & B43_PS_AWAKE) && (ps_flags & B43_PS_ASLEEP));
 
 	if (ps_flags & B43_PS_ENABLED) {
-		hwps = 1;
+		hwps = true;
 	} else if (ps_flags & B43_PS_DISABLED) {
-		hwps = 0;
+		hwps = false;
 	} else {
 		//TODO: If powersave is not off and FIXME is not set and we are not in adhoc
 		//      and thus is not an AP and we are associated, set bit 25
 	}
 	if (ps_flags & B43_PS_AWAKE) {
-		awake = 1;
+		awake = true;
 	} else if (ps_flags & B43_PS_ASLEEP) {
-		awake = 0;
+		awake = false;
 	} else {
 		//TODO: If the device is awake or this is an AP, or we are scanning, or FIXME,
 		//      or we are associated, or FIXME, or the latest PS-Poll packet sent was
@@ -1140,8 +1140,8 @@ void b43_power_saving_ctl_bits(struct b4
 	}
 
 /* FIXME: For now we force awake-on and hwps-off */
-	hwps = 0;
-	awake = 1;
+	hwps = false;
+	awake = true;
 
 	macctl = b43_read32(dev, B43_MMIO_MACCTL);
 	if (hwps)
@@ -1339,7 +1339,7 @@ static void b43_calculate_link_quality(s
 		return;
 	if (dev->noisecalc.calculation_running)
 		return;
-	dev->noisecalc.calculation_running = 1;
+	dev->noisecalc.calculation_running = true;
 	dev->noisecalc.nr_samples = 0;
 
 	b43_generate_noise_sample(dev);
@@ -1408,7 +1408,7 @@ static void handle_irq_noise(struct b43_
 			average -= 48;
 
 		dev->stats.link_noise = average;
-		dev->noisecalc.calculation_running = 0;
+		dev->noisecalc.calculation_running = false;
 		return;
 	}
 generate_new:
@@ -1424,7 +1424,7 @@ static void handle_irq_tbtt_indication(s
 			b43_power_saving_ctl_bits(dev, 0);
 	}
 	if (b43_is_mode(dev->wl, NL80211_IFTYPE_ADHOC))
-		dev->dfq_valid = 1;
+		dev->dfq_valid = true;
 }
 
 static void handle_irq_atim_end(struct b43_wldev *dev)
@@ -1433,7 +1433,7 @@ static void handle_irq_atim_end(struct b
 		b43_write32(dev, B43_MMIO_MACCMD,
 			    b43_read32(dev, B43_MMIO_MACCMD)
 			    | B43_MACCMD_DFQ_VALID);
-		dev->dfq_valid = 0;
+		dev->dfq_valid = false;
 	}
 }
 
@@ -1539,7 +1539,7 @@ static void b43_write_beacon_template(st
 	unsigned int i, len, variable_len;
 	const struct ieee80211_mgmt *bcn;
 	const u8 *ie;
-	bool tim_found = 0;
+	bool tim_found = false;
 	unsigned int rate;
 	u16 ctl;
 	int antenna;
@@ -1588,7 +1588,7 @@ static void b43_write_beacon_template(st
 			/* A valid TIM is at least 4 bytes long. */
 			if (ie_len < 4)
 				break;
-			tim_found = 1;
+			tim_found = true;
 
 			tim_position = sizeof(struct b43_plcp_hdr6);
 			tim_position += offsetof(struct ieee80211_mgmt, u.beacon.variable);
@@ -1625,7 +1625,7 @@ static void b43_upload_beacon0(struct b4
 	if (wl->beacon0_uploaded)
 		return;
 	b43_write_beacon_template(dev, 0x68, 0x18);
-	wl->beacon0_uploaded = 1;
+	wl->beacon0_uploaded = true;
 }
 
 static void b43_upload_beacon1(struct b43_wldev *dev)
@@ -1635,7 +1635,7 @@ static void b43_upload_beacon1(struct b4
 	if (wl->beacon1_uploaded)
 		return;
 	b43_write_beacon_template(dev, 0x468, 0x1A);
-	wl->beacon1_uploaded = 1;
+	wl->beacon1_uploaded = true;
 }
 
 static void handle_irq_beacon(struct b43_wldev *dev)
@@ -1667,7 +1667,7 @@ static void handle_irq_beacon(struct b43
 	if (unlikely(wl->beacon_templates_virgin)) {
 		/* We never uploaded a beacon before.
 		 * Upload both templates now, but only mark one valid. */
-		wl->beacon_templates_virgin = 0;
+		wl->beacon_templates_virgin = false;
 		b43_upload_beacon0(dev);
 		b43_upload_beacon1(dev);
 		cmd = b43_read32(dev, B43_MMIO_MACCMD);
@@ -1755,8 +1755,8 @@ static void b43_update_templates(struct
 	if (wl->current_beacon)
 		dev_kfree_skb_any(wl->current_beacon);
 	wl->current_beacon = beacon;
-	wl->beacon0_uploaded = 0;
-	wl->beacon1_uploaded = 0;
+	wl->beacon0_uploaded = false;
+	wl->beacon1_uploaded = false;
 	ieee80211_queue_work(wl->hw, &wl->beacon_update_trigger);
 }
 
@@ -1913,7 +1913,7 @@ static void b43_do_interrupt_thread(stru
 			b43err(dev->wl, "This device does not support DMA "
 			       "on your system. It will now be switched to PIO.\n");
 			/* Fall back to PIO transfers if we get fatal DMA errors! */
-			dev->use_pio = 1;
+			dev->use_pio = true;
 			b43_controller_restart(dev, "DMA error");
 			return;
 		}
@@ -2240,12 +2240,12 @@ static int b43_try_request_fw(struct b43
 		filename = NULL;
 	else
 		goto err_no_pcm;
-	fw->pcm_request_failed = 0;
+	fw->pcm_request_failed = false;
 	err = b43_do_request_fw(ctx, filename, &fw->pcm);
 	if (err == -ENOENT) {
 		/* We did not find a PCM file? Not fatal, but
 		 * core rev <= 10 must do without hwcrypto then. */
-		fw->pcm_request_failed = 1;
+		fw->pcm_request_failed = true;
 	} else if (err)
 		goto err_load;
 
@@ -2535,7 +2535,7 @@ static int b43_upload_microcode(struct b
 	dev->wl->hw->queues = dev->wl->mac80211_initially_registered_queues;
 	dev->qos_enabled = !!modparam_qos;
 	/* Default to firmware/hardware crypto acceleration. */
-	dev->hwcrypto_enabled = 1;
+	dev->hwcrypto_enabled = true;
 
 	if (dev->fw.opensource) {
 		u16 fwcapa;
@@ -2549,7 +2549,7 @@ static int b43_upload_microcode(struct b
 		if (!(fwcapa & B43_FWCAPA_HWCRYPTO) || dev->fw.pcm_request_failed) {
 			b43info(dev->wl, "Hardware crypto acceleration not supported by firmware\n");
 			/* Disable hardware crypto and fall back to software crypto. */
-			dev->hwcrypto_enabled = 0;
+			dev->hwcrypto_enabled = false;
 		}
 		if (!(fwcapa & B43_FWCAPA_QOS)) {
 			b43info(dev->wl, "QoS not supported by firmware\n");
@@ -2557,7 +2557,7 @@ static int b43_upload_microcode(struct b
 			 * ieee80211_unregister to make sure the networking core can
 			 * properly free possible resources. */
 			dev->wl->hw->queues = 1;
-			dev->qos_enabled = 0;
+			dev->qos_enabled = false;
 		}
 	} else {
 		b43info(dev->wl, "Loading firmware version %u.%u "
@@ -3361,10 +3361,10 @@ static int b43_rng_init(struct b43_wl *w
 	wl->rng.name = wl->rng_name;
 	wl->rng.data_read = b43_rng_read;
 	wl->rng.priv = (unsigned long)wl;
-	wl->rng_initialized = 1;
+	wl->rng_initialized = true;
 	err = hwrng_register(&wl->rng);
 	if (err) {
-		wl->rng_initialized = 0;
+		wl->rng_initialized = false;
 		b43err(wl, "Failed to register the random "
 		       "number generator (%d)\n", err);
 	}
@@ -3702,13 +3702,13 @@ static int b43_switch_band(struct b43_wl
 		case IEEE80211_BAND_5GHZ:
 			if (d->phy.supports_5ghz) {
 				up_dev = d;
-				gmode = 0;
+				gmode = false;
 			}
 			break;
 		case IEEE80211_BAND_2GHZ:
 			if (d->phy.supports_2ghz) {
 				up_dev = d;
-				gmode = 1;
+				gmode = true;
 			}
 			break;
 		default:
@@ -4425,18 +4425,18 @@ static void setup_struct_phy_for_init(st
 	atomic_set(&phy->txerr_cnt, B43_PHY_TX_BADNESS_LIMIT);
 
 #if B43_DEBUG
-	phy->phy_locked = 0;
-	phy->radio_locked = 0;
+	phy->phy_locked = false;
+	phy->radio_locked = false;
 #endif
 }
 
 static void setup_struct_wldev_for_init(struct b43_wldev *dev)
 {
-	dev->dfq_valid = 0;
+	dev->dfq_valid = false;
 
 	/* Assume the radio is enabled. If it's not enabled, the state will
 	 * immediately get fixed on the first periodic work run. */
-	dev->radio_hw_enable = 1;
+	dev->radio_hw_enable = true;
 
 	/* Stats */
 	memset(&dev->stats, 0, sizeof(dev->stats));
@@ -4670,16 +4670,16 @@ static int b43_wireless_core_init(struct
 
 	if (b43_bus_host_is_pcmcia(dev->dev) ||
 	    b43_bus_host_is_sdio(dev->dev)) {
-		dev->__using_pio_transfers = 1;
+		dev->__using_pio_transfers = true;
 		err = b43_pio_init(dev);
 	} else if (dev->use_pio) {
 		b43warn(dev->wl, "Forced PIO by use_pio module parameter. "
 			"This should not be needed and will result in lower "
 			"performance.\n");
-		dev->__using_pio_transfers = 1;
+		dev->__using_pio_transfers = true;
 		err = b43_pio_init(dev);
 	} else {
-		dev->__using_pio_transfers = 0;
+		dev->__using_pio_transfers = false;
 		err = b43_dma_init(dev);
 	}
 	if (err)
@@ -4733,7 +4733,7 @@ static int b43_op_add_interface(struct i
 	b43dbg(wl, "Adding Interface type %d\n", vif->type);
 
 	dev = wl->current_dev;
-	wl->operating = 1;
+	wl->operating = true;
 	wl->vif = vif;
 	wl->if_type = vif->type;
 	memcpy(wl->mac_addr, vif->addr, ETH_ALEN);
@@ -4767,7 +4767,7 @@ static void b43_op_remove_interface(stru
 	B43_WARN_ON(wl->vif != vif);
 	wl->vif = NULL;
 
-	wl->operating = 0;
+	wl->operating = false;
 
 	b43_adjust_opmode(dev);
 	memset(wl->mac_addr, 0, ETH_ALEN);
@@ -4789,12 +4789,12 @@ static int b43_op_start(struct ieee80211
 	memset(wl->bssid, 0, ETH_ALEN);
 	memset(wl->mac_addr, 0, ETH_ALEN);
 	wl->filter_flags = 0;
-	wl->radiotap_enabled = 0;
+	wl->radiotap_enabled = false;
 	b43_qos_clear(wl);
-	wl->beacon0_uploaded = 0;
-	wl->beacon1_uploaded = 0;
-	wl->beacon_templates_virgin = 1;
-	wl->radio_enabled = 1;
+	wl->beacon0_uploaded = false;
+	wl->beacon1_uploaded = false;
+	wl->beacon_templates_virgin = true;
+	wl->radio_enabled = true;
 
 	mutex_lock(&wl->mutex);
 
@@ -4840,7 +4840,7 @@ static void b43_op_stop(struct ieee80211
 			goto out_unlock;
 	}
 	b43_wireless_core_exit(dev);
-	wl->radio_enabled = 0;
+	wl->radio_enabled = false;
 
 out_unlock:
 	mutex_unlock(&wl->mutex);
@@ -5028,7 +5028,7 @@ static int b43_wireless_core_attach(stru
 	struct pci_dev *pdev = NULL;
 	int err;
 	u32 tmp;
-	bool have_2ghz_phy = 0, have_5ghz_phy = 0;
+	bool have_2ghz_phy = false, have_5ghz_phy = false;
 
 	/* Do NOT do any device initialization here.
 	 * Do it in wireless_core_init() instead.
@@ -5071,7 +5071,7 @@ static int b43_wireless_core_attach(stru
 	}
 
 	dev->phy.gmode = have_2ghz_phy;
-	dev->phy.radio_on = 1;
+	dev->phy.radio_on = true;
 	b43_wireless_core_reset(dev, dev->phy.gmode);
 
 	err = b43_phy_versioning(dev);
@@ -5082,11 +5082,11 @@ static int b43_wireless_core_attach(stru
 	    (pdev->device != 0x4312 &&
 	     pdev->device != 0x4319 && pdev->device != 0x4324)) {
 		/* No multiband support. */
-		have_2ghz_phy = 0;
-		have_5ghz_phy = 0;
+		have_2ghz_phy = false;
+		have_5ghz_phy = false;
 		switch (dev->phy.type) {
 		case B43_PHYTYPE_A:
-			have_5ghz_phy = 1;
+			have_5ghz_phy = true;
 			break;
 		case B43_PHYTYPE_LP: //FIXME not always!
 #if 0 //FIXME enabling 5GHz causes a NULL pointer dereference
@@ -5096,7 +5096,7 @@ static int b43_wireless_core_attach(stru
 		case B43_PHYTYPE_N:
 		case B43_PHYTYPE_HT:
 		case B43_PHYTYPE_LCN:
-			have_2ghz_phy = 1;
+			have_2ghz_phy = true;
 			break;
 		default:
 			B43_WARN_ON(1);
@@ -5112,8 +5112,8 @@ static int b43_wireless_core_attach(stru
 		/* FIXME: For now we disable the A-PHY on multi-PHY devices. */
 		if (dev->phy.type != B43_PHYTYPE_N &&
 		    dev->phy.type != B43_PHYTYPE_LP) {
-			have_2ghz_phy = 1;
-			have_5ghz_phy = 0;
+			have_2ghz_phy = true;
+			have_5ghz_phy = false;
 		}
 	}
 
diff -u -p a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
--- a/drivers/net/wireless/iwmc3200wifi/rx.c 2011-05-28 15:06:19.000000000 +0930
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c 2011-12-19 13:23:19.492434763 +1030
@@ -660,7 +660,7 @@ static int iwm_mlme_profile_invalidate(s
 	clear_bit(IWM_STATUS_SME_CONNECTING, &iwm->status);
 	clear_bit(IWM_STATUS_ASSOCIATED, &iwm->status);
 
-	iwm->umac_profile_active = 0;
+	iwm->umac_profile_active = false;
 	memset(iwm->bssid, 0, ETH_ALEN);
 	iwm->channel = 0;
 
@@ -735,7 +735,7 @@ static int iwm_mlme_update_sta_table(str
 			     umac_sta->mac_addr,
 			     umac_sta->flags & UMAC_STA_FLAG_QOS);
 
-		sta->valid = 1;
+		sta->valid = true;
 		sta->qos = umac_sta->flags & UMAC_STA_FLAG_QOS;
 		sta->color = GET_VAL8(umac_sta->sta_id, LMAC_STA_COLOR);
 		memcpy(sta->addr, umac_sta->mac_addr, ETH_ALEN);
@@ -750,12 +750,12 @@ static int iwm_mlme_update_sta_table(str
 		sta = &iwm->sta_table[GET_VAL8(umac_sta->sta_id, LMAC_STA_ID)];
 
 		if (!memcmp(sta->addr, umac_sta->mac_addr, ETH_ALEN))
-			sta->valid = 0;
+			sta->valid = false;
 
 		break;
 	case UMAC_OPCODE_CLEAR_ALL:
 		for (i = 0; i < IWM_STA_TABLE_NUM; i++)
-			iwm->sta_table[i].valid = 0;
+			iwm->sta_table[i].valid = false;
 
 		break;
 	default:
@@ -1203,7 +1203,7 @@ static int iwm_ntf_wifi_if_wrapper(struc
 
 	switch (hdr->oid) {
 	case UMAC_WIFI_IF_CMD_SET_PROFILE:
-		iwm->umac_profile_active = 1;
+		iwm->umac_profile_active = true;
 		break;
 	default:
 		break;
@@ -1363,7 +1363,7 @@ static int iwm_rx_handle_nonwifi(struct
 	 */
 	list_for_each_entry(cmd, &iwm->nonwifi_pending_cmd, pending)
 		if (cmd->seq_num == seq_num) {
-			cmd->resp_received = 1;
+			cmd->resp_received = true;
 			cmd->buf.len = buf_size;
 			memcpy(cmd->buf.hdr, buf, buf_size);
 			wake_up_interruptible(&iwm->nonwifi_queue);
diff -u -p a/drivers/net/wireless/iwmc3200wifi/main.c b/drivers/net/wireless/iwmc3200wifi/main.c
--- a/drivers/net/wireless/iwmc3200wifi/main.c 2011-12-19 13:09:30.712413542 +1030
+++ b/drivers/net/wireless/iwmc3200wifi/main.c 2011-12-19 13:23:19.900434774 +1030
@@ -130,7 +130,7 @@ static void iwm_disconnect_work(struct w
 		iwm_invalidate_mlme_profile(iwm);
 
 	clear_bit(IWM_STATUS_ASSOCIATED, &iwm->status);
-	iwm->umac_profile_active = 0;
+	iwm->umac_profile_active = false;
 	memset(iwm->bssid, 0, ETH_ALEN);
 	iwm->channel = 0;
 
diff -u -p a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
--- a/drivers/net/wireless/libertas/if_cs.c 2011-05-28 15:06:19.000000000 +0930
+++ b/drivers/net/wireless/libertas/if_cs.c 2011-12-19 13:23:21.148434806 +1030
@@ -859,7 +859,7 @@ static int if_cs_probe(struct pcmcia_dev
 	 * Most of the libertas cards can do unaligned register access, but some
 	 * weird ones cannot. That's especially true for the CF8305 card.
 	 */
-	card->align_regs = 0;
+	card->align_regs = false;
 
 	card->model = get_model(p_dev->manf_id, p_dev->card_id);
 	if (card->model == MODEL_UNKNOWN) {
@@ -871,7 +871,7 @@ static int if_cs_probe(struct pcmcia_dev
 	/* Check if we have a current silicon */
 	prod_id = if_cs_read8(card, IF_CS_PRODUCT_ID);
 	if (card->model == MODEL_8305) {
-		card->align_regs = 1;
+		card->align_regs = true;
 		if (prod_id < IF_CS_CF8305_B1_REV) {
 			pr_err("8305 rev B0 and older are not supported\n");
 			ret = -ENODEV;
diff -u -p a/drivers/net/wireless/wl12xx/sdio_test.c b/drivers/net/wireless/wl12xx/sdio_test.c
--- a/drivers/net/wireless/wl12xx/sdio_test.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/wl12xx/sdio_test.c 2011-12-19 13:23:22.184434832 +1030
@@ -341,8 +341,8 @@ static int tester(void *data)
 	struct sdio_func *func = wl_to_func(wl);
 	struct device *pdev = &func->dev;
 	int ret = 0;
-	bool rx_started = 0;
-	bool tx_started = 0;
+	bool rx_started = false;
+	bool tx_started = false;
 	uint8_t *tx_buf, *rx_buf;
 	int test_size = PAGE_SIZE;
 	u32 addr = 0;
@@ -371,18 +371,18 @@ static int tester(void *data)
 	while (!kthread_should_stop()) {
 		if (rx && !rx_started) {
 			dev_info(pdev, "starting rx test\n");
-			rx_started = 1;
+			rx_started = true;
 		} else if (!rx && rx_started) {
 			dev_info(pdev, "stopping rx test\n");
-			rx_started = 0;
+			rx_started = false;
 		}
 
 		if (tx && !tx_started) {
 			dev_info(pdev, "starting tx test\n");
-			tx_started = 1;
+			tx_started = true;
 		} else if (!tx && tx_started) {
 			dev_info(pdev, "stopping tx test\n");
-			tx_started = 0;
+			tx_started = false;
 		}
 
 		if (rx_started)
diff -u -p a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c 2011-11-21 11:21:33.000000000 +1030
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c 2011-12-19 13:23:24.928434902 +1030
@@ -627,10 +627,10 @@ struct dma_pub *dma_attach(char *name, s
 	/* WAR64450 : DMACtl.Addr ext fields are not supported in SDIOD core. */
 	if ((ai_coreid(sih) == SDIOD_CORE_ID)
 	    && ((ai_corerev(sih) > 0) && (ai_corerev(sih) <= 2)))
-		di->addrext = 0;
+		di->addrext = false;
 	else if ((ai_coreid(sih) == I2S_CORE_ID) &&
 		 ((ai_corerev(sih) == 0) || (ai_corerev(sih) == 1)))
-		di->addrext = 0;
+		di->addrext = false;
 	else
 		di->addrext = _dma_isaddrext(di);
 
diff -u -p a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c 2011-12-19 13:23:26.584434944 +1030
@@ -1603,7 +1603,7 @@ wlc_lcnphy_set_chanspec_tweaks(struct br
 		si_pmu_pllupd(pi->sh->sih);
 		write_phy_reg(pi, 0x942, 0);
 		wlc_lcnphy_txrx_spur_avoidance_mode(pi, false);
-		pi_lcn->lcnphy_spurmod = 0;
+		pi_lcn->lcnphy_spurmod = false;
 		mod_phy_reg(pi, 0x424, (0xff << 8), (0x1b) << 8);
 
 		write_phy_reg(pi, 0x425, 0x5907);
@@ -1616,7 +1616,7 @@ wlc_lcnphy_set_chanspec_tweaks(struct br
 		write_phy_reg(pi, 0x942, 0);
 		wlc_lcnphy_txrx_spur_avoidance_mode(pi, true);
 
-		pi_lcn->lcnphy_spurmod = 0;
+		pi_lcn->lcnphy_spurmod = false;
 		mod_phy_reg(pi, 0x424, (0xff << 8), (0x1f) << 8);
 
 		write_phy_reg(pi, 0x425, 0x590a);
@@ -2325,7 +2325,7 @@ static s8 wlc_lcnphy_tempcompensated_txp
 {
 	s8 index, delta_brd, delta_temp, new_index, tempcorrx;
 	s16 manp, meas_temp, temp_diff;
-	bool neg = 0;
+	bool neg = false;
 	u16 temp;
 	struct brcms_phy_lcnphy *pi_lcn = pi->u.pi_lcnphy;
 
@@ -2348,7 +2348,7 @@ static s8 wlc_lcnphy_tempcompensated_txp
 	manp = LCNPHY_TEMPSENSE(pi_lcn->lcnphy_rawtempsense);
 	temp_diff = manp - meas_temp;
 	if (temp_diff < 0) {
-		neg = 1;
+		neg = true;
 		temp_diff = -temp_diff;
 	}
 
@@ -3681,8 +3681,8 @@ wlc_lcnphy_a1(struct brcms_phy *pi, int
 	wlc_lcnphy_set_cc(pi, cal_type, phy_c15, phy_c16);
 	udelay(20);
 	for (phy_c8 = 0; phy_c7 != 0 && phy_c8 < num_levels; phy_c8++) {
-		phy_c23 = 1;
-		phy_c22 = 0;
+		phy_c23 = true;
+		phy_c22 = false;
 		switch (cal_type) {
 		case 0:
 			phy_c10 = 511;
@@ -3700,18 +3700,18 @@ wlc_lcnphy_a1(struct brcms_phy *pi, int
 
 		phy_c9 = read_phy_reg(pi, 0x93d);
 		phy_c9 = 2 * phy_c9;
-		phy_c24 = 0;
+		phy_c24 = false;
 		phy_c5 = 7;
-		phy_c25 = 1;
+		phy_c25 = true;
 		while (1) {
 			write_radio_reg(pi, RADIO_2064_REG026,
 					(phy_c5 & 0x7) | ((phy_c5 & 0x7) << 4));
 			udelay(50);
-			phy_c22 = 0;
+			phy_c22 = false;
 			ptr[130] = 0;
 			wlc_lcnphy_samp_cap(pi, 1, phy_c9, &ptr[0], 2);
 			if (ptr[130] == 1)
-				phy_c22 = 1;
+				phy_c22 = true;
 			if (phy_c22)
 				phy_c5 -= 1;
 			if ((phy_c22 != phy_c24) && (!phy_c25))
@@ -3721,7 +3721,7 @@ wlc_lcnphy_a1(struct brcms_phy *pi, int
 			if (phy_c5 <= 0 || phy_c5 >= 7)
 				break;
 			phy_c24 = phy_c22;
-			phy_c25 = 0;
+			phy_c25 = false;
 		}
 
 		if (phy_c5 < 0)
@@ -3772,10 +3772,10 @@ wlc_lcnphy_a1(struct brcms_phy *pi, int
 					phy_c13 = phy_c11;
 					phy_c14 = phy_c12;
 				}
-				phy_c23 = 0;
+				phy_c23 = false;
 			}
 		}
-		phy_c23 = 1;
+		phy_c23 = true;
 		phy_c15 = phy_c13;
 		phy_c16 = phy_c14;
 		phy_c7 = phy_c7 >> 1;
@@ -3965,7 +3965,7 @@ s16 wlc_lcnphy_tempsense_new(struct brcm
 {
 	u16 tempsenseval1, tempsenseval2;
 	s16 avg = 0;
-	bool suspend = 0;
+	bool suspend = false;
 
 	if (mode == 1) {
 		suspend =
@@ -4007,7 +4007,7 @@ u16 wlc_lcnphy_tempsense(struct brcms_ph
 {
 	u16 tempsenseval1, tempsenseval2;
 	s32 avg = 0;
-	bool suspend = 0;
+	bool suspend = false;
 	u16 SAVE_txpwrctrl = wlc_lcnphy_get_tx_pwr_ctrl(pi);
 	struct brcms_phy_lcnphy *pi_lcn = pi->u.pi_lcnphy;
 
@@ -4075,7 +4075,7 @@ s8 wlc_lcnphy_vbatsense(struct brcms_phy
 {
 	u16 vbatsenseval;
 	s32 avg = 0;
-	bool suspend = 0;
+	bool suspend = false;
 
 	if (mode == 1) {
 		suspend =
diff -u -p a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c 2011-12-19 13:23:39.144435266 +1030
@@ -1332,7 +1332,7 @@ uint brcms_reset(struct brcms_info *wl)
 	brcms_c_reset(wl->wlc);
 
 	/* dpc will not be rescheduled */
-	wl->resched = 0;
+	wl->resched = false;
 
 	return 0;
 }
diff -u -p a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c 2011-12-19 13:23:42.196435345 +1030
@@ -845,7 +845,7 @@ static int brcmf_netdev_stop(struct net_
 		return 0;
 
 	/* Set state and stop OS transmissions */
-	drvr->up = 0;
+	drvr->up = false;
 	netif_stop_queue(ndev);
 
 	return 0;
@@ -884,7 +884,7 @@ static int brcmf_netdev_open(struct net_
 	}
 	/* Allow transmit calls */
 	netif_start_queue(ndev);
-	drvr_priv->pub.up = 1;
+	drvr_priv->pub.up = true;
 	if (brcmf_cfg80211_up(drvr_priv->pub.config)) {
 		brcmf_dbg(ERROR, "failed to bring up cfg80211\n");
 		return -1;
diff -u -p a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
--- a/drivers/net/wireless/mwl8k.c 2011-12-19 13:09:30.716413542 +1030
+++ b/drivers/net/wireless/mwl8k.c 2011-12-19 13:23:44.756435410 +1030
@@ -738,10 +738,10 @@ static int mwl8k_load_firmware(struct ie
 
 		ready_code = ioread32(priv->regs + MWL8K_HIU_INT_CODE);
 		if (ready_code == MWL8K_FWAP_READY) {
-			priv->ap_fw = 1;
+			priv->ap_fw = true;
 			break;
 		} else if (ready_code == MWL8K_FWSTA_READY) {
-			priv->ap_fw = 0;
+			priv->ap_fw = false;
 			break;
 		}
 
@@ -5517,8 +5517,8 @@ static int mwl8k_firmware_load_success(s
 	INIT_LIST_HEAD(&priv->vif_list);
 
 	/* Set default radio state and preamble */
-	priv->radio_on = 0;
-	priv->radio_short_preamble = 0;
+	priv->radio_on = false;
+	priv->radio_short_preamble = false;
 
 	/* Finalize join worker */
 	INIT_WORK(&priv->finalize_join_worker, mwl8k_finalize_join_worker);
diff -u -p a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c 2011-10-27 10:37:52.000000000 +1030
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c 2011-12-19 13:23:50.220435550 +1030
@@ -1381,7 +1381,7 @@ static void __iwl_down(struct iwl_priv *
 	/* reset BT coex data */
 	priv->bt_status = 0;
 	priv->cur_rssi_ctx = NULL;
-	priv->bt_is_sco = 0;
+	priv->bt_is_sco = false;
 	if (priv->cfg->bt_params)
 		priv->bt_traffic_load =
 			 priv->cfg->bt_params->bt_init_traffic_load;
diff -u -p a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
--- a/drivers/net/wireless/mac80211_hwsim.c 2011-11-07 15:50:48.000000000 +1030
+++ b/drivers/net/wireless/mac80211_hwsim.c 2011-12-19 13:23:52.012435595 +1030
@@ -707,7 +707,7 @@ static int mac80211_hwsim_start(struct i
 {
 	struct mac80211_hwsim_data *data = hw->priv;
 	wiphy_debug(hw->wiphy, "%s\n", __func__);
-	data->started = 1;
+	data->started = true;
 	return 0;
 }
 
@@ -715,7 +715,7 @@ static int mac80211_hwsim_start(struct i
 static void mac80211_hwsim_stop(struct ieee80211_hw *hw)
 {
 	struct mac80211_hwsim_data *data = hw->priv;
-	data->started = 0;
+	data->started = false;
 	del_timer(&data->beacon_timer);
 	wiphy_debug(hw->wiphy, "%s\n", __func__);
 }
diff -u -p a/net/dccp/options.c b/net/dccp/options.c
--- a/net/dccp/options.c 2011-05-19 15:03:22.000000000 +0930
+++ b/net/dccp/options.c 2011-12-19 13:29:33.116444329 +1030
@@ -544,7 +544,7 @@ int dccp_insert_fn_opt(struct sk_buff *s
 	}
 
 	if (unlikely(val == NULL || len == 0))
-		len = repeat_first = 0;
+		len = repeat_first = false;
 	tot_len = 3 + repeat_first + len;
 
 	if (DCCP_SKB_CB(skb)->dccpd_opt_len + tot_len > DCCP_MAX_OPT_LEN) {
diff -u -p a/net/dccp/feat.c b/net/dccp/feat.c
--- a/net/dccp/feat.c 2011-10-27 10:37:55.000000000 +1030
+++ b/net/dccp/feat.c 2011-12-19 13:29:33.576444342 +1030
@@ -490,8 +490,8 @@ static int dccp_feat_push_change(struct
 	new->feat_num	     = feat;
 	new->is_local	     = local;
 	new->state	     = FEAT_INITIALISING;
-	new->needs_confirm   = 0;
-	new->empty_confirm   = 0;
+	new->needs_confirm   = false;
+	new->empty_confirm   = false;
 	new->val	     = *fval;
 	new->needs_mandatory = mandatory;
 
@@ -517,12 +517,12 @@ static int dccp_feat_push_confirm(struct
 	new->feat_num	     = feat;
 	new->is_local	     = local;
 	new->state	     = FEAT_STABLE;	/* transition in 6.6.2 */
-	new->needs_confirm   = 1;
+	new->needs_confirm   = true;
 	new->empty_confirm   = (fval == NULL);
 	new->val.nn	     = 0;		/* zeroes the whole structure */
 	if (!new->empty_confirm)
 		new->val     = *fval;
-	new->needs_mandatory = 0;
+	new->needs_mandatory = false;
 
 	return 0;
 }
@@ -1155,7 +1155,7 @@ static u8 dccp_feat_change_recv(struct l
 	}
 
 	if (dccp_feat_reconcile(&entry->val, val, len, server, true)) {
-		entry->empty_confirm = 0;
+		entry->empty_confirm = false;
 	} else if (is_mandatory) {
 		return DCCP_RESET_CODE_MANDATORY_ERROR;
 	} else if (entry->state == FEAT_INITIALISING) {
@@ -1171,10 +1171,10 @@ static u8 dccp_feat_change_recv(struct l
 		defval = dccp_feat_default_value(feat);
 		if (!dccp_feat_reconcile(&entry->val, &defval, 1, server, true))
 			return DCCP_RESET_CODE_OPTION_ERROR;
-		entry->empty_confirm = 1;
+		entry->empty_confirm = true;
 	}
-	entry->needs_confirm   = 1;
-	entry->needs_mandatory = 0;
+	entry->needs_confirm   = true;
+	entry->needs_mandatory = false;
 	entry->state	       = FEAT_STABLE;
 	return 0;
 
diff -u -p a/net/mac80211/scan.c b/net/mac80211/scan.c
--- a/net/mac80211/scan.c 2011-11-07 15:50:48.000000000 +1030
+++ b/net/mac80211/scan.c 2011-12-19 13:29:39.276444488 +1030
@@ -106,7 +106,7 @@ ieee80211_bss_info_update(struct ieee802
 	/* save the ERP value so that it is available at association time */
 	if (elems->erp_info && elems->erp_info_len >= 1) {
 		bss->erp_value = elems->erp_info[0];
-		bss->has_erp_value = 1;
+		bss->has_erp_value = true;
 	}
 
 	if (elems->tim) {
diff -u -p a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
--- a/net/mac80211/rc80211_pid_algo.c 2010-08-23 11:46:56.000000000 +0930
+++ b/net/mac80211/rc80211_pid_algo.c 2011-12-19 13:29:40.776444526 +1030
@@ -318,7 +318,7 @@ rate_control_pid_rate_init(void *priv, s
 			rinfo[i].diff = i * pinfo->norm_offset;
 	}
 	for (i = 1; i < sband->n_bitrates; i++) {
-		s = 0;
+		s = false;
 		for (j = 0; j < sband->n_bitrates - i; j++)
 			if (unlikely(sband->bitrates[rinfo[j].index].bitrate >
 				     sband->bitrates[rinfo[j + 1].index].bitrate)) {
@@ -327,7 +327,7 @@ rate_control_pid_rate_init(void *priv, s
 				rinfo[j + 1].index = tmp;
 				rinfo[rinfo[j].index].rev_index = j;
 				rinfo[rinfo[j + 1].index].rev_index = j + 1;
-				s = 1;
+				s = true;
 			}
 		if (!s)
 			break;
diff -u -p a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c 2011-03-31 12:06:06.000000000 +1030
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c 2011-12-19 13:29:43.564444597 +1030
@@ -108,7 +108,7 @@ static bool ip_vs_sip_ct_match(const str
 				  struct ip_vs_conn *ct)
 
 {
-	bool ret = 0;
+	bool ret = false;
 
 	if (ct->af == p->af &&
 	    ip_vs_addr_equal(p->af, p->caddr, &ct->caddr) &&
@@ -121,7 +121,7 @@ static bool ip_vs_sip_ct_match(const str
 	    ct->protocol == p->protocol &&
 	    ct->pe_data && ct->pe_data_len == p->pe_data_len &&
 	    !memcmp(ct->pe_data, p->pe_data, p->pe_data_len))
-		ret = 1;
+		ret = true;
 
 	IP_VS_DBG_BUF(9, "SIP template match %s %s->%s:%d %s\n",
 		      ip_vs_proto_name(p->protocol),
diff -u -p a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c 2011-10-27 10:37:55.000000000 +1030
+++ b/net/ipv4/tcp_timer.c 2011-12-19 13:29:52.944444838 +1030
@@ -171,13 +171,13 @@ static int tcp_write_timeout(struct sock
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int retry_until;
-	bool do_reset, syn_set = 0;
+	bool do_reset, syn_set = false;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
 			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
-		syn_set = 1;
+		syn_set = true;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
 			/* Black hole detection */
diff -u -p a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
--- a/net/rfkill/rfkill-regulator.c 2011-10-27 10:37:55.000000000 +1030
+++ b/net/rfkill/rfkill-regulator.c 2011-12-19 13:29:59.740445012 +1030
@@ -36,12 +36,12 @@ static int rfkill_regulator_set_block(vo
 	if (blocked) {
 		if (rfkill_data->reg_enabled) {
 			regulator_disable(rfkill_data->vcc);
-			rfkill_data->reg_enabled = 0;
+			rfkill_data->reg_enabled = false;
 		}
 	} else {
 		if (!rfkill_data->reg_enabled) {
 			regulator_enable(rfkill_data->vcc);
-			rfkill_data->reg_enabled = 1;
+			rfkill_data->reg_enabled = true;
 		}
 	}
 
@@ -96,7 +96,7 @@ static int __devinit rfkill_regulator_pr
 
 	if (regulator_is_enabled(vcc)) {
 		dev_dbg(&pdev->dev, "Regulator already enabled\n");
-		rfkill_data->reg_enabled = 1;
+		rfkill_data->reg_enabled = true;
 	}
 	rfkill_data->vcc = vcc;
 	rfkill_data->rf_kill = rf_kill;
diff -u -p a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
--- a/net/rxrpc/ar-ack.c 2011-05-28 15:06:24.000000000 +0930
+++ b/net/rxrpc/ar-ack.c 2011-12-19 13:30:05.168445151 +1030
@@ -195,7 +195,7 @@ static void rxrpc_resend(struct rxrpc_ca
 		sp = rxrpc_skb(txb);
 
 		if (sp->need_resend) {
-			sp->need_resend = 0;
+			sp->need_resend = false;
 
 			/* each Tx packet has a new serial number */
 			sp->hdr.serial =
@@ -216,7 +216,7 @@ static void rxrpc_resend(struct rxrpc_ca
 		}
 
 		if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = 1;
+			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
 			if (time_before(sp->resend_at, resend_at))
@@ -265,7 +265,7 @@ static void rxrpc_resend_timer(struct rx
 		if (sp->need_resend) {
 			;
 		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = 1;
+			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
 			if (time_before(sp->resend_at, resend_at))
@@ -314,11 +314,11 @@ static int rxrpc_process_soft_ACKs(struc
 
 		switch (sacks[loop]) {
 		case RXRPC_ACK_TYPE_ACK:
-			sp->need_resend = 0;
+			sp->need_resend = false;
 			*p_txb |= 1;
 			break;
 		case RXRPC_ACK_TYPE_NACK:
-			sp->need_resend = 1;
+			sp->need_resend = true;
 			*p_txb &= ~1;
 			resend = 1;
 			break;
@@ -344,13 +344,13 @@ static int rxrpc_process_soft_ACKs(struc
 
 		if (*p_txb & 1) {
 			/* packet must have been discarded */
-			sp->need_resend = 1;
+			sp->need_resend = true;
 			*p_txb &= ~1;
 			resend |= 1;
 		} else if (sp->need_resend) {
 			;
 		} else if (time_after_eq(jiffies + 1, sp->resend_at)) {
-			sp->need_resend = 1;
+			sp->need_resend = true;
 			resend |= 1;
 		} else if (resend & 2) {
 			if (time_before(sp->resend_at, resend_at))
diff -u -p a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
--- a/net/rxrpc/ar-output.c 2011-11-07 15:50:48.000000000 +1030
+++ b/net/rxrpc/ar-output.c 2011-12-19 13:30:05.452445157 +1030
@@ -486,7 +486,7 @@ static void rxrpc_queue_packet(struct rx
 	_proto("Tx DATA %%%u { #%u }",
 	       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
 
-	sp->need_resend = 0;
+	sp->need_resend = false;
 	sp->resend_at = jiffies + rxrpc_resend_timeout * HZ;
 	if (!test_and_set_bit(RXRPC_CALL_RUN_RTIMER, &call->flags)) {
 		_debug("run timer");
@@ -508,7 +508,7 @@ static void rxrpc_queue_packet(struct rx
 
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
-		sp->need_resend = 1;
+		sp->need_resend = true;
 		rxrpc_instant_resend(call);
 	}
 
