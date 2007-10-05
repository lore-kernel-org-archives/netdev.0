From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] s2io: sparse warnings fix
Date: Fri, 5 Oct 2007 09:07:25 -0700
Message-ID: <20071005090725.09a80bc7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Raapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56616 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756654AbXJEQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 12:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix warnings from sparse checker about shadowed definition and improperly
formatted ethtool_strings.

I chose to change module parameter rather than uglify the code by changing
the variable name.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
  CHECK   drivers/net/s2io.c
drivers/net/s2io.c:2892:15: warning: symbol 'lro' shadows an earlier one
drivers/net/s2io.c:471:1: originally declared here
drivers/net/s2io.c:7021:13: warning: symbol 'lro' shadows an earlier one
drivers/net/s2io.c:471:1: originally declared here
drivers/net/s2io.c:279:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:280:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:281:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:282:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:283:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:284:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:285:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:286:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:287:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:288:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:289:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:290:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:291:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:292:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:293:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:294:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:295:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:296:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:297:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:298:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:299:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:300:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:301:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:302:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:303:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:304:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:305:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:306:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:307:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:308:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:309:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:310:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:311:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:312:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:313:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:314:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:315:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:316:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:317:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:318:3: warning: array initialized from parenthesized string constant
drivers/net/s2io.c:1762:6: warning: symbol 'en_dis_err_alarms' was not declared. Should it be static?
include/linux/mm.h:587:9: warning: potentially expensive pointer subtraction
drivers/net/s2io.c:4231:5: warning: symbol 'do_s2io_chk_alarm_bit' was not declared. Should it be static?
drivers/net/s2io.c:7801:12: warning: symbol 's2io_starter' was not declared. Should it be static?


--- a/drivers/net/s2io.c	2007-10-05 08:09:07.000000000 -0700
+++ b/drivers/net/s2io.c	2007-10-05 09:06:40.000000000 -0700
@@ -38,7 +38,7 @@
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
  *     2(MSI_X). Default value is '2(MSI_X)'
- * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
+ * lro_enable: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
  *     aggregated as a single large packet
@@ -276,46 +276,46 @@ static char ethtool_driver_stats_keys[][
 	{"ring_5_full_cnt"},
 	{"ring_6_full_cnt"},
 	{"ring_7_full_cnt"},
-	("alarm_transceiver_temp_high"),
-	("alarm_transceiver_temp_low"),
-	("alarm_laser_bias_current_high"),
-	("alarm_laser_bias_current_low"),
-	("alarm_laser_output_power_high"),
-	("alarm_laser_output_power_low"),
-	("warn_transceiver_temp_high"),
-	("warn_transceiver_temp_low"),
-	("warn_laser_bias_current_high"),
-	("warn_laser_bias_current_low"),
-	("warn_laser_output_power_high"),
-	("warn_laser_output_power_low"),
-	("lro_aggregated_pkts"),
-	("lro_flush_both_count"),
-	("lro_out_of_sequence_pkts"),
-	("lro_flush_due_to_max_pkts"),
-	("lro_avg_aggr_pkts"),
-	("mem_alloc_fail_cnt"),
-	("pci_map_fail_cnt"),
-	("watchdog_timer_cnt"),
-	("mem_allocated"),
-	("mem_freed"),
-	("link_up_cnt"),
-	("link_down_cnt"),
-	("link_up_time"),
-	("link_down_time"),
-	("tx_tcode_buf_abort_cnt"),
-	("tx_tcode_desc_abort_cnt"),
-	("tx_tcode_parity_err_cnt"),
-	("tx_tcode_link_loss_cnt"),
-	("tx_tcode_list_proc_err_cnt"),
-	("rx_tcode_parity_err_cnt"),
-	("rx_tcode_abort_cnt"),
-	("rx_tcode_parity_abort_cnt"),
-	("rx_tcode_rda_fail_cnt"),
-	("rx_tcode_unkn_prot_cnt"),
-	("rx_tcode_fcs_err_cnt"),
-	("rx_tcode_buf_size_err_cnt"),
-	("rx_tcode_rxd_corrupt_cnt"),
-	("rx_tcode_unkn_err_cnt"),
+	{"alarm_transceiver_temp_high"},
+	{"alarm_transceiver_temp_low"},
+	{"alarm_laser_bias_current_high"},
+	{"alarm_laser_bias_current_low"},
+	{"alarm_laser_output_power_high"},
+	{"alarm_laser_output_power_low"},
+	{"warn_transceiver_temp_high"},
+	{"warn_transceiver_temp_low"},
+	{"warn_laser_bias_current_high"},
+	{"warn_laser_bias_current_low"},
+	{"warn_laser_output_power_high"},
+	{"warn_laser_output_power_low"},
+	{"lro_aggregated_pkts"},
+	{"lro_flush_both_count"},
+	{"lro_out_of_sequence_pkts"},
+	{"lro_flush_due_to_max_pkts"},
+	{"lro_avg_aggr_pkts"},
+	{"mem_alloc_fail_cnt"},
+	{"pci_map_fail_cnt"},
+	{"watchdog_timer_cnt"},
+	{"mem_allocated"},
+	{"mem_freed"},
+	{"link_up_cnt"},
+	{"link_down_cnt"},
+	{"link_up_time"},
+	{"link_down_time"},
+	{"tx_tcode_buf_abort_cnt"},
+	{"tx_tcode_desc_abort_cnt"},
+	{"tx_tcode_parity_err_cnt"},
+	{"tx_tcode_link_loss_cnt"},
+	{"tx_tcode_list_proc_err_cnt"},
+	{"rx_tcode_parity_err_cnt"},
+	{"rx_tcode_abort_cnt"},
+	{"rx_tcode_parity_abort_cnt"},
+	{"rx_tcode_rda_fail_cnt"},
+	{"rx_tcode_unkn_prot_cnt"},
+	{"rx_tcode_fcs_err_cnt"},
+	{"rx_tcode_buf_size_err_cnt"},
+	{"rx_tcode_rxd_corrupt_cnt"},
+	{"rx_tcode_unkn_err_cnt"},
 	{"tda_err_cnt"},
 	{"pfc_err_cnt"},
 	{"pcc_err_cnt"},
@@ -468,7 +468,7 @@ S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 2);
 /* Large receive offload feature */
-S2IO_PARM_INT(lro, 0);
+S2IO_PARM_INT(lro_enable, 0);
 /* Max pkts to be aggregated by LRO at one time. If not specified,
  * aggregation happens until we hit max IP pkt size(64K)
  */
@@ -1759,7 +1759,7 @@ static void do_s2io_write_bits(u64 value
 	writeq(temp64, addr);
 }
 
-void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
+static void en_dis_err_alarms(struct s2io_nic *nic, u16 mask, int flag)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 gen_int_mask = 0;
@@ -4228,7 +4228,7 @@ static void s2io_txpic_intr_handle(struc
  *  1 - if alarm bit set
  *  0 - if alarm bit is not set
  */
-int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
+static int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
 			  unsigned long long *cnt)
 {
 	u64 val64;
@@ -7135,7 +7135,8 @@ static int rx_osm_handler(struct ring_in
 				int ret = 0;
 
 				ret = s2io_club_tcp_session(skb->data, &tcp,
-						&tcp_len, &lro, rxdp, sp);
+							    &tcp_len, &lro,
+							    rxdp, sp);
 				switch (ret) {
 					case 3: /* Begin anew */
 						lro->parent = skb;
@@ -7451,7 +7452,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	else
 		sp->device_type = XFRAME_I_DEVICE;
 
-	sp->lro = lro;
+	sp->lro = lro_enable;
 
 	/* Initialize some PCI/PCI-X fields of the NIC. */
 	s2io_init_pci(sp);
@@ -7798,7 +7799,7 @@ static void __devexit s2io_rem_nic(struc
  * the module loadable parameters and initializes PCI configuration space.
  */
 
-int __init s2io_starter(void)
+static int __init s2io_starter(void)
 {
 	return pci_register_driver(&s2io_driver);
 }
