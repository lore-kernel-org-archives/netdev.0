From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 11/12] tg3: Remove tg3_dump_state()
Date: Mon, 5 Apr 2010 13:19:29 -0700
Message-ID: <1270498770-23765-12-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2378 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756512Ab0DEUTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3_dump_state() function is commented out and doesn't get used much
when debugging efforts are underway.  The chip architecture has also
changed enough that any debugging effort that might use it would have to
tailor it to the capabilities of the hardware.  This patch just removes
the function entirely.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  233 -----------------------------------------------------
 1 files changed, 0 insertions(+), 233 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 47dea55..af14bcc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8925,236 +8925,6 @@ err_out1:
 	return err;
 }
 
-#if 0
-/*static*/ void tg3_dump_state(struct tg3 *tp)
-{
-	u32 val32, val32_2, val32_3, val32_4, val32_5;
-	u16 val16;
-	int i;
-	struct tg3_hw_status *sblk = tp->napi[0]->hw_status;
-
-	pci_read_config_word(tp->pdev, PCI_STATUS, &val16);
-	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE, &val32);
-	printk("DEBUG: PCI status [%04x] TG3PCI state[%08x]\n",
-	       val16, val32);
-
-	/* MAC block */
-	printk("DEBUG: MAC_MODE[%08x] MAC_STATUS[%08x]\n",
-	       tr32(MAC_MODE), tr32(MAC_STATUS));
-	printk("       MAC_EVENT[%08x] MAC_LED_CTRL[%08x]\n",
-	       tr32(MAC_EVENT), tr32(MAC_LED_CTRL));
-	printk("DEBUG: MAC_TX_MODE[%08x] MAC_TX_STATUS[%08x]\n",
-	       tr32(MAC_TX_MODE), tr32(MAC_TX_STATUS));
-	printk("       MAC_RX_MODE[%08x] MAC_RX_STATUS[%08x]\n",
-	       tr32(MAC_RX_MODE), tr32(MAC_RX_STATUS));
-
-	/* Send data initiator control block */
-	printk("DEBUG: SNDDATAI_MODE[%08x] SNDDATAI_STATUS[%08x]\n",
-	       tr32(SNDDATAI_MODE), tr32(SNDDATAI_STATUS));
-	printk("       SNDDATAI_STATSCTRL[%08x]\n",
-	       tr32(SNDDATAI_STATSCTRL));
-
-	/* Send data completion control block */
-	printk("DEBUG: SNDDATAC_MODE[%08x]\n", tr32(SNDDATAC_MODE));
-
-	/* Send BD ring selector block */
-	printk("DEBUG: SNDBDS_MODE[%08x] SNDBDS_STATUS[%08x]\n",
-	       tr32(SNDBDS_MODE), tr32(SNDBDS_STATUS));
-
-	/* Send BD initiator control block */
-	printk("DEBUG: SNDBDI_MODE[%08x] SNDBDI_STATUS[%08x]\n",
-	       tr32(SNDBDI_MODE), tr32(SNDBDI_STATUS));
-
-	/* Send BD completion control block */
-	printk("DEBUG: SNDBDC_MODE[%08x]\n", tr32(SNDBDC_MODE));
-
-	/* Receive list placement control block */
-	printk("DEBUG: RCVLPC_MODE[%08x] RCVLPC_STATUS[%08x]\n",
-	       tr32(RCVLPC_MODE), tr32(RCVLPC_STATUS));
-	printk("       RCVLPC_STATSCTRL[%08x]\n",
-	       tr32(RCVLPC_STATSCTRL));
-
-	/* Receive data and receive BD initiator control block */
-	printk("DEBUG: RCVDBDI_MODE[%08x] RCVDBDI_STATUS[%08x]\n",
-	       tr32(RCVDBDI_MODE), tr32(RCVDBDI_STATUS));
-
-	/* Receive data completion control block */
-	printk("DEBUG: RCVDCC_MODE[%08x]\n",
-	       tr32(RCVDCC_MODE));
-
-	/* Receive BD initiator control block */
-	printk("DEBUG: RCVBDI_MODE[%08x] RCVBDI_STATUS[%08x]\n",
-	       tr32(RCVBDI_MODE), tr32(RCVBDI_STATUS));
-
-	/* Receive BD completion control block */
-	printk("DEBUG: RCVCC_MODE[%08x] RCVCC_STATUS[%08x]\n",
-	       tr32(RCVCC_MODE), tr32(RCVCC_STATUS));
-
-	/* Receive list selector control block */
-	printk("DEBUG: RCVLSC_MODE[%08x] RCVLSC_STATUS[%08x]\n",
-	       tr32(RCVLSC_MODE), tr32(RCVLSC_STATUS));
-
-	/* Mbuf cluster free block */
-	printk("DEBUG: MBFREE_MODE[%08x] MBFREE_STATUS[%08x]\n",
-	       tr32(MBFREE_MODE), tr32(MBFREE_STATUS));
-
-	/* Host coalescing control block */
-	printk("DEBUG: HOSTCC_MODE[%08x] HOSTCC_STATUS[%08x]\n",
-	       tr32(HOSTCC_MODE), tr32(HOSTCC_STATUS));
-	printk("DEBUG: HOSTCC_STATS_BLK_HOST_ADDR[%08x%08x]\n",
-	       tr32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH),
-	       tr32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW));
-	printk("DEBUG: HOSTCC_STATUS_BLK_HOST_ADDR[%08x%08x]\n",
-	       tr32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH),
-	       tr32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW));
-	printk("DEBUG: HOSTCC_STATS_BLK_NIC_ADDR[%08x]\n",
-	       tr32(HOSTCC_STATS_BLK_NIC_ADDR));
-	printk("DEBUG: HOSTCC_STATUS_BLK_NIC_ADDR[%08x]\n",
-	       tr32(HOSTCC_STATUS_BLK_NIC_ADDR));
-
-	/* Memory arbiter control block */
-	printk("DEBUG: MEMARB_MODE[%08x] MEMARB_STATUS[%08x]\n",
-	       tr32(MEMARB_MODE), tr32(MEMARB_STATUS));
-
-	/* Buffer manager control block */
-	printk("DEBUG: BUFMGR_MODE[%08x] BUFMGR_STATUS[%08x]\n",
-	       tr32(BUFMGR_MODE), tr32(BUFMGR_STATUS));
-	printk("DEBUG: BUFMGR_MB_POOL_ADDR[%08x] BUFMGR_MB_POOL_SIZE[%08x]\n",
-	       tr32(BUFMGR_MB_POOL_ADDR), tr32(BUFMGR_MB_POOL_SIZE));
-	printk("DEBUG: BUFMGR_DMA_DESC_POOL_ADDR[%08x] "
-	       "BUFMGR_DMA_DESC_POOL_SIZE[%08x]\n",
-	       tr32(BUFMGR_DMA_DESC_POOL_ADDR),
-	       tr32(BUFMGR_DMA_DESC_POOL_SIZE));
-
-	/* Read DMA control block */
-	printk("DEBUG: RDMAC_MODE[%08x] RDMAC_STATUS[%08x]\n",
-	       tr32(RDMAC_MODE), tr32(RDMAC_STATUS));
-
-	/* Write DMA control block */
-	printk("DEBUG: WDMAC_MODE[%08x] WDMAC_STATUS[%08x]\n",
-	       tr32(WDMAC_MODE), tr32(WDMAC_STATUS));
-
-	/* DMA completion block */
-	printk("DEBUG: DMAC_MODE[%08x]\n",
-	       tr32(DMAC_MODE));
-
-	/* GRC block */
-	printk("DEBUG: GRC_MODE[%08x] GRC_MISC_CFG[%08x]\n",
-	       tr32(GRC_MODE), tr32(GRC_MISC_CFG));
-	printk("DEBUG: GRC_LOCAL_CTRL[%08x]\n",
-	       tr32(GRC_LOCAL_CTRL));
-
-	/* TG3_BDINFOs */
-	printk("DEBUG: RCVDBDI_JUMBO_BD[%08x%08x:%08x:%08x]\n",
-	       tr32(RCVDBDI_JUMBO_BD + 0x0),
-	       tr32(RCVDBDI_JUMBO_BD + 0x4),
-	       tr32(RCVDBDI_JUMBO_BD + 0x8),
-	       tr32(RCVDBDI_JUMBO_BD + 0xc));
-	printk("DEBUG: RCVDBDI_STD_BD[%08x%08x:%08x:%08x]\n",
-	       tr32(RCVDBDI_STD_BD + 0x0),
-	       tr32(RCVDBDI_STD_BD + 0x4),
-	       tr32(RCVDBDI_STD_BD + 0x8),
-	       tr32(RCVDBDI_STD_BD + 0xc));
-	printk("DEBUG: RCVDBDI_MINI_BD[%08x%08x:%08x:%08x]\n",
-	       tr32(RCVDBDI_MINI_BD + 0x0),
-	       tr32(RCVDBDI_MINI_BD + 0x4),
-	       tr32(RCVDBDI_MINI_BD + 0x8),
-	       tr32(RCVDBDI_MINI_BD + 0xc));
-
-	tg3_read_mem(tp, NIC_SRAM_SEND_RCB + 0x0, &val32);
-	tg3_read_mem(tp, NIC_SRAM_SEND_RCB + 0x4, &val32_2);
-	tg3_read_mem(tp, NIC_SRAM_SEND_RCB + 0x8, &val32_3);
-	tg3_read_mem(tp, NIC_SRAM_SEND_RCB + 0xc, &val32_4);
-	printk("DEBUG: SRAM_SEND_RCB_0[%08x%08x:%08x:%08x]\n",
-	       val32, val32_2, val32_3, val32_4);
-
-	tg3_read_mem(tp, NIC_SRAM_RCV_RET_RCB + 0x0, &val32);
-	tg3_read_mem(tp, NIC_SRAM_RCV_RET_RCB + 0x4, &val32_2);
-	tg3_read_mem(tp, NIC_SRAM_RCV_RET_RCB + 0x8, &val32_3);
-	tg3_read_mem(tp, NIC_SRAM_RCV_RET_RCB + 0xc, &val32_4);
-	printk("DEBUG: SRAM_RCV_RET_RCB_0[%08x%08x:%08x:%08x]\n",
-	       val32, val32_2, val32_3, val32_4);
-
-	tg3_read_mem(tp, NIC_SRAM_STATUS_BLK + 0x0, &val32);
-	tg3_read_mem(tp, NIC_SRAM_STATUS_BLK + 0x4, &val32_2);
-	tg3_read_mem(tp, NIC_SRAM_STATUS_BLK + 0x8, &val32_3);
-	tg3_read_mem(tp, NIC_SRAM_STATUS_BLK + 0xc, &val32_4);
-	tg3_read_mem(tp, NIC_SRAM_STATUS_BLK + 0x10, &val32_5);
-	printk("DEBUG: SRAM_STATUS_BLK[%08x:%08x:%08x:%08x:%08x]\n",
-	       val32, val32_2, val32_3, val32_4, val32_5);
-
-	/* SW status block */
-	printk(KERN_DEBUG
-	 "Host status block [%08x:%08x:(%04x:%04x:%04x):(%04x:%04x)]\n",
-	       sblk->status,
-	       sblk->status_tag,
-	       sblk->rx_jumbo_consumer,
-	       sblk->rx_consumer,
-	       sblk->rx_mini_consumer,
-	       sblk->idx[0].rx_producer,
-	       sblk->idx[0].tx_consumer);
-
-	/* SW statistics block */
-	printk("DEBUG: Host statistics block [%08x:%08x:%08x:%08x]\n",
-	       ((u32 *)tp->hw_stats)[0],
-	       ((u32 *)tp->hw_stats)[1],
-	       ((u32 *)tp->hw_stats)[2],
-	       ((u32 *)tp->hw_stats)[3]);
-
-	/* Mailboxes */
-	printk("DEBUG: SNDHOST_PROD[%08x%08x] SNDNIC_PROD[%08x%08x]\n",
-	       tr32_mailbox(MAILBOX_SNDHOST_PROD_IDX_0 + 0x0),
-	       tr32_mailbox(MAILBOX_SNDHOST_PROD_IDX_0 + 0x4),
-	       tr32_mailbox(MAILBOX_SNDNIC_PROD_IDX_0 + 0x0),
-	       tr32_mailbox(MAILBOX_SNDNIC_PROD_IDX_0 + 0x4));
-
-	/* NIC side send descriptors. */
-	for (i = 0; i < 6; i++) {
-		unsigned long txd;
-
-		txd = tp->regs + NIC_SRAM_WIN_BASE + NIC_SRAM_TX_BUFFER_DESC
-			+ (i * sizeof(struct tg3_tx_buffer_desc));
-		printk("DEBUG: NIC TXD(%d)[%08x:%08x:%08x:%08x]\n",
-		       i,
-		       readl(txd + 0x0), readl(txd + 0x4),
-		       readl(txd + 0x8), readl(txd + 0xc));
-	}
-
-	/* NIC side RX descriptors. */
-	for (i = 0; i < 6; i++) {
-		unsigned long rxd;
-
-		rxd = tp->regs + NIC_SRAM_WIN_BASE + NIC_SRAM_RX_BUFFER_DESC
-			+ (i * sizeof(struct tg3_rx_buffer_desc));
-		printk("DEBUG: NIC RXD_STD(%d)[0][%08x:%08x:%08x:%08x]\n",
-		       i,
-		       readl(rxd + 0x0), readl(rxd + 0x4),
-		       readl(rxd + 0x8), readl(rxd + 0xc));
-		rxd += (4 * sizeof(u32));
-		printk("DEBUG: NIC RXD_STD(%d)[1][%08x:%08x:%08x:%08x]\n",
-		       i,
-		       readl(rxd + 0x0), readl(rxd + 0x4),
-		       readl(rxd + 0x8), readl(rxd + 0xc));
-	}
-
-	for (i = 0; i < 6; i++) {
-		unsigned long rxd;
-
-		rxd = tp->regs + NIC_SRAM_WIN_BASE + NIC_SRAM_RX_JUMBO_BUFFER_DESC
-			+ (i * sizeof(struct tg3_rx_buffer_desc));
-		printk("DEBUG: NIC RXD_JUMBO(%d)[0][%08x:%08x:%08x:%08x]\n",
-		       i,
-		       readl(rxd + 0x0), readl(rxd + 0x4),
-		       readl(rxd + 0x8), readl(rxd + 0xc));
-		rxd += (4 * sizeof(u32));
-		printk("DEBUG: NIC RXD_JUMBO(%d)[1][%08x:%08x:%08x:%08x]\n",
-		       i,
-		       readl(rxd + 0x0), readl(rxd + 0x4),
-		       readl(rxd + 0x8), readl(rxd + 0xc));
-	}
-}
-#endif
-
 static struct net_device_stats *tg3_get_stats(struct net_device *);
 static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *);
 
@@ -9173,9 +8943,6 @@ static int tg3_close(struct net_device *dev)
 	tg3_phy_stop(tp);
 
 	tg3_full_lock(tp, 1);
-#if 0
-	tg3_dump_state(tp);
-#endif
 
 	tg3_disable_ints(tp);
 
-- 
1.6.4.4


