From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 09/10] liquidio: Remove redundant code
Date: Sun, 3 Jul 2016 13:56:55 -0700
Message-ID: <1467579416-24219-10-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0083.outbound.protection.outlook.com ([104.47.32.83]:58282
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932291AbcGCVac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 17:30:32 -0400
In-Reply-To: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes redundant file includes and conditions.
Provides some meaningful comments and code alignment.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  2 +-
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |  1 -
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 18 ++++++---------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 26 +++++++++++-----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  5 +++--
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  4 ++--
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 12 +++++-----
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  4 ++--
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  4 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 13 ++++++++---
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  2 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  1 -
 .../net/ethernet/cavium/liquidio/request_manager.c |  6 +++--
 13 files changed, 51 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index 6271c57..c03d370 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -219,7 +219,7 @@ void lio_cn6xxx_setup_global_output_regs(struct octeon_device *oct)
 	/* / Select Packet count instead of bytes for SLI_PKTi_CNTS[CNT] */
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_BMODE, 0);
 
-	/* / Select ES,RO,NS setting from register for Output Queue Packet
+	/* Select ES, RO, NS setting from register for Output Queue Packet
 	 * Address
 	 */
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_DPADDR, 0xFFFFFFFF);
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
index 38cddbd..d45a0f4 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h
@@ -29,7 +29,6 @@
 
 #ifndef __CN68XX_REGS_H__
 #define __CN68XX_REGS_H__
-#include "cn66xx_regs.h"
 
 /*###################### REQUEST QUEUE #########################*/
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 82f20c9..289eb89 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -464,18 +464,16 @@ static int lio_set_phys_id(struct net_device *netdev,
 
 			/* Configure Beacon values */
 			value = LIO68XX_LED_BEACON_CFGON;
-			ret =
-				octnet_mdio45_access(lio, 1,
-						     LIO68XX_LED_BEACON_ADDR,
-						     &value);
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_BEACON_ADDR,
+						   &value);
 			if (ret)
 				return ret;
 
 			value = LIO68XX_LED_CTRL_CFGON;
-			ret =
-				octnet_mdio45_access(lio, 1,
-						     LIO68XX_LED_CTRL_ADDR,
-						     &value);
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_CTRL_ADDR,
+						   &value);
 			if (ret)
 				return ret;
 		} else {
@@ -961,7 +959,6 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 			intr_coal->rx_max_coalesced_frames =
 				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
 		}
-
 		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
 		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
 		break;
@@ -1688,13 +1685,12 @@ static void lio_get_regs(struct net_device *dev,
 	int len = 0;
 	struct octeon_device *oct = lio->oct_dev;
 
-	memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
 	regs->version = OCT_ETHTOOL_REGSVER;
 
 	switch (oct->chip_id) {
-	/* case OCTEON_CN73XX: Todo */
 	case OCTEON_CN68XX:
 	case OCTEON_CN66XX:
+		memset(regbuf, 0, OCT_ETHTOOL_REGDUMP_LEN);
 		len += cn6xxx_read_csr_reg(regbuf + len, oct);
 		len += cn6xxx_read_config_reg(regbuf + len, oct);
 		break;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index c75734f..20d6942 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1258,7 +1258,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 
 		/* Nothing to be done here either */
 		break;
-	}                       /* end switch(oct->status) */
+	}                       /* end switch (oct->status) */
 
 	tasklet_kill(&oct_priv->droq_tasklet);
 }
@@ -2125,7 +2125,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 /**
  * \brief Setup input and output queues
  * @param octeon_dev octeon device
- * @param net_device Net device
+ * @param ifidx  Interface Index
  *
  * Note: Queues are with respect to the octeon device. Thus
  * an input queue is for egress packets, and output queues
@@ -2336,7 +2336,6 @@ static int liquidio_stop(struct net_device *netdev)
 	}
 
 	dev_info(&oct->pci_dev->dev, "%s interface is stopped\n", netdev->name);
-	module_put(THIS_MODULE);
 
 	return 0;
 }
@@ -2347,6 +2346,7 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 	struct net_device *netdev = (struct net_device *)nctrl->netpndev;
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
+	u8 *mac;
 
 	switch (nctrl->ncmd.s.cmd) {
 	case OCTNET_CMD_CHANGE_DEVFLAGS:
@@ -2354,12 +2354,11 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 		break;
 
 	case OCTNET_CMD_CHANGE_MACADDR:
-		/* If command is successful, change the MACADDR. */
-		netif_info(lio, probe, lio->netdev, " MACAddr changed to 0x%llx\n",
-			   CVM_CAST64(nctrl->udd[0]));
-		dev_info(&oct->pci_dev->dev, "%s MACAddr changed to 0x%llx\n",
-			 netdev->name, CVM_CAST64(nctrl->udd[0]));
-		memcpy(netdev->dev_addr, ((u8 *)&nctrl->udd[0]) + 2, ETH_ALEN);
+		mac = ((u8 *)&nctrl->udd[0]) + 2;
+		netif_info(lio, probe, lio->netdev,
+			   "%s %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+			   "MACAddr changed to", mac[0], mac[1],
+			   mac[2], mac[3], mac[4], mac[5]);
 		break;
 
 	case OCTNET_CMD_CHANGE_MTU:
@@ -2940,12 +2939,12 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 			/* defer sending if queue is full */
 			stats->tx_iq_busy++;
 			netif_info(lio, tx_err, lio->netdev, "Transmit failed iq:%d full\n",
-				   ndata.q_no);
+				   lio->txq);
 			return NETDEV_TX_BUSY;
 		}
 	}
 	/* pr_info(" XMIT - valid Qs: %d, 1st Q no: %d, cpu:  %d, q_no:%d\n",
-	 *	lio->linfo.num_txpciq, lio->txq, cpu, ndata.q_no );
+	 *	lio->linfo.num_txpciq, lio->txq, cpu, ndata.q_no);
 	 */
 
 	ndata.datasize = skb->len;
@@ -2969,6 +2968,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (skb_shinfo(skb)->nr_frags == 0) {
 		cmdsetup.s.u.datasize = skb->len;
 		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
+
 		/* Offload checksum calculation for TCP/UDP packets */
 		dptr = dma_map_single(&oct->pci_dev->dev,
 				      skb->data,
@@ -3716,8 +3716,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		octeon_dev->priv_flags = 0x0;
 
 		if (netdev->features & NETIF_F_LRO)
-		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
-				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
+			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
+					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
 		liquidio_set_feature(netdev, OCTNET_CMD_ENABLE_VLAN_FILTER, 0);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index c6e3d57..603d205 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -34,6 +34,7 @@
 #define LIQUIDIO_MICRO_VERSION  ".1"
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_VERSION  "1.4.1"
+
 #define CONTROL_IQ 0
 /** Tag types used by Octeon cores in its work. */
 enum octeon_tag_type {
@@ -295,7 +296,7 @@ union octnet_cmd {
 
 #define   OCTNET_CMD_SIZE     (sizeof(union octnet_cmd))
 
-/* Instruction Header (DPI - CN23xx) - for OCTEON-III models */
+/* Instruction Header(DPI) - for OCTEON-III models */
 struct  octeon_instr_ih3 {
 #ifdef __BIG_ENDIAN_BITFIELD
 
@@ -345,7 +346,7 @@ struct  octeon_instr_ih3 {
 #endif
 };
 
-/* Optional PKI Instruction Header(PKI IH) - for OCTEON CN23XX models */
+/* Optional PKI Instruction Header(PKI IH) - for OCTEON-III models */
 /** BIG ENDIAN format.   */
 struct  octeon_instr_pki_ih3 {
 #ifdef __BIG_ENDIAN_BITFIELD
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 4b8c948..b3396e3 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -226,7 +226,7 @@ struct octeon_oq_config {
 	 */
 	u64 refill_threshold:16;
 
-	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	/** If set, the Output queue uses info-pointer mode. (Default: 1) */
 	u64 info_ptr:32;
 
 	/* Max number of OQs available */
@@ -236,7 +236,7 @@ struct octeon_oq_config {
 	/* Max number of OQs available */
 	u64 max_oqs:8;
 
-	/** If set, the Output queue uses info-pointer mode. (Default: 1 ) */
+	/** If set, the Output queue uses info-pointer mode. (Default: 1) */
 	u64 info_ptr:32;
 
 	/** The number of buffers that were consumed during packet processing by
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 70a8cd3..bbb50ea 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -223,7 +223,7 @@ static void CVMX_BOOTMEM_NAMED_GET_NAME(struct octeon_device *oct,
 					u32 len)
 {
 	addr += offsetof(struct cvmx_bootmem_named_block_desc, name);
-	octeon_pci_read_core_mem(oct, addr, str, len);
+	octeon_pci_read_core_mem(oct, addr, (u8 *)str, len);
 	str[len] = 0;
 }
 
@@ -375,7 +375,7 @@ static void octeon_remote_unlock(void)
 int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
 			    u32 wait_hundredths)
 {
-	u32 len = strlen(cmd_str);
+	u32 len = (u32)strlen(cmd_str);
 
 	dev_dbg(&oct->pci_dev->dev, "sending \"%s\" to bootloader\n", cmd_str);
 
@@ -483,7 +483,7 @@ static void check_console(struct work_struct *work)
 	struct octeon_console *console;
 	struct cavium_wk *wk = (struct cavium_wk *)work;
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
-	size_t console_num = wk->ctxul;
+	u32 console_num = (u32)wk->ctxul;
 	u32 delay;
 
 	console = &oct->console[console_num];
@@ -506,7 +506,7 @@ static void check_console(struct work_struct *work)
 						    console_buffer, bytes_read);
 			}
 		} else if (bytes_read < 0) {
-			dev_err(&oct->pci_dev->dev, "Error reading console %lu, ret=%d\n",
+			dev_err(&oct->pci_dev->dev, "Error reading console %u, ret=%d\n",
 				console_num, bytes_read);
 		}
 
@@ -518,7 +518,7 @@ static void check_console(struct work_struct *work)
 	 */
 	if (octeon_console_debug_enabled(console_num) &&
 	    (total_read == 0) && (console->leftover[0])) {
-		dev_info(&oct->pci_dev->dev, "%lu: %s\n",
+		dev_info(&oct->pci_dev->dev, "%u: %s\n",
 			 console_num, console->leftover);
 		console->leftover[0] = '\0';
 	}
@@ -700,7 +700,7 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 		bytes_to_read = console->buffer_size - rd_idx;
 
 	octeon_pci_read_core_mem(oct, console->output_base_addr + rd_idx,
-				 buffer, bytes_to_read);
+				 (u8 *)buffer, bytes_to_read);
 	octeon_write_device_mem32(oct, console->addr +
 				  offsetof(struct octeon_pci_console,
 					   output_read_index),
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index fda93be..0eb504a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -440,10 +440,10 @@ static struct octeon_config_ptr {
 };
 
 static char oct_dev_state_str[OCT_DEV_STATES + 1][32] = {
-	"BEGIN",	"PCI-MAP-DONE",	      "DISPATCH-INIT-DONE",
+	"BEGIN", "PCI-MAP-DONE", "DISPATCH-INIT-DONE",
 	"IQ-INIT-DONE", "SCBUFF-POOL-INIT-DONE", "RESPLIST-INIT-DONE",
 	"DROQ-INIT-DONE", "IO-QUEUES-INIT-DONE", "CONSOLE-INIT-DONE",
-	"HOST-READY",	"CORE-READY",	      "RUNNING",	   "IN-RESET",
+	"HOST-READY", "CORE-READY", "RUNNING", "IN-RESET",
 	"INVALID"
 };
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 579acd4..01edfb4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -221,7 +221,7 @@ struct octeon_fn_list {
 
 /* Structure for named memory blocks
  * Number of descriptors
- * available can be changed without affecting compatiblity,
+ * available can be changed without affecting compatibility,
  * but name length changes require a bump in the bootmem
  * descriptor version
  * Note: This structure must be naturally 64 bit aligned, as a single
@@ -254,7 +254,7 @@ struct oct_fw_info {
 struct cavium_wk {
 	struct delayed_work work;
 	void *ctxptr;
-	size_t ctxul;
+	u64 ctxul;
 };
 
 struct cavium_wq {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 93ab4ec..e0afe4c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -92,6 +92,11 @@ static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
 	return fn_arg;
 }
 
+/** Check for packets on Droq. This function should be called with
+ * lock held.
+ *  @param  droq - Droq on which count is checked.
+ *  @return Returns packet count.
+ */
 u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq)
 {
 	u32 pkt_count = 0;
@@ -183,7 +188,6 @@ octeon_droq_setup_ring_buffers(struct octeon_device *oct,
 
 		droq->recv_buf_list[i].buffer = buf;
 		droq->recv_buf_list[i].data = get_rbd(buf);
-
 		droq->info_list[i].length = 0;
 
 		/* map ring buffers into memory */
@@ -556,7 +560,9 @@ octeon_droq_dispatch_pkt(struct octeon_device *oct,
 			droq->stats.dropped_nomem++;
 		}
 	} else {
-		dev_err(&oct->pci_dev->dev, "DROQ: No dispatch function\n");
+		dev_err(&oct->pci_dev->dev, "DROQ: No dispatch function (opcode %u/%u)\n",
+			(unsigned int)rh->r.opcode,
+			(unsigned int)rh->r.subcode);
 		droq->stats.dropped_nodispatch++;
 	}                       /* else (dispatch_fn ... */
 
@@ -641,6 +647,7 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 					pg_info->page = NULL;
 				droq->recv_buf_list[droq->read_idx].buffer =
 					NULL;
+
 				INCR_INDEX_BY1(droq->read_idx, droq->max_count);
 				droq->refill_count++;
 			} else {
@@ -735,7 +742,7 @@ octeon_droq_process_packets(struct octeon_device *oct,
 	if (pkt_count > budget)
 		pkt_count = budget;
 
-	/* Grab the lock */
+	/* Grab the droq lock */
 	spin_lock(&droq->lock);
 
 	pkts_processed = octeon_droq_fast_process_packets(oct, droq, pkt_count);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 5ac7e66..ff4b1d6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -99,7 +99,7 @@ struct octeon_instr_queue {
 
 	u32 rsvd:17;
 
-	/* Controls the periodic flushing of iq */
+	/* Controls whether extra flushing of IQ is done on Tx */
 	u32 do_auto_flush:1;
 
 	u32 status:8;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index ab41866..fb820dc 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -124,7 +124,6 @@ struct lio {
 
 	/* work queue for  txq status */
 	struct cavium_wq	txq_status_wq;
-
 };
 
 #define LIO_SIZE         (sizeof(struct lio))
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 3f7044c..d32492f1 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -349,6 +349,7 @@ __add_to_request_list(struct octeon_instr_queue *iq,
 	iq->request_list[idx].reqtype = reqtype;
 }
 
+/* Can only run in process context */
 int
 lio_process_iq_request_list(struct octeon_device *oct,
 			    struct octeon_instr_queue *iq, u32 napi_budget)
@@ -405,6 +406,7 @@ lio_process_iq_request_list(struct octeon_device *oct,
 					 flags);
 			} else {
 				if (sc->callback) {
+					/* This callback must not sleep */
 					sc->callback(oct, OCTEON_REQUEST_DONE,
 						     sc->callback_arg);
 				}
@@ -521,7 +523,7 @@ static void check_db_timeout(struct work_struct *work)
 {
 	struct cavium_wk *wk = (struct cavium_wk *)work;
 	struct octeon_device *oct = (struct octeon_device *)wk->ctxptr;
-	unsigned long iq_no = wk->ctxul;
+	u64 iq_no = wk->ctxul;
 	struct cavium_wq *db_wq = &oct->check_db_wq[iq_no];
 	u32 delay = 10;
 
@@ -550,7 +552,7 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, bytes_sent, datasize);
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_posted, 1);
 
-		if (iq->fill_cnt >= iq->fill_threshold || force_db)
+		if (force_db)
 			ring_doorbell(oct, iq);
 	} else {
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_dropped, 1);
-- 
1.8.3.1
