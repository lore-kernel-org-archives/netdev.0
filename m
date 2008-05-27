From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 5/12]bnx2x: New statistics code
Date: Tue, 27 May 2008 10:17:29 -0400
Message-ID: <1211897849.6967.78.camel@ubuntu804desktop.localdomain>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eliezer Tamir" <eliezert@broadcom.com>,
	"Yitchak Gertner" <gertner@broadcom.com>
To: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3390 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673AbYE0ORw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:17:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x: New statistics code
=EF=BB=BF
=EF=BB=BF=EF=BB=BFSigned-off-by: Yitchak Gertner <gertner@broadcom.com>
=EF=BB=BF=EF=BB=BFSigned-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |  441 ++++++---------
 drivers/net/bnx2x_hsi.h  |  374 +++++++++++++-
 drivers/net/bnx2x_main.c | 1340 +++++++++++++++++++++++++++++---------=
--------
 3 files changed, 1389 insertions(+), 766 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8d7b2f4..56331be 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -125,243 +125,6 @@
 #define is_multi(bp)		(bp->num_queues > 1)
=20
=20
-struct regp {
-	u32 lo;
-	u32 hi;
-};
-
-struct bmac_stats {
-	struct regp tx_gtpkt;
-	struct regp tx_gtxpf;
-	struct regp tx_gtfcs;
-	struct regp tx_gtmca;
-	struct regp tx_gtgca;
-	struct regp tx_gtfrg;
-	struct regp tx_gtovr;
-	struct regp tx_gt64;
-	struct regp tx_gt127;
-	struct regp tx_gt255;   /* 10 */
-	struct regp tx_gt511;
-	struct regp tx_gt1023;
-	struct regp tx_gt1518;
-	struct regp tx_gt2047;
-	struct regp tx_gt4095;
-	struct regp tx_gt9216;
-	struct regp tx_gt16383;
-	struct regp tx_gtmax;
-	struct regp tx_gtufl;
-	struct regp tx_gterr;   /* 20 */
-	struct regp tx_gtbyt;
-
-	struct regp rx_gr64;
-	struct regp rx_gr127;
-	struct regp rx_gr255;
-	struct regp rx_gr511;
-	struct regp rx_gr1023;
-	struct regp rx_gr1518;
-	struct regp rx_gr2047;
-	struct regp rx_gr4095;
-	struct regp rx_gr9216;  /* 30 */
-	struct regp rx_gr16383;
-	struct regp rx_grmax;
-	struct regp rx_grpkt;
-	struct regp rx_grfcs;
-	struct regp rx_grmca;
-	struct regp rx_grbca;
-	struct regp rx_grxcf;
-	struct regp rx_grxpf;
-	struct regp rx_grxuo;
-	struct regp rx_grjbr;   /* 40 */
-	struct regp rx_grovr;
-	struct regp rx_grflr;
-	struct regp rx_grmeg;
-	struct regp rx_grmeb;
-	struct regp rx_grbyt;
-	struct regp rx_grund;
-	struct regp rx_grfrg;
-	struct regp rx_grerb;
-	struct regp rx_grfre;
-	struct regp rx_gripj;   /* 50 */
-};
-
-struct emac_stats {
-	u32 rx_ifhcinoctets     		   ;
-	u32 rx_ifhcinbadoctets  		   ;
-	u32 rx_etherstatsfragments      	   ;
-	u32 rx_ifhcinucastpkts  		   ;
-	u32 rx_ifhcinmulticastpkts      	   ;
-	u32 rx_ifhcinbroadcastpkts      	   ;
-	u32 rx_dot3statsfcserrors       	   ;
-	u32 rx_dot3statsalignmenterrors 	   ;
-	u32 rx_dot3statscarriersenseerrors         ;
-	u32 rx_xonpauseframesreceived   	   ;    /* 10 */
-	u32 rx_xoffpauseframesreceived  	   ;
-	u32 rx_maccontrolframesreceived 	   ;
-	u32 rx_xoffstateentered 		   ;
-	u32 rx_dot3statsframestoolong   	   ;
-	u32 rx_etherstatsjabbers		   ;
-	u32 rx_etherstatsundersizepkts  	   ;
-	u32 rx_etherstatspkts64octets   	   ;
-	u32 rx_etherstatspkts65octetsto127octets   ;
-	u32 rx_etherstatspkts128octetsto255octets  ;
-	u32 rx_etherstatspkts256octetsto511octets  ;    /* 20 */
-	u32 rx_etherstatspkts512octetsto1023octets ;
-	u32 rx_etherstatspkts1024octetsto1522octets;
-	u32 rx_etherstatspktsover1522octets        ;
-
-	u32 rx_falsecarriererrors       	   ;
-
-	u32 tx_ifhcoutoctets    		   ;
-	u32 tx_ifhcoutbadoctets 		   ;
-	u32 tx_etherstatscollisions     	   ;
-	u32 tx_outxonsent       		   ;
-	u32 tx_outxoffsent      		   ;
-	u32 tx_flowcontroldone  		   ;    /* 30 */
-	u32 tx_dot3statssinglecollisionframes      ;
-	u32 tx_dot3statsmultiplecollisionframes    ;
-	u32 tx_dot3statsdeferredtransmissions      ;
-	u32 tx_dot3statsexcessivecollisions        ;
-	u32 tx_dot3statslatecollisions  	   ;
-	u32 tx_ifhcoutucastpkts 		   ;
-	u32 tx_ifhcoutmulticastpkts     	   ;
-	u32 tx_ifhcoutbroadcastpkts     	   ;
-	u32 tx_etherstatspkts64octets   	   ;
-	u32 tx_etherstatspkts65octetsto127octets   ;    /* 40 */
-	u32 tx_etherstatspkts128octetsto255octets  ;
-	u32 tx_etherstatspkts256octetsto511octets  ;
-	u32 tx_etherstatspkts512octetsto1023octets ;
-	u32 tx_etherstatspkts1024octetsto1522octet ;
-	u32 tx_etherstatspktsover1522octets        ;
-	u32 tx_dot3statsinternalmactransmiterrors  ;    /* 46 */
-};
-
-union mac_stats {
-	struct emac_stats emac;
-	struct bmac_stats bmac;
-};
-
-struct nig_stats {
-	u32 brb_discard;
-	u32 brb_packet;
-	u32 brb_truncate;
-	u32 flow_ctrl_discard;
-	u32 flow_ctrl_octets;
-	u32 flow_ctrl_packet;
-	u32 mng_discard;
-	u32 mng_octet_inp;
-	u32 mng_octet_out;
-	u32 mng_packet_inp;
-	u32 mng_packet_out;
-	u32 pbf_octets;
-	u32 pbf_packet;
-	u32 safc_inp;
-	u32 done;
-	u32 pad;
-};
-
-struct bnx2x_eth_stats {
-	u32 pad;	/* to make long counters u64 aligned */
-	u32 mac_stx_start;
-	u32 total_bytes_received_hi;
-	u32 total_bytes_received_lo;
-	u32 total_bytes_transmitted_hi;
-	u32 total_bytes_transmitted_lo;
-	u32 total_unicast_packets_received_hi;
-	u32 total_unicast_packets_received_lo;
-	u32 total_multicast_packets_received_hi;
-	u32 total_multicast_packets_received_lo;
-	u32 total_broadcast_packets_received_hi;
-	u32 total_broadcast_packets_received_lo;
-	u32 total_unicast_packets_transmitted_hi;
-	u32 total_unicast_packets_transmitted_lo;
-	u32 total_multicast_packets_transmitted_hi;
-	u32 total_multicast_packets_transmitted_lo;
-	u32 total_broadcast_packets_transmitted_hi;
-	u32 total_broadcast_packets_transmitted_lo;
-	u32 crc_receive_errors;
-	u32 alignment_errors;
-	u32 false_carrier_detections;
-	u32 runt_packets_received;
-	u32 jabber_packets_received;
-	u32 pause_xon_frames_received;
-	u32 pause_xoff_frames_received;
-	u32 pause_xon_frames_transmitted;
-	u32 pause_xoff_frames_transmitted;
-	u32 single_collision_transmit_frames;
-	u32 multiple_collision_transmit_frames;
-	u32 late_collision_frames;
-	u32 excessive_collision_frames;
-	u32 control_frames_received;
-	u32 frames_received_64_bytes;
-	u32 frames_received_65_127_bytes;
-	u32 frames_received_128_255_bytes;
-	u32 frames_received_256_511_bytes;
-	u32 frames_received_512_1023_bytes;
-	u32 frames_received_1024_1522_bytes;
-	u32 frames_received_1523_9022_bytes;
-	u32 frames_transmitted_64_bytes;
-	u32 frames_transmitted_65_127_bytes;
-	u32 frames_transmitted_128_255_bytes;
-	u32 frames_transmitted_256_511_bytes;
-	u32 frames_transmitted_512_1023_bytes;
-	u32 frames_transmitted_1024_1522_bytes;
-	u32 frames_transmitted_1523_9022_bytes;
-	u32 valid_bytes_received_hi;
-	u32 valid_bytes_received_lo;
-	u32 error_runt_packets_received;
-	u32 error_jabber_packets_received;
-	u32 mac_stx_end;
-
-	u32 pad2;
-	u32 stat_IfHCInBadOctets_hi;
-	u32 stat_IfHCInBadOctets_lo;
-	u32 stat_IfHCOutBadOctets_hi;
-	u32 stat_IfHCOutBadOctets_lo;
-	u32 stat_Dot3statsFramesTooLong;
-	u32 stat_Dot3statsInternalMacTransmitErrors;
-	u32 stat_Dot3StatsCarrierSenseErrors;
-	u32 stat_Dot3StatsDeferredTransmissions;
-	u32 stat_FlowControlDone;
-	u32 stat_XoffStateEntered;
-
-	u32 x_total_sent_bytes_hi;
-	u32 x_total_sent_bytes_lo;
-	u32 x_total_sent_pkts;
-
-	u32 t_rcv_unicast_bytes_hi;
-	u32 t_rcv_unicast_bytes_lo;
-	u32 t_rcv_broadcast_bytes_hi;
-	u32 t_rcv_broadcast_bytes_lo;
-	u32 t_rcv_multicast_bytes_hi;
-	u32 t_rcv_multicast_bytes_lo;
-	u32 t_total_rcv_pkt;
-
-	u32 checksum_discard;
-	u32 packets_too_big_discard;
-	u32 no_buff_discard;
-	u32 ttl0_discard;
-	u32 mac_discard;
-	u32 mac_filter_discard;
-	u32 xxoverflow_discard;
-	u32 brb_truncate_discard;
-
-	u32 brb_discard;
-	u32 brb_packet;
-	u32 brb_truncate;
-	u32 flow_ctrl_discard;
-	u32 flow_ctrl_octets;
-	u32 flow_ctrl_packet;
-	u32 mng_discard;
-	u32 mng_octet_inp;
-	u32 mng_octet_out;
-	u32 mng_packet_inp;
-	u32 mng_packet_out;
-	u32 pbf_octets;
-	u32 pbf_packet;
-	u32 safc_inp;
-	u32 driver_xoff;
-	u32 number_of_bugs_found_in_stats_spec; /* just kidding */
-};
=20
 #define bnx2x_sp_check(bp, var) ((bp->slowpath) ? (&bp->slowpath->var)=
 : NULL)
 struct sw_rx_bd {
@@ -440,6 +203,10 @@ struct bnx2x_fastpath {
 /* This is needed for determening of last_max */
 #define SUB_S16(a, b)			(s16)((s16)(a) - (s16)(b))
=20
+#define BD_UNMAP_ADDR(bd)		HILO_U64(le32_to_cpu((bd)->addr_hi), \
+						 le32_to_cpu((bd)->addr_lo))
+#define BD_UNMAP_LEN(bd)		(le16_to_cpu((bd)->nbytes))
+
 /* stuff added to make the code fit 80Col */
=20
 #define CQE_TYPE(cqe_fp_flags)	((cqe_fp_flags) & ETH_FAST_PATH_RX_CQE_=
TYPE)
@@ -449,6 +216,9 @@ struct bnx2x_fastpath {
 				 ETH_FAST_PATH_RX_CQE_L4_BAD_XSUM_FLG)
=20
=20
+#define FP_USB_FUNC_OFF			(2 + 2*HC_USTORM_SB_NUM_INDICES)
+#define FP_CSB_FUNC_OFF			(2 + 2*HC_CSTORM_SB_NUM_INDICES)
+
 #define U_SB_ETH_RX_CQ_INDEX		HC_INDEX_U_ETH_RX_CQ_CONS
 #define U_SB_ETH_RX_BD_INDEX		HC_INDEX_U_ETH_RX_BD_CONS
 #define C_SB_ETH_TX_CQ_INDEX		HC_INDEX_C_ETH_TX_CQ_CONS
@@ -526,6 +296,23 @@ struct bnx2x_common {
=20
 /* port */
=20
+struct nig_stats {
+	u32 brb_discard;
+	u32 brb_packet;
+	u32 brb_truncate;
+	u32 flow_ctrl_discard;
+	u32 flow_ctrl_octets;
+	u32 flow_ctrl_packet;
+	u32 mng_discard;
+	u32 mng_octet_inp;
+	u32 mng_octet_out;
+	u32 mng_packet_inp;
+	u32 mng_packet_out;
+	u32 pbf_octets;
+	u32 pbf_packet;
+	u32 safc_inp;
+};
+
 struct bnx2x_port {
 	u32			pmf;
=20
@@ -551,7 +338,136 @@ struct bnx2x_port {
=20
 /* end of port */
=20
-#define MAC_STX_NA      		0xffffffff
+
+enum bnx2x_stats_event {
+	STATS_EVENT_PMF =3D 0,
+	STATS_EVENT_LINK_UP,
+	STATS_EVENT_UPDATE,
+	STATS_EVENT_STOP,
+	STATS_EVENT_MAX
+};
+
+enum bnx2x_stats_state {
+	STATS_STATE_DISABLED =3D 0,
+	STATS_STATE_ENABLED,
+	STATS_STATE_MAX
+};
+
+struct bnx2x_eth_stats {
+	u32 total_bytes_received_hi;
+	u32 total_bytes_received_lo;
+	u32 total_bytes_transmitted_hi;
+	u32 total_bytes_transmitted_lo;
+	u32 total_unicast_packets_received_hi;
+	u32 total_unicast_packets_received_lo;
+	u32 total_multicast_packets_received_hi;
+	u32 total_multicast_packets_received_lo;
+	u32 total_broadcast_packets_received_hi;
+	u32 total_broadcast_packets_received_lo;
+	u32 total_unicast_packets_transmitted_hi;
+	u32 total_unicast_packets_transmitted_lo;
+	u32 total_multicast_packets_transmitted_hi;
+	u32 total_multicast_packets_transmitted_lo;
+	u32 total_broadcast_packets_transmitted_hi;
+	u32 total_broadcast_packets_transmitted_lo;
+	u32 valid_bytes_received_hi;
+	u32 valid_bytes_received_lo;
+
+	u32 rx_stat_ifhcinbadoctets_hi;
+	u32 rx_stat_ifhcinbadoctets_lo;
+	u32 tx_stat_ifhcoutbadoctets_hi;
+	u32 tx_stat_ifhcoutbadoctets_lo;
+	u32 rx_stat_dot3statsfcserrors_hi;
+	u32 rx_stat_dot3statsfcserrors_lo;
+	u32 rx_stat_dot3statsalignmenterrors_hi;
+	u32 rx_stat_dot3statsalignmenterrors_lo;
+	u32 rx_stat_dot3statscarriersenseerrors_hi;
+	u32 rx_stat_dot3statscarriersenseerrors_lo;
+	u32 rx_stat_falsecarriererrors_hi;
+	u32 rx_stat_falsecarriererrors_lo;
+	u32 rx_stat_etherstatsundersizepkts_hi;
+	u32 rx_stat_etherstatsundersizepkts_lo;
+	u32 rx_stat_dot3statsframestoolong_hi;
+	u32 rx_stat_dot3statsframestoolong_lo;
+	u32 rx_stat_etherstatsfragments_hi;
+	u32 rx_stat_etherstatsfragments_lo;
+	u32 rx_stat_etherstatsjabbers_hi;
+	u32 rx_stat_etherstatsjabbers_lo;
+	u32 rx_stat_maccontrolframesreceived_hi;
+	u32 rx_stat_maccontrolframesreceived_lo;
+	u32 rx_stat_bmac_xpf_hi;
+	u32 rx_stat_bmac_xpf_lo;
+	u32 rx_stat_bmac_xcf_hi;
+	u32 rx_stat_bmac_xcf_lo;
+	u32 rx_stat_xoffstateentered_hi;
+	u32 rx_stat_xoffstateentered_lo;
+	u32 rx_stat_xonpauseframesreceived_hi;
+	u32 rx_stat_xonpauseframesreceived_lo;
+	u32 rx_stat_xoffpauseframesreceived_hi;
+	u32 rx_stat_xoffpauseframesreceived_lo;
+	u32 tx_stat_outxonsent_hi;
+	u32 tx_stat_outxonsent_lo;
+	u32 tx_stat_outxoffsent_hi;
+	u32 tx_stat_outxoffsent_lo;
+	u32 tx_stat_flowcontroldone_hi;
+	u32 tx_stat_flowcontroldone_lo;
+	u32 tx_stat_etherstatscollisions_hi;
+	u32 tx_stat_etherstatscollisions_lo;
+	u32 tx_stat_dot3statssinglecollisionframes_hi;
+	u32 tx_stat_dot3statssinglecollisionframes_lo;
+	u32 tx_stat_dot3statsmultiplecollisionframes_hi;
+	u32 tx_stat_dot3statsmultiplecollisionframes_lo;
+	u32 tx_stat_dot3statsdeferredtransmissions_hi;
+	u32 tx_stat_dot3statsdeferredtransmissions_lo;
+	u32 tx_stat_dot3statsexcessivecollisions_hi;
+	u32 tx_stat_dot3statsexcessivecollisions_lo;
+	u32 tx_stat_dot3statslatecollisions_hi;
+	u32 tx_stat_dot3statslatecollisions_lo;
+	u32 tx_stat_etherstatspkts64octets_hi;
+	u32 tx_stat_etherstatspkts64octets_lo;
+	u32 tx_stat_etherstatspkts65octetsto127octets_hi;
+	u32 tx_stat_etherstatspkts65octetsto127octets_lo;
+	u32 tx_stat_etherstatspkts128octetsto255octets_hi;
+	u32 tx_stat_etherstatspkts128octetsto255octets_lo;
+	u32 tx_stat_etherstatspkts256octetsto511octets_hi;
+	u32 tx_stat_etherstatspkts256octetsto511octets_lo;
+	u32 tx_stat_etherstatspkts512octetsto1023octets_hi;
+	u32 tx_stat_etherstatspkts512octetsto1023octets_lo;
+	u32 tx_stat_etherstatspkts1024octetsto1522octets_hi;
+	u32 tx_stat_etherstatspkts1024octetsto1522octets_lo;
+	u32 tx_stat_etherstatspktsover1522octets_hi;
+	u32 tx_stat_etherstatspktsover1522octets_lo;
+	u32 tx_stat_bmac_2047_hi;
+	u32 tx_stat_bmac_2047_lo;
+	u32 tx_stat_bmac_4095_hi;
+	u32 tx_stat_bmac_4095_lo;
+	u32 tx_stat_bmac_9216_hi;
+	u32 tx_stat_bmac_9216_lo;
+	u32 tx_stat_bmac_16383_hi;
+	u32 tx_stat_bmac_16383_lo;
+	u32 tx_stat_dot3statsinternalmactransmiterrors_hi;
+	u32 tx_stat_dot3statsinternalmactransmiterrors_lo;
+	u32 tx_stat_bmac_ufl_hi;
+	u32 tx_stat_bmac_ufl_lo;
+
+	u32 brb_drop_hi;
+	u32 brb_drop_lo;
+
+	u32 jabber_packets_received;
+
+	u32 etherstatspktsover1522octets_hi;
+	u32 etherstatspktsover1522octets_lo;
+
+	u32 no_buff_discard;
+
+	u32 mac_filter_discard;
+	u32 xxoverflow_discard;
+	u32 brb_truncate_discard;
+	u32 mac_discard;
+
+	u32 driver_xoff;
+};
+
=20
 #ifdef BNX2X_MULTI
 #define MAX_CONTEXT			16
@@ -576,12 +492,13 @@ struct bnx2x_slowpath {
 	/* used by dmae command executer */
 	struct dmae_command		dmae[MAX_DMAE_C];
=20
-	union mac_stats 		mac_stats;
-	struct nig_stats		nig;
-	struct bnx2x_eth_stats  	eth_stats;
+	u32				stats_comp;
+	union mac_stats			mac_stats;
+	struct nig_stats		nig_stats;
+	struct host_port_stats		port_stats;
+	struct host_func_stats		func_stats;
=20
 	u32				wb_comp;
-#define BNX2X_WB_COMP_VAL       	0xe0d0d0ae
 	u32				wb_data[4];
 };
=20
@@ -650,10 +567,10 @@ struct bnx2x {
 	/* used to synchronize spq accesses */
 	spinlock_t		spq_lock;
=20
-	/* Flag for marking that there is either
-	 * STAT_QUERY or CFC DELETE ramrod pending
-	 */
-	u8      		stat_pending;
+	/* Flags for marking that there is a STAT_QUERY or
+	   SET_MAC ramrod pending */
+	u8			stats_pending;
+	u8			set_mac_pending;
=20
 	/* End of fileds used in the performance code paths */
=20
@@ -766,17 +683,14 @@ struct bnx2x {
=20
 	/* used to synchronize stats collecting */
 	int			stats_state;
-#define STATS_STATE_DISABLE     	0
-#define STATS_STATE_ENABLE      	1
-#define STATS_STATE_STOP		2 /* stop stats on next iteration */
-
 	/* used by dmae command loader */
-	struct dmae_command     dmae;
+	struct dmae_command	stats_dmae;
 	int			executer_idx;
=20
-	u32     		old_brb_discard;
-	struct bmac_stats       old_bmac;
+	u16			stats_counter;
 	struct tstorm_per_client_stats old_tclient;
+	struct xstorm_per_client_stats old_xclient;
+	struct bnx2x_eth_stats	eth_stats;
=20
 	struct z_stream_s	*strm;
 	void			*gunzip_buf;
@@ -838,11 +752,6 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num,=
 u32 mode);
 #define CQE_CMD(x)      		(le32_to_cpu(x) >> \
 					COMMON_RAMROD_ETH_RX_CQE_CMD_ID_SHIFT)
=20
-#define BD_UNMAP_ADDR(bd)       	HILO_U64(le32_to_cpu((bd)->addr_hi), =
\
-						 le32_to_cpu((bd)->addr_lo))
-#define BD_UNMAP_LEN(bd)		(le16_to_cpu((bd)->nbytes))
-
-
 #define STROM_ASSERT_ARRAY_SIZE 	50
=20
=20
@@ -858,10 +767,6 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num,=
 u32 mode);
 #define MAX_SPQ_PENDING 		8
=20
=20
-#define BNX2X_NUM_STATS			34
-#define BNX2X_NUM_TESTS			1
-
-
 #define DPM_TRIGER_TYPE 		0x40
 #define DOORBELL(bp, cid, val) \
 	do { \
@@ -894,6 +799,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 re=
g, u32 expected, int ms,
 #define UNLOAD_NORMAL			0
 #define UNLOAD_CLOSE			1
=20
+
 /* DMAE command defines */
 #define DMAE_CMD_SRC_PCI		0
 #define DMAE_CMD_SRC_GRC		DMAE_COMMAND_SRC
@@ -936,7 +842,16 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 r=
eg, u32 expected, int ms,
 #define PCICFG_LINK_SPEED		0xf0000
 #define PCICFG_LINK_SPEED_SHIFT		16
=20
-#define BMAC_CONTROL_RX_ENABLE		2
+
+#define BNX2X_NUM_STATS			41
+#define BNX2X_NUM_TESTS			8
+
+#define BNX2X_MAC_LOOPBACK		0
+#define BNX2X_PHY_LOOPBACK		1
+#define BNX2X_MAC_LOOPBACK_FAILED	1
+#define BNX2X_PHY_LOOPBACK_FAILED	2
+#define BNX2X_LOOPBACK_FAILED		(BNX2X_MAC_LOOPBACK_FAILED | \
+					 BNX2X_PHY_LOOPBACK_FAILED)
=20
 #define pbd_tcp_flags(skb)  	(ntohl(tcp_flag_word(tcp_hdr(skb)))>>16 &=
 0xff)
=20
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index b5f486c..9f195e0 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -880,6 +880,337 @@ struct shmem_region {			       /*   SharedMem Off=
set (size) */
 };						       /* 0x6dc */
=20
=20
+struct emac_stats {
+    u32     rx_stat_ifhcinoctets;
+    u32     rx_stat_ifhcinbadoctets;
+    u32     rx_stat_etherstatsfragments;
+    u32     rx_stat_ifhcinucastpkts;
+    u32     rx_stat_ifhcinmulticastpkts;
+    u32     rx_stat_ifhcinbroadcastpkts;
+    u32     rx_stat_dot3statsfcserrors;
+    u32     rx_stat_dot3statsalignmenterrors;
+    u32     rx_stat_dot3statscarriersenseerrors;
+    u32     rx_stat_xonpauseframesreceived;
+    u32     rx_stat_xoffpauseframesreceived;
+    u32     rx_stat_maccontrolframesreceived;
+    u32     rx_stat_xoffstateentered;
+    u32     rx_stat_dot3statsframestoolong;
+    u32     rx_stat_etherstatsjabbers;
+    u32     rx_stat_etherstatsundersizepkts;
+    u32     rx_stat_etherstatspkts64octets;
+    u32     rx_stat_etherstatspkts65octetsto127octets;
+    u32     rx_stat_etherstatspkts128octetsto255octets;
+    u32     rx_stat_etherstatspkts256octetsto511octets;
+    u32     rx_stat_etherstatspkts512octetsto1023octets;
+    u32     rx_stat_etherstatspkts1024octetsto1522octets;
+    u32     rx_stat_etherstatspktsover1522octets;
+
+    u32     rx_stat_falsecarriererrors;
+
+    u32     tx_stat_ifhcoutoctets;
+    u32     tx_stat_ifhcoutbadoctets;
+    u32     tx_stat_etherstatscollisions;
+    u32     tx_stat_outxonsent;
+    u32     tx_stat_outxoffsent;
+    u32     tx_stat_flowcontroldone;
+    u32     tx_stat_dot3statssinglecollisionframes;
+    u32     tx_stat_dot3statsmultiplecollisionframes;
+    u32     tx_stat_dot3statsdeferredtransmissions;
+    u32     tx_stat_dot3statsexcessivecollisions;
+    u32     tx_stat_dot3statslatecollisions;
+    u32     tx_stat_ifhcoutucastpkts;
+    u32     tx_stat_ifhcoutmulticastpkts;
+    u32     tx_stat_ifhcoutbroadcastpkts;
+    u32     tx_stat_etherstatspkts64octets;
+    u32     tx_stat_etherstatspkts65octetsto127octets;
+    u32     tx_stat_etherstatspkts128octetsto255octets;
+    u32     tx_stat_etherstatspkts256octetsto511octets;
+    u32     tx_stat_etherstatspkts512octetsto1023octets;
+    u32     tx_stat_etherstatspkts1024octetsto1522octets;
+    u32     tx_stat_etherstatspktsover1522octets;
+    u32     tx_stat_dot3statsinternalmactransmiterrors;
+};
+
+
+struct bmac_stats {
+    u32     tx_stat_gtpkt_lo;
+    u32     tx_stat_gtpkt_hi;
+    u32     tx_stat_gtxpf_lo;
+    u32     tx_stat_gtxpf_hi;
+    u32     tx_stat_gtfcs_lo;
+    u32     tx_stat_gtfcs_hi;
+    u32     tx_stat_gtmca_lo;
+    u32     tx_stat_gtmca_hi;
+    u32     tx_stat_gtbca_lo;
+    u32     tx_stat_gtbca_hi;
+    u32     tx_stat_gtfrg_lo;
+    u32     tx_stat_gtfrg_hi;
+    u32     tx_stat_gtovr_lo;
+    u32     tx_stat_gtovr_hi;
+    u32     tx_stat_gt64_lo;
+    u32     tx_stat_gt64_hi;
+    u32     tx_stat_gt127_lo;
+    u32     tx_stat_gt127_hi;
+    u32     tx_stat_gt255_lo;
+    u32     tx_stat_gt255_hi;
+    u32     tx_stat_gt511_lo;
+    u32     tx_stat_gt511_hi;
+    u32     tx_stat_gt1023_lo;
+    u32     tx_stat_gt1023_hi;
+    u32     tx_stat_gt1518_lo;
+    u32     tx_stat_gt1518_hi;
+    u32     tx_stat_gt2047_lo;
+    u32     tx_stat_gt2047_hi;
+    u32     tx_stat_gt4095_lo;
+    u32     tx_stat_gt4095_hi;
+    u32     tx_stat_gt9216_lo;
+    u32     tx_stat_gt9216_hi;
+    u32     tx_stat_gt16383_lo;
+    u32     tx_stat_gt16383_hi;
+    u32     tx_stat_gtmax_lo;
+    u32     tx_stat_gtmax_hi;
+    u32     tx_stat_gtufl_lo;
+    u32     tx_stat_gtufl_hi;
+    u32     tx_stat_gterr_lo;
+    u32     tx_stat_gterr_hi;
+    u32     tx_stat_gtbyt_lo;
+    u32     tx_stat_gtbyt_hi;
+
+    u32     rx_stat_gr64_lo;
+    u32     rx_stat_gr64_hi;
+    u32     rx_stat_gr127_lo;
+    u32     rx_stat_gr127_hi;
+    u32     rx_stat_gr255_lo;
+    u32     rx_stat_gr255_hi;
+    u32     rx_stat_gr511_lo;
+    u32     rx_stat_gr511_hi;
+    u32     rx_stat_gr1023_lo;
+    u32     rx_stat_gr1023_hi;
+    u32     rx_stat_gr1518_lo;
+    u32     rx_stat_gr1518_hi;
+    u32     rx_stat_gr2047_lo;
+    u32     rx_stat_gr2047_hi;
+    u32     rx_stat_gr4095_lo;
+    u32     rx_stat_gr4095_hi;
+    u32     rx_stat_gr9216_lo;
+    u32     rx_stat_gr9216_hi;
+    u32     rx_stat_gr16383_lo;
+    u32     rx_stat_gr16383_hi;
+    u32     rx_stat_grmax_lo;
+    u32     rx_stat_grmax_hi;
+    u32     rx_stat_grpkt_lo;
+    u32     rx_stat_grpkt_hi;
+    u32     rx_stat_grfcs_lo;
+    u32     rx_stat_grfcs_hi;
+    u32     rx_stat_grmca_lo;
+    u32     rx_stat_grmca_hi;
+    u32     rx_stat_grbca_lo;
+    u32     rx_stat_grbca_hi;
+    u32     rx_stat_grxcf_lo;
+    u32     rx_stat_grxcf_hi;
+    u32     rx_stat_grxpf_lo;
+    u32     rx_stat_grxpf_hi;
+    u32     rx_stat_grxuo_lo;
+    u32     rx_stat_grxuo_hi;
+    u32     rx_stat_grjbr_lo;
+    u32     rx_stat_grjbr_hi;
+    u32     rx_stat_grovr_lo;
+    u32     rx_stat_grovr_hi;
+    u32     rx_stat_grflr_lo;
+    u32     rx_stat_grflr_hi;
+    u32     rx_stat_grmeg_lo;
+    u32     rx_stat_grmeg_hi;
+    u32     rx_stat_grmeb_lo;
+    u32     rx_stat_grmeb_hi;
+    u32     rx_stat_grbyt_lo;
+    u32     rx_stat_grbyt_hi;
+    u32     rx_stat_grund_lo;
+    u32     rx_stat_grund_hi;
+    u32     rx_stat_grfrg_lo;
+    u32     rx_stat_grfrg_hi;
+    u32     rx_stat_grerb_lo;
+    u32     rx_stat_grerb_hi;
+    u32     rx_stat_grfre_lo;
+    u32     rx_stat_grfre_hi;
+    u32     rx_stat_gripj_lo;
+    u32     rx_stat_gripj_hi;
+};
+
+
+union mac_stats {
+    struct emac_stats	emac_stats;
+    struct bmac_stats	bmac_stats;
+};
+
+
+struct mac_stx {
+    /* in_bad_octets */
+    u32     rx_stat_ifhcinbadoctets_hi;
+    u32     rx_stat_ifhcinbadoctets_lo;
+
+    /* out_bad_octets */
+    u32     tx_stat_ifhcoutbadoctets_hi;
+    u32     tx_stat_ifhcoutbadoctets_lo;
+
+    /* crc_receive_errors */
+    u32     rx_stat_dot3statsfcserrors_hi;
+    u32     rx_stat_dot3statsfcserrors_lo;
+    /* alignment_errors */
+    u32     rx_stat_dot3statsalignmenterrors_hi;
+    u32     rx_stat_dot3statsalignmenterrors_lo;
+    /* carrier_sense_errors */
+    u32     rx_stat_dot3statscarriersenseerrors_hi;
+    u32     rx_stat_dot3statscarriersenseerrors_lo;
+    /* false_carrier_detections */
+    u32     rx_stat_falsecarriererrors_hi;
+    u32     rx_stat_falsecarriererrors_lo;
+
+    /* runt_packets_received */
+    u32     rx_stat_etherstatsundersizepkts_hi;
+    u32     rx_stat_etherstatsundersizepkts_lo;
+    /* jabber_packets_received */
+    u32     rx_stat_dot3statsframestoolong_hi;
+    u32     rx_stat_dot3statsframestoolong_lo;
+
+    /* error_runt_packets_received */
+    u32     rx_stat_etherstatsfragments_hi;
+    u32     rx_stat_etherstatsfragments_lo;
+    /* error_jabber_packets_received */
+    u32     rx_stat_etherstatsjabbers_hi;
+    u32     rx_stat_etherstatsjabbers_lo;
+
+    /* control_frames_received */
+    u32     rx_stat_maccontrolframesreceived_hi;
+    u32     rx_stat_maccontrolframesreceived_lo;
+    u32     rx_stat_bmac_xpf_hi;
+    u32     rx_stat_bmac_xpf_lo;
+    u32     rx_stat_bmac_xcf_hi;
+    u32     rx_stat_bmac_xcf_lo;
+
+    /* xoff_state_entered */
+    u32     rx_stat_xoffstateentered_hi;
+    u32     rx_stat_xoffstateentered_lo;
+    /* pause_xon_frames_received */
+    u32     rx_stat_xonpauseframesreceived_hi;
+    u32     rx_stat_xonpauseframesreceived_lo;
+    /* pause_xoff_frames_received */
+    u32     rx_stat_xoffpauseframesreceived_hi;
+    u32     rx_stat_xoffpauseframesreceived_lo;
+    /* pause_xon_frames_transmitted */
+    u32     tx_stat_outxonsent_hi;
+    u32     tx_stat_outxonsent_lo;
+    /* pause_xoff_frames_transmitted */
+    u32     tx_stat_outxoffsent_hi;
+    u32     tx_stat_outxoffsent_lo;
+    /* flow_control_done */
+    u32     tx_stat_flowcontroldone_hi;
+    u32     tx_stat_flowcontroldone_lo;
+
+    /* ether_stats_collisions */
+    u32     tx_stat_etherstatscollisions_hi;
+    u32     tx_stat_etherstatscollisions_lo;
+    /* single_collision_transmit_frames */
+    u32     tx_stat_dot3statssinglecollisionframes_hi;
+    u32     tx_stat_dot3statssinglecollisionframes_lo;
+    /* multiple_collision_transmit_frames */
+    u32     tx_stat_dot3statsmultiplecollisionframes_hi;
+    u32     tx_stat_dot3statsmultiplecollisionframes_lo;
+    /* deferred_transmissions */
+    u32     tx_stat_dot3statsdeferredtransmissions_hi;
+    u32     tx_stat_dot3statsdeferredtransmissions_lo;
+    /* excessive_collision_frames */
+    u32     tx_stat_dot3statsexcessivecollisions_hi;
+    u32     tx_stat_dot3statsexcessivecollisions_lo;
+    /* late_collision_frames */
+    u32     tx_stat_dot3statslatecollisions_hi;
+    u32     tx_stat_dot3statslatecollisions_lo;
+
+    /* frames_transmitted_64_bytes */
+    u32     tx_stat_etherstatspkts64octets_hi;
+    u32     tx_stat_etherstatspkts64octets_lo;
+    /* frames_transmitted_65_127_bytes */
+    u32     tx_stat_etherstatspkts65octetsto127octets_hi;
+    u32     tx_stat_etherstatspkts65octetsto127octets_lo;
+    /* frames_transmitted_128_255_bytes */
+    u32     tx_stat_etherstatspkts128octetsto255octets_hi;
+    u32     tx_stat_etherstatspkts128octetsto255octets_lo;
+    /* frames_transmitted_256_511_bytes */
+    u32     tx_stat_etherstatspkts256octetsto511octets_hi;
+    u32     tx_stat_etherstatspkts256octetsto511octets_lo;
+    /* frames_transmitted_512_1023_bytes */
+    u32     tx_stat_etherstatspkts512octetsto1023octets_hi;
+    u32     tx_stat_etherstatspkts512octetsto1023octets_lo;
+    /* frames_transmitted_1024_1522_bytes */
+    u32     tx_stat_etherstatspkts1024octetsto1522octets_hi;
+    u32     tx_stat_etherstatspkts1024octetsto1522octets_lo;
+    /* frames_transmitted_1523_9022_bytes */
+    u32     tx_stat_etherstatspktsover1522octets_hi;
+    u32     tx_stat_etherstatspktsover1522octets_lo;
+    u32     tx_stat_bmac_2047_hi;
+    u32     tx_stat_bmac_2047_lo;
+    u32     tx_stat_bmac_4095_hi;
+    u32     tx_stat_bmac_4095_lo;
+    u32     tx_stat_bmac_9216_hi;
+    u32     tx_stat_bmac_9216_lo;
+    u32     tx_stat_bmac_16383_hi;
+    u32     tx_stat_bmac_16383_lo;
+
+    /* internal_mac_transmit_errors */
+    u32     tx_stat_dot3statsinternalmactransmiterrors_hi;
+    u32     tx_stat_dot3statsinternalmactransmiterrors_lo;
+
+    /* if_out_discards */
+    u32     tx_stat_bmac_ufl_hi;
+    u32     tx_stat_bmac_ufl_lo;
+};
+
+
+#define MAC_STX_IDX_MAX 		    2
+
+struct host_port_stats {
+    u32 	   host_port_stats_start;
+
+    struct mac_stx mac_stx[MAC_STX_IDX_MAX];
+
+    u32 	   brb_drop_hi;
+    u32 	   brb_drop_lo;
+
+    u32 	   host_port_stats_end;
+};
+
+
+struct host_func_stats {
+    u32     host_func_stats_start;
+
+    u32     total_bytes_received_hi;
+    u32     total_bytes_received_lo;
+
+    u32     total_bytes_transmitted_hi;
+    u32     total_bytes_transmitted_lo;
+
+    u32     total_unicast_packets_received_hi;
+    u32     total_unicast_packets_received_lo;
+
+    u32     total_multicast_packets_received_hi;
+    u32     total_multicast_packets_received_lo;
+
+    u32     total_broadcast_packets_received_hi;
+    u32     total_broadcast_packets_received_lo;
+
+    u32     total_unicast_packets_transmitted_hi;
+    u32     total_unicast_packets_transmitted_lo;
+
+    u32     total_multicast_packets_transmitted_hi;
+    u32     total_multicast_packets_transmitted_lo;
+
+    u32     total_broadcast_packets_transmitted_hi;
+    u32     total_broadcast_packets_transmitted_lo;
+
+    u32     valid_bytes_received_hi;
+    u32     valid_bytes_received_lo;
+
+    u32     host_func_stats_end;
+};
=20
=20
 #define BCM_5710_FW_MAJOR_VERSION			4
@@ -2369,9 +2700,9 @@ struct cmng_struct_per_port {
=20
=20
 /*
- * Common statistics collected by the Xstorm (per port)
+ * Protocol-common statistics collected by the Xstorm (per client)
  */
-struct xstorm_common_stats {
+struct xstorm_per_client_stats {
 	struct regpair total_sent_bytes;
 	u32 total_sent_pkts;
 	u32 unicast_pkts_sent;
@@ -2380,9 +2711,31 @@ struct xstorm_common_stats {
 	u32 multicast_pkts_sent;
 	u32 broadcast_pkts_sent;
 	struct regpair broadcast_bytes_sent;
-	struct regpair done;
+	u16 stats_counter;
+	u16 reserved0;
+	u32 reserved1;
+};
+
+
+/*
+ * Common statistics collected by the Xstorm (per port)
+ */
+struct xstorm_common_stats {
+ struct xstorm_per_client_stats client_statistics[MAX_X_STAT_COUNTER_I=
D];
+};
+
+
+/*
+ * Protocol-common statistics collected by the Tstorm (per port)
+ */
+struct tstorm_per_port_stats {
+	u32 mac_filter_discard;
+	u32 xxoverflow_discard;
+	u32 brb_truncate_discard;
+	u32 mac_discard;
 };
=20
+
 /*
  * Protocol-common statistics collected by the Tstorm (per client)
  */
@@ -2400,20 +2753,17 @@ struct tstorm_per_client_stats {
 	u32 rcv_multicast_pkts;
 	u32 no_buff_discard;
 	u32 ttl0_discard;
-	u32 mac_discard;
-	u32 reserved;
+	u16 stats_counter;
+	u16 reserved0;
+	u32 reserved1;
 };
=20
 /*
- * Protocol-common statistics collected by the Tstorm (per port)
+ * Protocol-common statistics collected by the Tstorm
  */
 struct tstorm_common_stats {
-	struct tstorm_per_client_stats client_statistics[MAX_T_STAT_COUNTER_I=
D];
-	u32 mac_filter_discard;
-	u32 xxoverflow_discard;
-	u32 brb_truncate_discard;
-	u32 reserved;
-	struct regpair done;
+	struct tstorm_per_port_stats port_statistics;
+ struct tstorm_per_client_stats client_statistics[MAX_T_STAT_COUNTER_I=
D];
 };
=20
 /*
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ba46002..20ecfcb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -495,8 +495,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	bnx2x_mc_assert(bp);
 	BNX2X_ERR("end crash dump -----------------\n");
=20
-	bp->stats_state =3D STATS_STATE_DISABLE;
-	DP(BNX2X_MSG_STATS, "stats_state - DISABLE\n");
+	bp->stats_state =3D STATS_STATE_DISABLED;
+	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
 }
=20
 static void bnx2x_int_enable(struct bnx2x *bp)
@@ -873,6 +873,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *f=
p,
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_OPEN):
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_DIAG):
 		DP(NETIF_MSG_IFUP, "got set mac ramrod\n");
+		bp->set_mac_pending =3D 0;
 		break;
=20
 	case (RAMROD_CMD_ID_ETH_SET_MAC | BNX2X_STATE_CLOSING_WAIT4_HALT):
@@ -1203,6 +1204,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void =
*dev_instance)
=20
 /* end of fast path */
=20
+static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_even=
t event);
=20
 /* Link */
=20
@@ -1714,10 +1716,28 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 {
 	int vn;
=20
+	/* Make sure that we are synced with the current statistics */
+	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+
 	bnx2x_phy_hw_lock(bp);
 	bnx2x_link_update(&bp->link_params, &bp->link_vars);
 	bnx2x_phy_hw_unlock(bp);
=20
+	if (bp->link_vars.link_up) {
+
+		if (bp->link_vars.mac_type =3D=3D MAC_TYPE_BMAC) {
+			struct host_port_stats *pstats;
+
+			pstats =3D bnx2x_sp(bp, port_stats);
+			/* reset old bmac stats */
+			memset(&(pstats->mac_stx[0]), 0,
+			       sizeof(struct mac_stx));
+		}
+		if ((bp->state =3D=3D BNX2X_STATE_OPEN) ||
+		    (bp->state =3D=3D BNX2X_STATE_DISABLED))
+			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
+	}
+
 	/* indicate link status */
 	bnx2x_link_report(bp);
=20
@@ -1761,6 +1781,11 @@ static void bnx2x__link_status_update(struct bnx=
2x *bp)
=20
 	bnx2x_link_status_update(&bp->link_params, &bp->link_vars);
=20
+	if (bp->link_vars.link_up)
+		bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
+	else
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+
 	/* indicate link status */
 	bnx2x_link_report(bp);
 }
@@ -1777,6 +1802,8 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
 	val =3D (0xff0f | (1 << (BP_E1HVN(bp) + 4)));
 	REG_WR(bp, HC_REG_TRAILING_EDGE_0 + port*8, val);
 	REG_WR(bp, HC_REG_LEADING_EDGE_0 + port*8, val);
+
+	bnx2x_stats_handle(bp, STATS_EVENT_PMF);
 }
=20
 /* end of Link */
@@ -2301,6 +2328,10 @@ static void bnx2x_sp_task(struct work_struct *wo=
rk)
 	if (status & 0x1)
 		bnx2x_attn_int(bp);
=20
+	/* CStorm events: query_stats, port delete ramrod */
+	if (status & 0x2)
+		bp->stats_pending =3D 0;
+
 	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, bp->def_att_idx,
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
@@ -2345,12 +2376,6 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, vo=
id *dev_instance)
 * Macros
 **********************************************************************=
******/
=20
-#define UPDATE_STAT(s, t) \
-	do { \
-		estats->t +=3D new->s - old->s; \
-		old->s =3D new->s; \
-	} while (0)
-
 /* sum[hi:lo] +=3D add[hi:lo] */
 #define ADD_64(s_hi, a_hi, s_lo, a_lo) \
 	do { \
@@ -2361,40 +2386,39 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, v=
oid *dev_instance)
 /* difference =3D minuend - subtrahend */
 #define DIFF_64(d_hi, m_hi, s_hi, d_lo, m_lo, s_lo) \
 	do { \
-		if (m_lo < s_lo) {      /* underflow */ \
+		if (m_lo < s_lo) { \
+			/* underflow */ \
 			d_hi =3D m_hi - s_hi; \
-			if (d_hi > 0) { /* we can 'loan' 1 */ \
+			if (d_hi > 0) { \
+			/* we can 'loan' 1 */ \
 				d_hi--; \
 				d_lo =3D m_lo + (UINT_MAX - s_lo) + 1; \
-			} else {	/* m_hi <=3D s_hi */ \
+			} else { \
+			/* m_hi <=3D s_hi */ \
 				d_hi =3D 0; \
 				d_lo =3D 0; \
 			} \
-		} else {		/* m_lo >=3D s_lo */ \
+		} else { \
+			/* m_lo >=3D s_lo */ \
 			if (m_hi < s_hi) { \
 			    d_hi =3D 0; \
 			    d_lo =3D 0; \
-			} else {	/* m_hi >=3D s_hi */ \
+			} else { \
+			/* m_hi >=3D s_hi */ \
 			    d_hi =3D m_hi - s_hi; \
 			    d_lo =3D m_lo - s_lo; \
 			} \
 		} \
 	} while (0)
=20
-/* minuend -=3D subtrahend */
-#define SUB_64(m_hi, s_hi, m_lo, s_lo) \
+#define UPDATE_STAT64(s, t) \
 	do { \
-		DIFF_64(m_hi, m_hi, s_hi, m_lo, m_lo, s_lo); \
-	} while (0)
-
-#define UPDATE_STAT64(s_hi, t_hi, s_lo, t_lo) \
-	do { \
-		DIFF_64(diff.hi, new->s_hi, old->s_hi, \
-			diff.lo, new->s_lo, old->s_lo); \
-		old->s_hi =3D new->s_hi; \
-		old->s_lo =3D new->s_lo; \
-		ADD_64(estats->t_hi, diff.hi, \
-		       estats->t_lo, diff.lo); \
+		DIFF_64(diff.hi, new->s##_hi, pstats->mac_stx[0].t##_hi, \
+			diff.lo, new->s##_lo, pstats->mac_stx[0].t##_lo); \
+		pstats->mac_stx[0].t##_hi =3D new->s##_hi; \
+		pstats->mac_stx[0].t##_lo =3D new->s##_lo; \
+		ADD_64(pstats->mac_stx[1].t##_hi, diff.hi, \
+		       pstats->mac_stx[1].t##_lo, diff.lo); \
 	} while (0)
=20
 /* sum[hi:lo] +=3D add */
@@ -2404,16 +2428,25 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, v=
oid *dev_instance)
 		s_hi +=3D (s_lo < a) ? 1 : 0; \
 	} while (0)
=20
-#define UPDATE_EXTEND_STAT(s, t_hi, t_lo) \
+#define UPDATE_EXTEND_STAT(s) \
 	do { \
-		ADD_EXTEND_64(estats->t_hi, estats->t_lo, new->s); \
+		ADD_EXTEND_64(pstats->mac_stx[1].s##_hi, \
+			      pstats->mac_stx[1].s##_lo, \
+			      new->s); \
 	} while (0)
=20
-#define UPDATE_EXTEND_TSTAT(s, t_hi, t_lo) \
+#define UPDATE_EXTEND_TSTAT(s, t) \
 	do { \
 		diff =3D le32_to_cpu(tclient->s) - old_tclient->s; \
 		old_tclient->s =3D le32_to_cpu(tclient->s); \
-		ADD_EXTEND_64(estats->t_hi, estats->t_lo, diff); \
+		ADD_EXTEND_64(fstats->t##_hi, fstats->t##_lo, diff); \
+	} while (0)
+
+#define UPDATE_EXTEND_XSTAT(s, t) \
+	do { \
+		diff =3D le32_to_cpu(xclient->s) - old_xclient->s; \
+		old_xclient->s =3D le32_to_cpu(xclient->s); \
+		ADD_EXTEND_64(fstats->t##_hi, fstats->t##_lo, diff); \
 	} while (0)
=20
 /*
@@ -2436,55 +2469,268 @@ static inline long bnx2x_hilo(u32 *hiref)
  * Init service functions
  */
=20
-static void bnx2x_init_mac_stats(struct bnx2x *bp)
+static void bnx2x_storm_stats_init(struct bnx2x *bp)
+{
+	int func =3D BP_FUNC(bp);
+
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(func), 1);
+	REG_WR(bp, BAR_XSTRORM_INTMEM +
+	       XSTORM_STATS_FLAGS_OFFSET(func) + 4, 0);
+
+	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(func), 1);
+	REG_WR(bp, BAR_TSTRORM_INTMEM +
+	       TSTORM_STATS_FLAGS_OFFSET(func) + 4, 0);
+
+	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(func), 0);
+	REG_WR(bp, BAR_CSTRORM_INTMEM +
+	       CSTORM_STATS_FLAGS_OFFSET(func) + 4, 0);
+
+	REG_WR(bp, BAR_XSTRORM_INTMEM +
+	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
+	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
+	REG_WR(bp, BAR_XSTRORM_INTMEM +
+	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
+	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+
+	REG_WR(bp, BAR_TSTRORM_INTMEM +
+	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func),
+	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
+	REG_WR(bp, BAR_TSTRORM_INTMEM +
+	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(func) + 4,
+	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+}
+
+static void bnx2x_storm_stats_post(struct bnx2x *bp)
+{
+	if (!bp->stats_pending) {
+		struct eth_query_ramrod_data ramrod_data =3D {0};
+		int rc;
+
+		ramrod_data.drv_counter =3D bp->stats_counter++;
+		ramrod_data.collect_port_1b =3D bp->port.pmf ? 1 : 0;
+		ramrod_data.ctr_id_vector =3D (1 << BP_CL_ID(bp));
+
+		rc =3D bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0,
+				   ((u32 *)&ramrod_data)[1],
+				   ((u32 *)&ramrod_data)[0], 0);
+		if (rc =3D=3D 0) {
+			/* stats ramrod has it's own slot on the spq */
+			bp->spq_left++;
+			bp->stats_pending =3D 1;
+		}
+	}
+}
+
+static void bnx2x_stats_init(struct bnx2x *bp)
+{
+	int port =3D BP_PORT(bp);
+
+	bp->executer_idx =3D 0;
+	bp->stats_counter =3D 0;
+
+	/* port stats */
+	if (!BP_NOMCP(bp))
+		bp->port.port_stx =3D SHMEM_RD(bp, port_mb[port].port_stx);
+	else
+		bp->port.port_stx =3D 0;
+	DP(BNX2X_MSG_MCP, "port_stx 0x%x\n", bp->port.port_stx);
+
+	memset(&(bp->port.old_nig_stats), 0, sizeof(struct nig_stats));
+	bp->port.old_nig_stats.brb_discard =3D
+			REG_RD(bp, NIG_REG_STAT0_BRB_DISCARD + port*0x38);
+
+	/* function stats */
+	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
+	memset(&bp->old_tclient, 0, sizeof(struct tstorm_per_client_stats));
+	memset(&bp->old_xclient, 0, sizeof(struct xstorm_per_client_stats));
+	memset(&bp->eth_stats, 0, sizeof(struct bnx2x_eth_stats));
+
+	bp->stats_state =3D STATS_STATE_DISABLED;
+	if (IS_E1HMF(bp) && bp->port.pmf && bp->port.port_stx)
+		bnx2x_stats_handle(bp, STATS_EVENT_PMF);
+}
+
+static void bnx2x_hw_stats_post(struct bnx2x *bp)
+{
+	struct dmae_command *dmae =3D &bp->stats_dmae;
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
+
+	*stats_comp =3D DMAE_COMP_VAL;
+
+	/* loader */
+	if (bp->executer_idx) {
+		int loader_idx =3D PMF_DMAE_C(bp);
+
+		memset(dmae, 0, sizeof(struct dmae_command));
+
+		dmae->opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+				DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
+				DMAE_CMD_DST_RESET |
+#ifdef __BIG_ENDIAN
+				DMAE_CMD_ENDIANITY_B_DW_SWAP |
+#else
+				DMAE_CMD_ENDIANITY_DW_SWAP |
+#endif
+				(BP_PORT(bp) ? DMAE_CMD_PORT_1 :
+					       DMAE_CMD_PORT_0) |
+				(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, dmae[0]));
+		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, dmae[0]));
+		dmae->dst_addr_lo =3D (DMAE_REG_CMD_MEM +
+				     sizeof(struct dmae_command) *
+				     (loader_idx + 1)) >> 2;
+		dmae->dst_addr_hi =3D 0;
+		dmae->len =3D sizeof(struct dmae_command) >> 2;
+		if (CHIP_IS_E1(bp))
+			dmae->len--;
+		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx + 1] >> 2;
+		dmae->comp_addr_hi =3D 0;
+		dmae->comp_val =3D 1;
+
+		*stats_comp =3D 0;
+		bnx2x_post_dmae(bp, dmae, loader_idx);
+
+	} else if (bp->func_stx) {
+		*stats_comp =3D 0;
+		bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
+	}
+}
+
+static int bnx2x_stats_comp(struct bnx2x *bp)
+{
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
+	int cnt =3D 10;
+
+	might_sleep();
+	while (*stats_comp !=3D DMAE_COMP_VAL) {
+		msleep(1);
+		if (!cnt) {
+			BNX2X_ERR("timeout waiting for stats finished\n");
+			break;
+		}
+		cnt--;
+	}
+	return 1;
+}
+
+/*
+ * Statistics service functions
+ */
+
+static void bnx2x_stats_pmf_update(struct bnx2x *bp)
+{
+	struct dmae_command *dmae;
+	u32 opcode;
+	int loader_idx =3D PMF_DMAE_C(bp);
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
+
+	/* sanity */
+	if (!IS_E1HMF(bp) || !bp->port.pmf || !bp->port.port_stx) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
+
+	bp->executer_idx =3D 0;
+
+	opcode =3D (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
+		  DMAE_CMD_C_ENABLE |
+		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+#ifdef __BIG_ENDIAN
+		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
+#else
+		  DMAE_CMD_ENDIANITY_DW_SWAP |
+#endif
+		  (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		  (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+
+	dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
+	dmae->opcode =3D (opcode | DMAE_CMD_C_DST_GRC);
+	dmae->src_addr_lo =3D bp->port.port_stx >> 2;
+	dmae->src_addr_hi =3D 0;
+	dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, port_stats));
+	dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, port_stats));
+	dmae->len =3D DMAE_LEN32_RD_MAX;
+	dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
+	dmae->comp_addr_hi =3D 0;
+	dmae->comp_val =3D 1;
+
+	dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
+	dmae->opcode =3D (opcode | DMAE_CMD_C_DST_PCI);
+	dmae->src_addr_lo =3D (bp->port.port_stx >> 2) + DMAE_LEN32_RD_MAX;
+	dmae->src_addr_hi =3D 0;
+	dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, port_stats)
+				   + DMAE_LEN32_RD_MAX * 4);
+	dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, port_stats)
+				   + DMAE_LEN32_RD_MAX * 4);
+	dmae->len =3D (sizeof(struct host_port_stats) >> 2) - DMAE_LEN32_RD_M=
AX;
+	dmae->comp_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_val =3D DMAE_COMP_VAL;
+
+	*stats_comp =3D 0;
+	bnx2x_hw_stats_post(bp);
+	bnx2x_stats_comp(bp);
+}
+
+static void bnx2x_port_stats_init(struct bnx2x *bp)
 {
 	struct dmae_command *dmae;
 	int port =3D BP_PORT(bp);
-	int loader_idx =3D port * 8;
+	int vn =3D BP_E1HVN(bp);
 	u32 opcode;
+	int loader_idx =3D PMF_DMAE_C(bp);
 	u32 mac_addr;
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
+
+	/* sanity */
+	if (!bp->link_vars.link_up || !bp->port.pmf) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
=20
 	bp->executer_idx =3D 0;
-	if (bp->func_stx) {
-		/* MCP */
-		opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-			  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+
+	/* MCP */
+	opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+		  DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
+		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
 #ifdef __BIG_ENDIAN
-			  DMAE_CMD_ENDIANITY_B_DW_SWAP |
+		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
 #else
-			  DMAE_CMD_ENDIANITY_DW_SWAP |
+		  DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		  (vn << DMAE_CMD_E1HVN_SHIFT));
=20
-		if (bp->link_vars.link_up)
-			opcode |=3D (DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE);
+	if (bp->port.port_stx) {
=20
 		dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
 		dmae->opcode =3D opcode;
-		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, eth_stats) +
-					   sizeof(u32));
-		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, eth_stats) +
-					   sizeof(u32));
-		dmae->dst_addr_lo =3D bp->func_stx >> 2;
+		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, port_stats));
+		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, port_stats));
+		dmae->dst_addr_lo =3D bp->port.port_stx >> 2;
 		dmae->dst_addr_hi =3D 0;
-		dmae->len =3D (offsetof(struct bnx2x_eth_stats, mac_stx_end) -
-			     sizeof(u32)) >> 2;
-		if (bp->link_vars.link_up) {
-			dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
-			dmae->comp_addr_hi =3D 0;
-			dmae->comp_val =3D 1;
-		} else {
-			dmae->comp_addr_lo =3D 0;
-			dmae->comp_addr_hi =3D 0;
-			dmae->comp_val =3D 0;
-		}
+		dmae->len =3D sizeof(struct host_port_stats) >> 2;
+		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
+		dmae->comp_addr_hi =3D 0;
+		dmae->comp_val =3D 1;
 	}
=20
-	if (!bp->link_vars.link_up) {
-		/* no need to collect statistics in link down */
-		return;
+	if (bp->func_stx) {
+
+		dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
+		dmae->opcode =3D opcode;
+		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, func_stats));
+		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, func_stats));
+		dmae->dst_addr_lo =3D bp->func_stx >> 2;
+		dmae->dst_addr_hi =3D 0;
+		dmae->len =3D sizeof(struct host_func_stats) >> 2;
+		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
+		dmae->comp_addr_hi =3D 0;
+		dmae->comp_val =3D 1;
 	}
=20
+	/* MAC */
 	opcode =3D (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
 		  DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
 		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
@@ -2493,7 +2739,8 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp=
)
 #else
 		  DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		  (vn << DMAE_CMD_E1HVN_SHIFT));
=20
 	if (bp->link_vars.mac_type =3D=3D MAC_TYPE_BMAC) {
=20
@@ -2523,9 +2770,9 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp=
)
 				     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
 		dmae->src_addr_hi =3D 0;
 		dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
-					offsetof(struct bmac_stats, rx_gr64));
+				offsetof(struct bmac_stats, rx_stat_gr64_lo));
 		dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
-					offsetof(struct bmac_stats, rx_gr64));
+				offsetof(struct bmac_stats, rx_stat_gr64_lo));
 		dmae->len =3D (8 + BIGMAC_REGISTER_RX_STAT_GRIPJ -
 			     BIGMAC_REGISTER_RX_STAT_GR64) >> 2;
 		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
@@ -2556,11 +2803,9 @@ static void bnx2x_init_mac_stats(struct bnx2x *b=
p)
 				     EMAC_REG_EMAC_RX_STAT_AC_28) >> 2;
 		dmae->src_addr_hi =3D 0;
 		dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
-					   offsetof(struct emac_stats,
-						    rx_falsecarriererrors));
+		     offsetof(struct emac_stats, rx_stat_falsecarriererrors));
 		dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
-					   offsetof(struct emac_stats,
-						    rx_falsecarriererrors));
+		     offsetof(struct emac_stats, rx_stat_falsecarriererrors));
 		dmae->len =3D 1;
 		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
 		dmae->comp_addr_hi =3D 0;
@@ -2573,11 +2818,9 @@ static void bnx2x_init_mac_stats(struct bnx2x *b=
p)
 				     EMAC_REG_EMAC_TX_STAT_AC) >> 2;
 		dmae->src_addr_hi =3D 0;
 		dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, mac_stats) +
-					   offsetof(struct emac_stats,
-						    tx_ifhcoutoctets));
+			offsetof(struct emac_stats, tx_stat_ifhcoutoctets));
 		dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, mac_stats) +
-					   offsetof(struct emac_stats,
-						    tx_ifhcoutoctets));
+			offsetof(struct emac_stats, tx_stat_ifhcoutoctets));
 		dmae->len =3D EMAC_REG_EMAC_TX_STAT_AC_COUNT;
 		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
 		dmae->comp_addr_hi =3D 0;
@@ -2594,325 +2837,328 @@ static void bnx2x_init_mac_stats(struct bnx2x=
 *bp)
 #else
 			DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
+			(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(vn << DMAE_CMD_E1HVN_SHIFT));
 	dmae->src_addr_lo =3D (port ? NIG_REG_STAT1_BRB_DISCARD :
 				    NIG_REG_STAT0_BRB_DISCARD) >> 2;
 	dmae->src_addr_hi =3D 0;
-	dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, nig));
-	dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, nig));
+	dmae->dst_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, nig_stats));
+	dmae->dst_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, nig_stats));
 	dmae->len =3D (sizeof(struct nig_stats) - 2*sizeof(u32)) >> 2;
-	dmae->comp_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, nig) +
-				    offsetof(struct nig_stats, done));
-	dmae->comp_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, nig) +
-				    offsetof(struct nig_stats, done));
-	dmae->comp_val =3D 0xffffffff;
+	dmae->comp_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_val =3D DMAE_COMP_VAL;
+
+	*stats_comp =3D 0;
 }
=20
-static void bnx2x_init_stats(struct bnx2x *bp)
+static void bnx2x_func_stats_init(struct bnx2x *bp)
 {
-	int port =3D BP_PORT(bp);
-
-	bp->stats_state =3D STATS_STATE_DISABLE;
-	bp->executer_idx =3D 0;
+	struct dmae_command *dmae =3D &bp->stats_dmae;
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
=20
-	bp->old_brb_discard =3D REG_RD(bp,
-				     NIG_REG_STAT0_BRB_DISCARD + port*0x38);
-
-	memset(&bp->old_bmac, 0, sizeof(struct bmac_stats));
-	memset(&bp->old_tclient, 0, sizeof(struct tstorm_per_client_stats));
-	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
-
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_STATS_FLAGS_OFFSET(port), 1);
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_STATS_FLAGS_OFFSET(port) + 4, 0);
-
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_STATS_FLAGS_OFFSET(port), 1);
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_STATS_FLAGS_OFFSET(port) + 4, 0);
+	/* sanity */
+	if (!bp->func_stx) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
=20
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_STATS_FLAGS_OFFSET(port), 0);
-	REG_WR(bp, BAR_CSTRORM_INTMEM +
-	       CSTORM_STATS_FLAGS_OFFSET(port) + 4, 0);
+	bp->executer_idx =3D 0;
+	memset(dmae, 0, sizeof(struct dmae_command));
=20
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port),
-	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
-	REG_WR(bp, BAR_XSTRORM_INTMEM +
-	       XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port) + 4,
-	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+	dmae->opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
+			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+#ifdef __BIG_ENDIAN
+			DMAE_CMD_ENDIANITY_B_DW_SWAP |
+#else
+			DMAE_CMD_ENDIANITY_DW_SWAP |
+#endif
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, func_stats));
+	dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, func_stats));
+	dmae->dst_addr_lo =3D bp->func_stx >> 2;
+	dmae->dst_addr_hi =3D 0;
+	dmae->len =3D sizeof(struct host_func_stats) >> 2;
+	dmae->comp_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_val =3D DMAE_COMP_VAL;
=20
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port),
-	       U64_LO(bnx2x_sp_mapping(bp, fw_stats)));
-	REG_WR(bp, BAR_TSTRORM_INTMEM +
-	       TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(port) + 4,
-	       U64_HI(bnx2x_sp_mapping(bp, fw_stats)));
+	*stats_comp =3D 0;
 }
=20
-static void bnx2x_stop_stats(struct bnx2x *bp)
+static void bnx2x_stats_start(struct bnx2x *bp)
 {
-	might_sleep();
-	if (bp->stats_state !=3D STATS_STATE_DISABLE) {
-		int timeout =3D 10;
+	if (bp->port.pmf)
+		bnx2x_port_stats_init(bp);
+
+	else if (bp->func_stx)
+		bnx2x_func_stats_init(bp);
+
+	bnx2x_hw_stats_post(bp);
+	bnx2x_storm_stats_post(bp);
+}
+
+static void bnx2x_stats_pmf_start(struct bnx2x *bp)
+{
+	bnx2x_stats_comp(bp);
+	bnx2x_stats_pmf_update(bp);
+	bnx2x_stats_start(bp);
+}
+
+static void bnx2x_stats_restart(struct bnx2x *bp)
+{
+	bnx2x_stats_comp(bp);
+	bnx2x_stats_start(bp);
+}
+
+static void bnx2x_bmac_stats_update(struct bnx2x *bp)
+{
+	struct bmac_stats *new =3D bnx2x_sp(bp, mac_stats.bmac_stats);
+	struct host_port_stats *pstats =3D bnx2x_sp(bp, port_stats);
+	struct regpair diff;
+
+	UPDATE_STAT64(rx_stat_grerb, rx_stat_ifhcinbadoctets);
+	UPDATE_STAT64(rx_stat_grfcs, rx_stat_dot3statsfcserrors);
+	UPDATE_STAT64(rx_stat_grund, rx_stat_etherstatsundersizepkts);
+	UPDATE_STAT64(rx_stat_grovr, rx_stat_dot3statsframestoolong);
+	UPDATE_STAT64(rx_stat_grfrg, rx_stat_etherstatsfragments);
+	UPDATE_STAT64(rx_stat_grjbr, rx_stat_etherstatsjabbers);
+	UPDATE_STAT64(rx_stat_grxpf, rx_stat_bmac_xpf);
+	UPDATE_STAT64(rx_stat_grxcf, rx_stat_bmac_xcf);
+	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffstateentered);
+	UPDATE_STAT64(rx_stat_grxpf, rx_stat_xoffpauseframesreceived);
+	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_outxoffsent);
+	UPDATE_STAT64(tx_stat_gtxpf, tx_stat_flowcontroldone);
+	UPDATE_STAT64(tx_stat_gt64, tx_stat_etherstatspkts64octets);
+	UPDATE_STAT64(tx_stat_gt127,
+				tx_stat_etherstatspkts65octetsto127octets);
+	UPDATE_STAT64(tx_stat_gt255,
+				tx_stat_etherstatspkts128octetsto255octets);
+	UPDATE_STAT64(tx_stat_gt511,
+				tx_stat_etherstatspkts256octetsto511octets);
+	UPDATE_STAT64(tx_stat_gt1023,
+				tx_stat_etherstatspkts512octetsto1023octets);
+	UPDATE_STAT64(tx_stat_gt1518,
+				tx_stat_etherstatspkts1024octetsto1522octets);
+	UPDATE_STAT64(tx_stat_gt2047, tx_stat_bmac_2047);
+	UPDATE_STAT64(tx_stat_gt4095, tx_stat_bmac_4095);
+	UPDATE_STAT64(tx_stat_gt9216, tx_stat_bmac_9216);
+	UPDATE_STAT64(tx_stat_gt16383, tx_stat_bmac_16383);
+	UPDATE_STAT64(tx_stat_gterr,
+				tx_stat_dot3statsinternalmactransmiterrors);
+	UPDATE_STAT64(tx_stat_gtufl, tx_stat_bmac_ufl);
+}
+
+static void bnx2x_emac_stats_update(struct bnx2x *bp)
+{
+	struct emac_stats *new =3D bnx2x_sp(bp, mac_stats.emac_stats);
+	struct host_port_stats *pstats =3D bnx2x_sp(bp, port_stats);
+
+	UPDATE_EXTEND_STAT(rx_stat_ifhcinbadoctets);
+	UPDATE_EXTEND_STAT(tx_stat_ifhcoutbadoctets);
+	UPDATE_EXTEND_STAT(rx_stat_dot3statsfcserrors);
+	UPDATE_EXTEND_STAT(rx_stat_dot3statsalignmenterrors);
+	UPDATE_EXTEND_STAT(rx_stat_dot3statscarriersenseerrors);
+	UPDATE_EXTEND_STAT(rx_stat_falsecarriererrors);
+	UPDATE_EXTEND_STAT(rx_stat_etherstatsundersizepkts);
+	UPDATE_EXTEND_STAT(rx_stat_dot3statsframestoolong);
+	UPDATE_EXTEND_STAT(rx_stat_etherstatsfragments);
+	UPDATE_EXTEND_STAT(rx_stat_etherstatsjabbers);
+	UPDATE_EXTEND_STAT(rx_stat_maccontrolframesreceived);
+	UPDATE_EXTEND_STAT(rx_stat_xoffstateentered);
+	UPDATE_EXTEND_STAT(rx_stat_xonpauseframesreceived);
+	UPDATE_EXTEND_STAT(rx_stat_xoffpauseframesreceived);
+	UPDATE_EXTEND_STAT(tx_stat_outxonsent);
+	UPDATE_EXTEND_STAT(tx_stat_outxoffsent);
+	UPDATE_EXTEND_STAT(tx_stat_flowcontroldone);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatscollisions);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statssinglecollisionframes);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statsmultiplecollisionframes);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statsdeferredtransmissions);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statsexcessivecollisions);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statslatecollisions);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts64octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts65octetsto127octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts128octetsto255octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts256octetsto511octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts512octetsto1023octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspkts1024octetsto1522octets);
+	UPDATE_EXTEND_STAT(tx_stat_etherstatspktsover1522octets);
+	UPDATE_EXTEND_STAT(tx_stat_dot3statsinternalmactransmiterrors);
+}
+
+static int bnx2x_hw_stats_update(struct bnx2x *bp)
+{
+	struct nig_stats *new =3D bnx2x_sp(bp, nig_stats);
+	struct nig_stats *old =3D &(bp->port.old_nig_stats);
+	struct host_port_stats *pstats =3D bnx2x_sp(bp, port_stats);
+	struct bnx2x_eth_stats *estats =3D &bp->eth_stats;
+
+	if (bp->link_vars.mac_type =3D=3D MAC_TYPE_BMAC)
+		bnx2x_bmac_stats_update(bp);
+
+	else if (bp->link_vars.mac_type =3D=3D MAC_TYPE_EMAC)
+		bnx2x_emac_stats_update(bp);
+
+	else { /* unreached */
+		BNX2X_ERR("stats updated by dmae but no MAC active\n");
+		return -1;
+	}
=20
-		bp->stats_state =3D STATS_STATE_STOP;
-		DP(BNX2X_MSG_STATS, "stats_state - STOP\n");
+	ADD_EXTEND_64(pstats->brb_drop_hi, pstats->brb_drop_lo,
+		      new->brb_discard - old->brb_discard);
+
+	memcpy(old, new, sizeof(struct nig_stats));
+
+	memcpy(&(estats->rx_stat_ifhcinbadoctets_hi), &(pstats->mac_stx[1]),
+	       sizeof(struct mac_stx));
+	estats->brb_drop_hi =3D pstats->brb_drop_hi;
+	estats->brb_drop_lo =3D pstats->brb_drop_lo;
+
+	estats->etherstatspktsover1522octets_hi =3D 0;
+	estats->etherstatspktsover1522octets_lo =3D 0;
+	ADD_64(estats->etherstatspktsover1522octets_hi,
+	       estats->tx_stat_etherstatspktsover1522octets_hi,
+	       estats->etherstatspktsover1522octets_lo,
+	       estats->tx_stat_etherstatspktsover1522octets_lo);
+	ADD_64(estats->etherstatspktsover1522octets_hi,
+	       estats->tx_stat_bmac_2047_hi,
+	       estats->etherstatspktsover1522octets_lo,
+	       estats->tx_stat_bmac_2047_lo);
+	ADD_64(estats->etherstatspktsover1522octets_hi,
+	       estats->tx_stat_bmac_4095_hi,
+	       estats->etherstatspktsover1522octets_lo,
+	       estats->tx_stat_bmac_4095_lo);
+	ADD_64(estats->etherstatspktsover1522octets_hi,
+	       estats->tx_stat_bmac_9216_hi,
+	       estats->etherstatspktsover1522octets_lo,
+	       estats->tx_stat_bmac_9216_lo);
+	ADD_64(estats->etherstatspktsover1522octets_hi,
+	       estats->tx_stat_bmac_16383_hi,
+	       estats->etherstatspktsover1522octets_lo,
+	       estats->tx_stat_bmac_16383_lo);
+
+	pstats->host_port_stats_start =3D ++pstats->host_port_stats_end;
=20
-		while (bp->stats_state !=3D STATS_STATE_DISABLE) {
-			if (!timeout) {
-				BNX2X_ERR("timeout waiting for stats stop\n");
-				break;
-			}
-			timeout--;
-			msleep(100);
-		}
-	}
-	DP(BNX2X_MSG_STATS, "stats_state - DISABLE\n");
+	return 0;
 }
=20
-/*
- * Statistics service functions
- */
-
-static void bnx2x_update_bmac_stats(struct bnx2x *bp)
-{
-	struct regp diff;
-	struct regp sum;
-	struct bmac_stats *new =3D bnx2x_sp(bp, mac_stats.bmac);
-	struct bmac_stats *old =3D &bp->old_bmac;
-	struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
-
-	sum.hi =3D 0;
-	sum.lo =3D 0;
-
-	UPDATE_STAT64(tx_gtbyt.hi, total_bytes_transmitted_hi,
-		      tx_gtbyt.lo, total_bytes_transmitted_lo);
-
-	UPDATE_STAT64(tx_gtmca.hi, total_multicast_packets_transmitted_hi,
-		      tx_gtmca.lo, total_multicast_packets_transmitted_lo);
-	ADD_64(sum.hi, diff.hi, sum.lo, diff.lo);
-
-	UPDATE_STAT64(tx_gtgca.hi, total_broadcast_packets_transmitted_hi,
-		      tx_gtgca.lo, total_broadcast_packets_transmitted_lo);
-	ADD_64(sum.hi, diff.hi, sum.lo, diff.lo);
-
-	UPDATE_STAT64(tx_gtpkt.hi, total_unicast_packets_transmitted_hi,
-		      tx_gtpkt.lo, total_unicast_packets_transmitted_lo);
-	SUB_64(estats->total_unicast_packets_transmitted_hi, sum.hi,
-	       estats->total_unicast_packets_transmitted_lo, sum.lo);
-
-	UPDATE_STAT(tx_gtxpf.lo, pause_xoff_frames_transmitted);
-	UPDATE_STAT(tx_gt64.lo, frames_transmitted_64_bytes);
-	UPDATE_STAT(tx_gt127.lo, frames_transmitted_65_127_bytes);
-	UPDATE_STAT(tx_gt255.lo, frames_transmitted_128_255_bytes);
-	UPDATE_STAT(tx_gt511.lo, frames_transmitted_256_511_bytes);
-	UPDATE_STAT(tx_gt1023.lo, frames_transmitted_512_1023_bytes);
-	UPDATE_STAT(tx_gt1518.lo, frames_transmitted_1024_1522_bytes);
-	UPDATE_STAT(tx_gt2047.lo, frames_transmitted_1523_9022_bytes);
-	UPDATE_STAT(tx_gt4095.lo, frames_transmitted_1523_9022_bytes);
-	UPDATE_STAT(tx_gt9216.lo, frames_transmitted_1523_9022_bytes);
-	UPDATE_STAT(tx_gt16383.lo, frames_transmitted_1523_9022_bytes);
-
-	UPDATE_STAT(rx_grfcs.lo, crc_receive_errors);
-	UPDATE_STAT(rx_grund.lo, runt_packets_received);
-	UPDATE_STAT(rx_grovr.lo, stat_Dot3statsFramesTooLong);
-	UPDATE_STAT(rx_grxpf.lo, pause_xoff_frames_received);
-	UPDATE_STAT(rx_grxcf.lo, control_frames_received);
-	/* UPDATE_STAT(rx_grxpf.lo, control_frames_received); */
-	UPDATE_STAT(rx_grfrg.lo, error_runt_packets_received);
-	UPDATE_STAT(rx_grjbr.lo, error_jabber_packets_received);
-
-	UPDATE_STAT64(rx_grerb.hi, stat_IfHCInBadOctets_hi,
-		      rx_grerb.lo, stat_IfHCInBadOctets_lo);
-	UPDATE_STAT64(tx_gtufl.hi, stat_IfHCOutBadOctets_hi,
-		      tx_gtufl.lo, stat_IfHCOutBadOctets_lo);
-	UPDATE_STAT(tx_gterr.lo, stat_Dot3statsInternalMacTransmitErrors);
-	/* UPDATE_STAT(rx_grxpf.lo, stat_XoffStateEntered); */
-	estats->stat_XoffStateEntered =3D estats->pause_xoff_frames_received;
-}
-
-static void bnx2x_update_emac_stats(struct bnx2x *bp)
-{
-	struct emac_stats *new =3D bnx2x_sp(bp, mac_stats.emac);
-	struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
-
-	UPDATE_EXTEND_STAT(tx_ifhcoutoctets, total_bytes_transmitted_hi,
-					     total_bytes_transmitted_lo);
-	UPDATE_EXTEND_STAT(tx_ifhcoutucastpkts,
-					total_unicast_packets_transmitted_hi,
-					total_unicast_packets_transmitted_lo);
-	UPDATE_EXTEND_STAT(tx_ifhcoutmulticastpkts,
-				      total_multicast_packets_transmitted_hi,
-				      total_multicast_packets_transmitted_lo);
-	UPDATE_EXTEND_STAT(tx_ifhcoutbroadcastpkts,
-				      total_broadcast_packets_transmitted_hi,
-				      total_broadcast_packets_transmitted_lo);
-
-	estats->pause_xon_frames_transmitted +=3D new->tx_outxonsent;
-	estats->pause_xoff_frames_transmitted +=3D new->tx_outxoffsent;
-	estats->single_collision_transmit_frames +=3D
-				new->tx_dot3statssinglecollisionframes;
-	estats->multiple_collision_transmit_frames +=3D
-				new->tx_dot3statsmultiplecollisionframes;
-	estats->late_collision_frames +=3D new->tx_dot3statslatecollisions;
-	estats->excessive_collision_frames +=3D
-				new->tx_dot3statsexcessivecollisions;
-	estats->frames_transmitted_64_bytes +=3D new->tx_etherstatspkts64octe=
ts;
-	estats->frames_transmitted_65_127_bytes +=3D
-				new->tx_etherstatspkts65octetsto127octets;
-	estats->frames_transmitted_128_255_bytes +=3D
-				new->tx_etherstatspkts128octetsto255octets;
-	estats->frames_transmitted_256_511_bytes +=3D
-				new->tx_etherstatspkts256octetsto511octets;
-	estats->frames_transmitted_512_1023_bytes +=3D
-				new->tx_etherstatspkts512octetsto1023octets;
-	estats->frames_transmitted_1024_1522_bytes +=3D
-				new->tx_etherstatspkts1024octetsto1522octet;
-	estats->frames_transmitted_1523_9022_bytes +=3D
-				new->tx_etherstatspktsover1522octets;
-
-	estats->crc_receive_errors +=3D new->rx_dot3statsfcserrors;
-	estats->alignment_errors +=3D new->rx_dot3statsalignmenterrors;
-	estats->false_carrier_detections +=3D new->rx_falsecarriererrors;
-	estats->runt_packets_received +=3D new->rx_etherstatsundersizepkts;
-	estats->stat_Dot3statsFramesTooLong +=3D new->rx_dot3statsframestoolo=
ng;
-	estats->pause_xon_frames_received +=3D new->rx_xonpauseframesreceived=
;
-	estats->pause_xoff_frames_received +=3D new->rx_xoffpauseframesreceiv=
ed;
-	estats->control_frames_received +=3D new->rx_maccontrolframesreceived=
;
-	estats->error_runt_packets_received +=3D new->rx_etherstatsfragments;
-	estats->error_jabber_packets_received +=3D new->rx_etherstatsjabbers;
-
-	UPDATE_EXTEND_STAT(rx_ifhcinbadoctets, stat_IfHCInBadOctets_hi,
-					       stat_IfHCInBadOctets_lo);
-	UPDATE_EXTEND_STAT(tx_ifhcoutbadoctets, stat_IfHCOutBadOctets_hi,
-						stat_IfHCOutBadOctets_lo);
-	estats->stat_Dot3statsInternalMacTransmitErrors +=3D
-				new->tx_dot3statsinternalmactransmiterrors;
-	estats->stat_Dot3StatsCarrierSenseErrors +=3D
-				new->rx_dot3statscarriersenseerrors;
-	estats->stat_Dot3StatsDeferredTransmissions +=3D
-				new->tx_dot3statsdeferredtransmissions;
-	estats->stat_FlowControlDone +=3D new->tx_flowcontroldone;
-	estats->stat_XoffStateEntered +=3D new->rx_xoffstateentered;
-}
-
-static int bnx2x_update_storm_stats(struct bnx2x *bp)
+static int bnx2x_storm_stats_update(struct bnx2x *bp)
 {
 	struct eth_stats_query *stats =3D bnx2x_sp(bp, fw_stats);
-	struct tstorm_common_stats *tstats =3D &stats->tstorm_common;
+	int cl_id =3D BP_CL_ID(bp);
+	struct tstorm_per_port_stats *tport =3D
+				&stats->tstorm_common.port_statistics;
 	struct tstorm_per_client_stats *tclient =3D
-						&tstats->client_statistics[0];
+			&stats->tstorm_common.client_statistics[cl_id];
 	struct tstorm_per_client_stats *old_tclient =3D &bp->old_tclient;
-	struct xstorm_common_stats *xstats =3D &stats->xstorm_common;
-	struct nig_stats *nstats =3D bnx2x_sp(bp, nig);
-	struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
+	struct xstorm_per_client_stats *xclient =3D
+			&stats->xstorm_common.client_statistics[cl_id];
+	struct xstorm_per_client_stats *old_xclient =3D &bp->old_xclient;
+	struct host_func_stats *fstats =3D bnx2x_sp(bp, func_stats);
+	struct bnx2x_eth_stats *estats =3D &bp->eth_stats;
 	u32 diff;
=20
-	/* are DMAE stats valid? */
-	if (nstats->done !=3D 0xffffffff) {
-		DP(BNX2X_MSG_STATS, "stats not updated by dmae\n");
+	/* are storm stats valid? */
+	if ((u16)(le16_to_cpu(tclient->stats_counter) + 1) !=3D
+							bp->stats_counter) {
+		DP(BNX2X_MSG_STATS, "stats not updated by tstorm"
+		   "  tstorm counter (%d) !=3D stats_counter (%d)\n",
+		   tclient->stats_counter, bp->stats_counter);
 		return -1;
 	}
-
-	/* are storm stats valid? */
-	if (tstats->done.hi !=3D 0xffffffff) {
-		DP(BNX2X_MSG_STATS, "stats not updated by tstorm\n");
+	if ((u16)(le16_to_cpu(xclient->stats_counter) + 1) !=3D
+							bp->stats_counter) {
+		DP(BNX2X_MSG_STATS, "stats not updated by xstorm"
+		   "  xstorm counter (%d) !=3D stats_counter (%d)\n",
+		   xclient->stats_counter, bp->stats_counter);
 		return -2;
 	}
-	if (xstats->done.hi !=3D 0xffffffff) {
-		DP(BNX2X_MSG_STATS, "stats not updated by xstorm\n");
-		return -3;
-	}
=20
-	estats->total_bytes_received_hi =3D
-	estats->valid_bytes_received_hi =3D
+	fstats->total_bytes_received_hi =3D
+	fstats->valid_bytes_received_hi =3D
 				le32_to_cpu(tclient->total_rcv_bytes.hi);
-	estats->total_bytes_received_lo =3D
-	estats->valid_bytes_received_lo =3D
+	fstats->total_bytes_received_lo =3D
+	fstats->valid_bytes_received_lo =3D
 				le32_to_cpu(tclient->total_rcv_bytes.lo);
-	ADD_64(estats->total_bytes_received_hi,
+	ADD_64(fstats->total_bytes_received_hi,
 	       le32_to_cpu(tclient->rcv_error_bytes.hi),
-	       estats->total_bytes_received_lo,
+	       fstats->total_bytes_received_lo,
 	       le32_to_cpu(tclient->rcv_error_bytes.lo));
=20
-	UPDATE_EXTEND_TSTAT(rcv_unicast_pkts,
-					total_unicast_packets_received_hi,
-					total_unicast_packets_received_lo);
+	UPDATE_EXTEND_TSTAT(rcv_unicast_pkts, total_unicast_packets_received)=
;
 	UPDATE_EXTEND_TSTAT(rcv_multicast_pkts,
-					total_multicast_packets_received_hi,
-					total_multicast_packets_received_lo);
+				total_multicast_packets_received);
 	UPDATE_EXTEND_TSTAT(rcv_broadcast_pkts,
-					total_broadcast_packets_received_hi,
-					total_broadcast_packets_received_lo);
-
-	estats->frames_received_64_bytes =3D MAC_STX_NA;
-	estats->frames_received_65_127_bytes =3D MAC_STX_NA;
-	estats->frames_received_128_255_bytes =3D MAC_STX_NA;
-	estats->frames_received_256_511_bytes =3D MAC_STX_NA;
-	estats->frames_received_512_1023_bytes =3D MAC_STX_NA;
-	estats->frames_received_1024_1522_bytes =3D MAC_STX_NA;
-	estats->frames_received_1523_9022_bytes =3D MAC_STX_NA;
-
-	estats->x_total_sent_bytes_hi =3D
-				le32_to_cpu(xstats->total_sent_bytes.hi);
-	estats->x_total_sent_bytes_lo =3D
-				le32_to_cpu(xstats->total_sent_bytes.lo);
-	estats->x_total_sent_pkts =3D le32_to_cpu(xstats->total_sent_pkts);
-
-	estats->t_rcv_unicast_bytes_hi =3D
+				total_broadcast_packets_received);
+
+	fstats->total_bytes_transmitted_hi =3D
+				le32_to_cpu(xclient->total_sent_bytes.hi);
+	fstats->total_bytes_transmitted_lo =3D
+				le32_to_cpu(xclient->total_sent_bytes.lo);
+
+	UPDATE_EXTEND_XSTAT(unicast_pkts_sent,
+				total_unicast_packets_transmitted);
+	UPDATE_EXTEND_XSTAT(multicast_pkts_sent,
+				total_multicast_packets_transmitted);
+	UPDATE_EXTEND_XSTAT(broadcast_pkts_sent,
+				total_broadcast_packets_transmitted);
+
+	memcpy(estats, &(fstats->total_bytes_received_hi),
+	       sizeof(struct host_func_stats) - 2*sizeof(u32));
+
+	estats->mac_filter_discard =3D le32_to_cpu(tport->mac_filter_discard)=
;
+	estats->xxoverflow_discard =3D le32_to_cpu(tport->xxoverflow_discard)=
;
+	estats->brb_truncate_discard =3D
+				le32_to_cpu(tport->brb_truncate_discard);
+	estats->mac_discard =3D le32_to_cpu(tport->mac_discard);
+
+	old_tclient->rcv_unicast_bytes.hi =3D
 				le32_to_cpu(tclient->rcv_unicast_bytes.hi);
-	estats->t_rcv_unicast_bytes_lo =3D
+	old_tclient->rcv_unicast_bytes.lo =3D
 				le32_to_cpu(tclient->rcv_unicast_bytes.lo);
-	estats->t_rcv_broadcast_bytes_hi =3D
+	old_tclient->rcv_broadcast_bytes.hi =3D
 				le32_to_cpu(tclient->rcv_broadcast_bytes.hi);
-	estats->t_rcv_broadcast_bytes_lo =3D
+	old_tclient->rcv_broadcast_bytes.lo =3D
 				le32_to_cpu(tclient->rcv_broadcast_bytes.lo);
-	estats->t_rcv_multicast_bytes_hi =3D
+	old_tclient->rcv_multicast_bytes.hi =3D
 				le32_to_cpu(tclient->rcv_multicast_bytes.hi);
-	estats->t_rcv_multicast_bytes_lo =3D
+	old_tclient->rcv_multicast_bytes.lo =3D
 				le32_to_cpu(tclient->rcv_multicast_bytes.lo);
-	estats->t_total_rcv_pkt =3D le32_to_cpu(tclient->total_rcv_pkts);
+	old_tclient->total_rcv_pkts =3D le32_to_cpu(tclient->total_rcv_pkts);
=20
-	estats->checksum_discard =3D le32_to_cpu(tclient->checksum_discard);
-	estats->packets_too_big_discard =3D
+	old_tclient->checksum_discard =3D le32_to_cpu(tclient->checksum_disca=
rd);
+	old_tclient->packets_too_big_discard =3D
 				le32_to_cpu(tclient->packets_too_big_discard);
-	estats->jabber_packets_received =3D estats->packets_too_big_discard +
-					  estats->stat_Dot3statsFramesTooLong;
-	estats->no_buff_discard =3D le32_to_cpu(tclient->no_buff_discard);
-	estats->ttl0_discard =3D le32_to_cpu(tclient->ttl0_discard);
-	estats->mac_discard =3D le32_to_cpu(tclient->mac_discard);
-	estats->mac_filter_discard =3D le32_to_cpu(tstats->mac_filter_discard=
);
-	estats->xxoverflow_discard =3D le32_to_cpu(tstats->xxoverflow_discard=
);
-	estats->brb_truncate_discard =3D
-				le32_to_cpu(tstats->brb_truncate_discard);
-
-	estats->brb_discard +=3D nstats->brb_discard - bp->old_brb_discard;
-	bp->old_brb_discard =3D nstats->brb_discard;
-
-	estats->brb_packet =3D nstats->brb_packet;
-	estats->brb_truncate =3D nstats->brb_truncate;
-	estats->flow_ctrl_discard =3D nstats->flow_ctrl_discard;
-	estats->flow_ctrl_octets =3D nstats->flow_ctrl_octets;
-	estats->flow_ctrl_packet =3D nstats->flow_ctrl_packet;
-	estats->mng_discard =3D nstats->mng_discard;
-	estats->mng_octet_inp =3D nstats->mng_octet_inp;
-	estats->mng_octet_out =3D nstats->mng_octet_out;
-	estats->mng_packet_inp =3D nstats->mng_packet_inp;
-	estats->mng_packet_out =3D nstats->mng_packet_out;
-	estats->pbf_octets =3D nstats->pbf_octets;
-	estats->pbf_packet =3D nstats->pbf_packet;
-	estats->safc_inp =3D nstats->safc_inp;
-
-	xstats->done.hi =3D 0;
-	tstats->done.hi =3D 0;
-	nstats->done =3D 0;
+	estats->no_buff_discard =3D
+	old_tclient->no_buff_discard =3D le32_to_cpu(tclient->no_buff_discard=
);
+	old_tclient->ttl0_discard =3D le32_to_cpu(tclient->ttl0_discard);
+
+	old_xclient->total_sent_pkts =3D le32_to_cpu(xclient->total_sent_pkts=
);
+	old_xclient->unicast_bytes_sent.hi =3D
+				le32_to_cpu(xclient->unicast_bytes_sent.hi);
+	old_xclient->unicast_bytes_sent.lo =3D
+				le32_to_cpu(xclient->unicast_bytes_sent.lo);
+	old_xclient->multicast_bytes_sent.hi =3D
+				le32_to_cpu(xclient->multicast_bytes_sent.hi);
+	old_xclient->multicast_bytes_sent.lo =3D
+				le32_to_cpu(xclient->multicast_bytes_sent.lo);
+	old_xclient->broadcast_bytes_sent.hi =3D
+				le32_to_cpu(xclient->broadcast_bytes_sent.hi);
+	old_xclient->broadcast_bytes_sent.lo =3D
+				le32_to_cpu(xclient->broadcast_bytes_sent.lo);
+
+	fstats->host_func_stats_start =3D ++fstats->host_func_stats_end;
=20
 	return 0;
 }
=20
-static void bnx2x_update_net_stats(struct bnx2x *bp)
+static void bnx2x_net_stats_update(struct bnx2x *bp)
 {
-	struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
+	struct tstorm_per_client_stats *old_tclient =3D &bp->old_tclient;
+	struct bnx2x_eth_stats *estats =3D &bp->eth_stats;
 	struct net_device_stats *nstats =3D &bp->dev->stats;
=20
 	nstats->rx_packets =3D
@@ -2929,24 +3175,31 @@ static void bnx2x_update_net_stats(struct bnx2x=
 *bp)
=20
 	nstats->tx_bytes =3D bnx2x_hilo(&estats->total_bytes_transmitted_hi);
=20
-	nstats->rx_dropped =3D estats->checksum_discard + estats->mac_discard=
;
+	nstats->rx_dropped =3D old_tclient->checksum_discard +
+			     estats->mac_discard;
 	nstats->tx_dropped =3D 0;
=20
 	nstats->multicast =3D
 		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi);
=20
-	nstats->collisions =3D estats->single_collision_transmit_frames +
-			     estats->multiple_collision_transmit_frames +
-			     estats->late_collision_frames +
-			     estats->excessive_collision_frames;
+	nstats->collisions =3D
+			estats->tx_stat_dot3statssinglecollisionframes_lo +
+			estats->tx_stat_dot3statsmultiplecollisionframes_lo +
+			estats->tx_stat_dot3statslatecollisions_lo +
+			estats->tx_stat_dot3statsexcessivecollisions_lo;
+
+	estats->jabber_packets_received =3D
+				old_tclient->packets_too_big_discard +
+				estats->rx_stat_dot3statsframestoolong_lo;
=20
-	nstats->rx_length_errors =3D estats->runt_packets_received +
-				   estats->jabber_packets_received;
-	nstats->rx_over_errors =3D estats->brb_discard +
+	nstats->rx_length_errors =3D
+				estats->rx_stat_etherstatsundersizepkts_lo +
+				estats->jabber_packets_received;
+	nstats->rx_over_errors =3D estats->brb_drop_lo +
 				 estats->brb_truncate_discard;
-	nstats->rx_crc_errors =3D estats->crc_receive_errors;
-	nstats->rx_frame_errors =3D estats->alignment_errors;
-	nstats->rx_fifo_errors =3D estats->no_buff_discard;
+	nstats->rx_crc_errors =3D estats->rx_stat_dot3statsfcserrors_lo;
+	nstats->rx_frame_errors =3D estats->rx_stat_dot3statsalignmenterrors_=
lo;
+	nstats->rx_fifo_errors =3D old_tclient->no_buff_discard;
 	nstats->rx_missed_errors =3D estats->xxoverflow_discard;
=20
 	nstats->rx_errors =3D nstats->rx_length_errors +
@@ -2956,39 +3209,48 @@ static void bnx2x_update_net_stats(struct bnx2x=
 *bp)
 			    nstats->rx_fifo_errors +
 			    nstats->rx_missed_errors;
=20
-	nstats->tx_aborted_errors =3D estats->late_collision_frames +
-				    estats->excessive_collision_frames;
-	nstats->tx_carrier_errors =3D estats->false_carrier_detections;
+	nstats->tx_aborted_errors =3D
+			estats->tx_stat_dot3statslatecollisions_lo +
+			estats->tx_stat_dot3statsexcessivecollisions_lo;
+	nstats->tx_carrier_errors =3D estats->rx_stat_falsecarriererrors_lo;
 	nstats->tx_fifo_errors =3D 0;
 	nstats->tx_heartbeat_errors =3D 0;
 	nstats->tx_window_errors =3D 0;
=20
 	nstats->tx_errors =3D nstats->tx_aborted_errors +
 			    nstats->tx_carrier_errors;
-
-	estats->mac_stx_start =3D ++estats->mac_stx_end;
 }
=20
-static void bnx2x_update_stats(struct bnx2x *bp)
+static void bnx2x_stats_update(struct bnx2x *bp)
 {
-	if (!bnx2x_update_storm_stats(bp)) {
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
+	int update =3D 0;
=20
-		if (bp->link_vars.mac_type =3D=3D MAC_TYPE_BMAC) {
-			bnx2x_update_bmac_stats(bp);
+	if (*stats_comp !=3D DMAE_COMP_VAL)
+		return;
=20
-		} else if (bp->link_vars.mac_type =3D=3D MAC_TYPE_EMAC) {
-			bnx2x_update_emac_stats(bp);
+	if (bp->port.pmf)
+		update =3D (bnx2x_hw_stats_update(bp) =3D=3D 0);
=20
-		} else { /* unreached */
-			BNX2X_ERR("no MAC active\n");
-			return;
-		}
+	update |=3D (bnx2x_storm_stats_update(bp) =3D=3D 0);
+
+	if (update)
+		bnx2x_net_stats_update(bp);
=20
-		bnx2x_update_net_stats(bp);
+	else {
+		if (bp->stats_pending) {
+			bp->stats_pending++;
+			if (bp->stats_pending =3D=3D 3) {
+				BNX2X_ERR("stats not updated for 3 times\n");
+				bnx2x_panic();
+				return;
+			}
+		}
 	}
=20
 	if (bp->msglevel & NETIF_MSG_TIMER) {
-		struct bnx2x_eth_stats *estats =3D bnx2x_sp(bp, eth_stats);
+		struct tstorm_per_client_stats *old_tclient =3D &bp->old_tclient;
+		struct bnx2x_eth_stats *estats =3D &bp->eth_stats;
 		struct net_device_stats *nstats =3D &bp->dev->stats;
 		int i;
=20
@@ -3003,17 +3265,18 @@ static void bnx2x_update_stats(struct bnx2x *bp=
)
 		       *bp->fp->rx_cons_sb, nstats->rx_packets);
 		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u\n",
 		       netif_queue_stopped(bp->dev)? "Xoff" : "Xon",
-		       estats->driver_xoff, estats->brb_discard);
+		       estats->driver_xoff, estats->brb_drop_lo);
 		printk(KERN_DEBUG "tstats: checksum_discard %u  "
 			"packets_too_big_discard %u  no_buff_discard %u  "
 			"mac_discard %u  mac_filter_discard %u  "
 			"xxovrflow_discard %u  brb_truncate_discard %u  "
 			"ttl0_discard %u\n",
-		       estats->checksum_discard,
-		       estats->packets_too_big_discard,
-		       estats->no_buff_discard, estats->mac_discard,
+		       old_tclient->checksum_discard,
+		       old_tclient->packets_too_big_discard,
+		       old_tclient->no_buff_discard, estats->mac_discard,
 		       estats->mac_filter_discard, estats->xxoverflow_discard,
-		       estats->brb_truncate_discard, estats->ttl0_discard);
+		       estats->brb_truncate_discard,
+		       old_tclient->ttl0_discard);
=20
 		for_each_queue(bp, i) {
 			printk(KERN_DEBUG "[%d]: %lu\t%lu\t%lu\n", i,
@@ -3023,60 +3286,131 @@ static void bnx2x_update_stats(struct bnx2x *b=
p)
 		}
 	}
=20
-	if (bp->state !=3D BNX2X_STATE_OPEN) {
-		DP(BNX2X_MSG_STATS, "state is %x, returning\n", bp->state);
-		return;
-	}
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return;
-#endif
+	bnx2x_hw_stats_post(bp);
+	bnx2x_storm_stats_post(bp);
+}
=20
-	/* loader */
-	if (bp->executer_idx) {
-		struct dmae_command *dmae =3D &bp->dmae;
-		int port =3D BP_PORT(bp);
-		int loader_idx =3D port * 8;
+static void bnx2x_port_stats_stop(struct bnx2x *bp)
+{
+	struct dmae_command *dmae;
+	u32 opcode;
+	int loader_idx =3D PMF_DMAE_C(bp);
+	u32 *stats_comp =3D bnx2x_sp(bp, stats_comp);
=20
-		memset(dmae, 0, sizeof(struct dmae_command));
+	bp->executer_idx =3D 0;
=20
-		dmae->opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-				DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE |
-				DMAE_CMD_DST_RESET |
+	opcode =3D (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+		  DMAE_CMD_C_ENABLE |
+		  DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
 #ifdef __BIG_ENDIAN
-				DMAE_CMD_ENDIANITY_B_DW_SWAP |
+		  DMAE_CMD_ENDIANITY_B_DW_SWAP |
 #else
-				DMAE_CMD_ENDIANITY_DW_SWAP |
+		  DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-				(port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
-		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, dmae[0]));
-		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, dmae[0]));
-		dmae->dst_addr_lo =3D (DMAE_REG_CMD_MEM +
-				     sizeof(struct dmae_command) *
-				     (loader_idx + 1)) >> 2;
+		  (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		  (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+
+	if (bp->port.port_stx) {
+
+		dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
+		if (bp->func_stx)
+			dmae->opcode =3D (opcode | DMAE_CMD_C_DST_GRC);
+		else
+			dmae->opcode =3D (opcode | DMAE_CMD_C_DST_PCI);
+		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, port_stats));
+		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, port_stats));
+		dmae->dst_addr_lo =3D bp->port.port_stx >> 2;
 		dmae->dst_addr_hi =3D 0;
-		dmae->len =3D sizeof(struct dmae_command) >> 2;
-		dmae->len--;    /* !!! for A0/1 only */
-		dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx + 1] >> 2;
-		dmae->comp_addr_hi =3D 0;
-		dmae->comp_val =3D 1;
+		dmae->len =3D sizeof(struct host_port_stats) >> 2;
+		if (bp->func_stx) {
+			dmae->comp_addr_lo =3D dmae_reg_go_c[loader_idx] >> 2;
+			dmae->comp_addr_hi =3D 0;
+			dmae->comp_val =3D 1;
+		} else {
+			dmae->comp_addr_lo =3D
+				U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+			dmae->comp_addr_hi =3D
+				U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+			dmae->comp_val =3D DMAE_COMP_VAL;
=20
-		bnx2x_post_dmae(bp, dmae, loader_idx);
+			*stats_comp =3D 0;
+		}
 	}
=20
-	if (bp->stats_state !=3D STATS_STATE_ENABLE) {
-		bp->stats_state =3D STATS_STATE_DISABLE;
-		return;
+	if (bp->func_stx) {
+
+		dmae =3D bnx2x_sp(bp, dmae[bp->executer_idx++]);
+		dmae->opcode =3D (opcode | DMAE_CMD_C_DST_PCI);
+		dmae->src_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, func_stats));
+		dmae->src_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, func_stats));
+		dmae->dst_addr_lo =3D bp->func_stx >> 2;
+		dmae->dst_addr_hi =3D 0;
+		dmae->len =3D sizeof(struct host_func_stats) >> 2;
+		dmae->comp_addr_lo =3D U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+		dmae->comp_addr_hi =3D U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+		dmae->comp_val =3D DMAE_COMP_VAL;
+
+		*stats_comp =3D 0;
 	}
+}
+
+static void bnx2x_stats_stop(struct bnx2x *bp)
+{
+	int update =3D 0;
+
+	bnx2x_stats_comp(bp);
+
+	if (bp->port.pmf)
+		update =3D (bnx2x_hw_stats_update(bp) =3D=3D 0);
+
+	update |=3D (bnx2x_storm_stats_update(bp) =3D=3D 0);
+
+	if (update) {
+		bnx2x_net_stats_update(bp);
+
+		if (bp->port.pmf)
+			bnx2x_port_stats_stop(bp);
=20
-	if (bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0, 0, 0, 0) =3D=3D=
 0) {
-		/* stats ramrod has it's own slot on the spe */
-		bp->spq_left++;
-		bp->stat_pending =3D 1;
+		bnx2x_hw_stats_post(bp);
+		bnx2x_stats_comp(bp);
 	}
 }
=20
+static void bnx2x_stats_do_nothing(struct bnx2x *bp)
+{
+}
+
+static const struct {
+	void (*action)(struct bnx2x *bp);
+	enum bnx2x_stats_state next_state;
+} bnx2x_stats_stm[STATS_STATE_MAX][STATS_EVENT_MAX] =3D {
+/* state	event	*/
+{
+/* DISABLED	PMF	*/ {bnx2x_stats_pmf_update, STATS_STATE_DISABLED},
+/*		LINK_UP	*/ {bnx2x_stats_start,      STATS_STATE_ENABLED},
+/*		UPDATE	*/ {bnx2x_stats_do_nothing, STATS_STATE_DISABLED},
+/*		STOP	*/ {bnx2x_stats_do_nothing, STATS_STATE_DISABLED}
+},
+{
+/* ENABLED	PMF	*/ {bnx2x_stats_pmf_start,  STATS_STATE_ENABLED},
+/*		LINK_UP	*/ {bnx2x_stats_restart,    STATS_STATE_ENABLED},
+/*		UPDATE	*/ {bnx2x_stats_update,     STATS_STATE_ENABLED},
+/*		STOP	*/ {bnx2x_stats_stop,       STATS_STATE_DISABLED}
+}
+};
+
+static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_even=
t event)
+{
+	enum bnx2x_stats_state state =3D bp->stats_state;
+
+	bnx2x_stats_stm[state][event].action(bp);
+	bp->stats_state =3D bnx2x_stats_stm[state][event].next_state;
+
+	if ((event !=3D STATS_EVENT_UPDATE) || (bp->msglevel & NETIF_MSG_TIME=
R))
+		DP(BNX2X_MSG_STATS, "state %d -> event %d -> state %d\n",
+		   state, event, bp->stats_state);
+}
+
 static void bnx2x_timer(unsigned long data)
 {
 	struct bnx2x *bp =3D (struct bnx2x *) data;
@@ -3119,10 +3453,9 @@ static void bnx2x_timer(unsigned long data)
 		}
 	}
=20
-	if (bp->stats_state =3D=3D STATS_STATE_DISABLE)
-		goto timer_restart;
-
-	bnx2x_update_stats(bp);
+	if ((bp->state =3D=3D BNX2X_STATE_OPEN) ||
+	    (bp->state =3D=3D BNX2X_STATE_DISABLED))
+		bnx2x_stats_handle(bp, STATS_EVENT_UPDATE);
=20
 timer_restart:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
@@ -3152,6 +3485,7 @@ static void bnx2x_init_sb(struct bnx2x *bp, int s=
b_id,
 			  struct host_status_block *sb,	dma_addr_t mapping)
 {
 	int port =3D BP_PORT(bp);
+	int func =3D BP_FUNC(bp);
 	int index;
 	u64 section;
=20
@@ -3165,6 +3499,8 @@ static void bnx2x_init_sb(struct bnx2x *bp, int s=
b_id,
 	REG_WR(bp, BAR_USTRORM_INTMEM +
 	       ((USTORM_SB_HOST_SB_ADDR_OFFSET(port, sb_id)) + 4),
 	       U64_HI(section));
+	REG_WR8(bp, BAR_USTRORM_INTMEM + FP_USB_FUNC_OFF +
+		USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, sb_id), func);
=20
 	for (index =3D 0; index < HC_USTORM_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
@@ -3336,6 +3672,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 		REG_WR16(bp, BAR_XSTRORM_INTMEM +
 			 XSTORM_DEF_SB_HC_DISABLE_OFFSET(func, index), 1);
=20
+	bp->stats_pending =3D 0;
+
 	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
=20
@@ -3729,7 +4067,7 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	bnx2x_init_sp_ring(bp);
 	bnx2x_init_context(bp);
 	bnx2x_init_internal(bp);
-	bnx2x_init_stats(bp);
+	bnx2x_storm_stats_init(bp);
 	bnx2x_init_ind_table(bp);
 	bnx2x_int_enable(bp);
 }
@@ -5302,6 +5640,8 @@ static int bnx2x_nic_load(struct bnx2x *bp, int l=
oad_mode)
 		}
 	}
=20
+	bnx2x_stats_init(bp);
+
 	bp->state =3D BNX2X_STATE_OPENING_WAIT4_PORT;
=20
 	/* Enable Rx interrupt handling before sending the ramrod
@@ -5549,6 +5889,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int=
 unload_mode)
 	del_timer_sync(&bp->timer);
 	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
+	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
=20
 	/* Wait until all fast path tasks complete */
 	for_each_queue(bp, i) {
@@ -6572,7 +6913,7 @@ static int bnx2x_set_settings(struct net_device *=
dev, struct ethtool_cmd *cmd)
 	   bp->port.advertising);
=20
 	if (netif_running(dev)) {
-		bnx2x_stop_stats(bp);
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 		bnx2x_link_set(bp);
 	}
=20
@@ -6669,7 +7010,7 @@ static int bnx2x_nway_reset(struct net_device *de=
v)
 		return 0;
=20
 	if (netif_running(dev)) {
-		bnx2x_stop_stats(bp);
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 		bnx2x_link_set(bp);
 	}
=20
@@ -7059,10 +7400,13 @@ static int bnx2x_set_eeprom(struct net_device *=
dev,
 					     bp->link_params.ext_phy_config,
 					     (bp->state !=3D BNX2X_STATE_CLOSED),
 					     eebuf, eeprom->len);
+			if ((bp->state =3D=3D BNX2X_STATE_OPEN) ||
+			    (bp->state =3D=3D BNX2X_STATE_DISABLED)) {
 				rc |=3D bnx2x_link_reset(&bp->link_params,
 						       &bp->link_vars);
 				rc |=3D bnx2x_phy_init(&bp->link_params,
 						     &bp->link_vars);
+			}
 			bnx2x_phy_hw_unlock(bp);
=20
 		} else /* Only the PMF can access the PHY */
@@ -7204,7 +7548,7 @@ static int bnx2x_set_pauseparam(struct net_device=
 *dev,
 	   bp->link_params.req_flow_ctrl);
=20
 	if (netif_running(dev)) {
-		bnx2x_stop_stats(bp);
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 		bnx2x_link_set(bp);
 	}
=20
@@ -7260,7 +7604,6 @@ static void bnx2x_self_test(struct net_device *de=
v,
 	}
=20
 	stats_state =3D bp->stats_state;
-	bnx2x_stop_stats(bp);
=20
 	if (bnx2x_mc_assert(bp) !=3D 0) {
 		buf[0] =3D 1;
@@ -7270,46 +7613,52 @@ static void bnx2x_self_test(struct net_device *=
dev,
 #ifdef BNX2X_EXTRA_DEBUG
 	bnx2x_panic_dump(bp);
 #endif
-	bp->stats_state =3D stats_state;
 }
=20
-static struct {
+static const struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_stats_str_arr[BNX2X_NUM_STATS] =3D {
-	{ "rx_bytes"},
-	{ "rx_error_bytes"},
-	{ "tx_bytes"},
-	{ "tx_error_bytes"},
-	{ "rx_ucast_packets"},
-	{ "rx_mcast_packets"},
-	{ "rx_bcast_packets"},
-	{ "tx_ucast_packets"},
-	{ "tx_mcast_packets"},
-	{ "tx_bcast_packets"},
-	{ "tx_mac_errors"},	/* 10 */
-	{ "tx_carrier_errors"},
-	{ "rx_crc_errors"},
-	{ "rx_align_errors"},
-	{ "tx_single_collisions"},
-	{ "tx_multi_collisions"},
-	{ "tx_deferred"},
-	{ "tx_excess_collisions"},
-	{ "tx_late_collisions"},
-	{ "tx_total_collisions"},
-	{ "rx_fragments"},	/* 20 */
-	{ "rx_jabbers"},
-	{ "rx_undersize_packets"},
-	{ "rx_oversize_packets"},
-	{ "rx_xon_frames"},
-	{ "rx_xoff_frames"},
-	{ "tx_xon_frames"},
-	{ "tx_xoff_frames"},
-	{ "rx_mac_ctrl_frames"},
-	{ "rx_filtered_packets"},
-	{ "rx_discards"},	/* 30 */
-	{ "brb_discard"},
-	{ "brb_truncate"},
-	{ "xxoverflow"}
+	{ "rx_bytes" },
+	{ "rx_error_bytes" },
+	{ "tx_bytes" },
+	{ "tx_error_bytes" },
+	{ "rx_ucast_packets" },
+	{ "rx_mcast_packets" },
+	{ "rx_bcast_packets" },
+	{ "tx_ucast_packets" },
+	{ "tx_mcast_packets" },
+	{ "tx_bcast_packets" },			/* 10 */
+	{ "tx_mac_errors" },
+	{ "tx_carrier_errors" },
+	{ "rx_crc_errors" },
+	{ "rx_align_errors" },
+	{ "tx_single_collisions" },
+	{ "tx_multi_collisions" },
+	{ "tx_deferred" },
+	{ "tx_excess_collisions" },
+	{ "tx_late_collisions" },
+	{ "tx_total_collisions" },		/* 20 */
+	{ "rx_fragments" },
+	{ "rx_jabbers" },
+	{ "rx_undersize_packets" },
+	{ "rx_oversize_packets" },
+	{ "tx_64_byte_packets" },
+	{ "tx_65_to_127_byte_packets" },
+	{ "tx_128_to_255_byte_packets" },
+	{ "tx_256_to_511_byte_packets" },
+	{ "tx_512_to_1023_byte_packets" },
+	{ "tx_1024_to_1522_byte_packets" },	/* 30 */
+	{ "tx_1523_to_9022_byte_packets" },
+	{ "rx_xon_frames" },
+	{ "rx_xoff_frames" },
+	{ "tx_xon_frames" },
+	{ "tx_xoff_frames" },
+	{ "rx_mac_ctrl_frames" },
+	{ "rx_filtered_packets" },
+	{ "rx_discards" },
+	{ "rx_fw_discards" },
+	{ "brb_discard" },			/* 40 */
+	{ "brb_truncate" }
 };
=20
 #define STATS_OFFSET32(offset_name) \
@@ -7317,46 +7666,54 @@ static struct {
=20
 static unsigned long bnx2x_stats_offset_arr[BNX2X_NUM_STATS] =3D {
 	STATS_OFFSET32(total_bytes_received_hi),
-	STATS_OFFSET32(stat_IfHCInBadOctets_hi),
+	STATS_OFFSET32(rx_stat_ifhcinbadoctets_hi),
 	STATS_OFFSET32(total_bytes_transmitted_hi),
-	STATS_OFFSET32(stat_IfHCOutBadOctets_hi),
+	STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
 	STATS_OFFSET32(total_unicast_packets_received_hi),
 	STATS_OFFSET32(total_multicast_packets_received_hi),
 	STATS_OFFSET32(total_broadcast_packets_received_hi),
 	STATS_OFFSET32(total_unicast_packets_transmitted_hi),
 	STATS_OFFSET32(total_multicast_packets_transmitted_hi),
-	STATS_OFFSET32(total_broadcast_packets_transmitted_hi),
-	STATS_OFFSET32(stat_Dot3statsInternalMacTransmitErrors), /* 10 */
-	STATS_OFFSET32(stat_Dot3StatsCarrierSenseErrors),
-	STATS_OFFSET32(crc_receive_errors),
-	STATS_OFFSET32(alignment_errors),
-	STATS_OFFSET32(single_collision_transmit_frames),
-	STATS_OFFSET32(multiple_collision_transmit_frames),
-	STATS_OFFSET32(stat_Dot3StatsDeferredTransmissions),
-	STATS_OFFSET32(excessive_collision_frames),
-	STATS_OFFSET32(late_collision_frames),
-	STATS_OFFSET32(number_of_bugs_found_in_stats_spec),
-	STATS_OFFSET32(runt_packets_received),			/* 20 */
+	STATS_OFFSET32(total_broadcast_packets_transmitted_hi),	/* 10 */
+	STATS_OFFSET32(tx_stat_dot3statsinternalmactransmiterrors_hi),
+	STATS_OFFSET32(rx_stat_dot3statscarriersenseerrors_hi),
+	STATS_OFFSET32(rx_stat_dot3statsfcserrors_hi),
+	STATS_OFFSET32(rx_stat_dot3statsalignmenterrors_hi),
+	STATS_OFFSET32(tx_stat_dot3statssinglecollisionframes_hi),
+	STATS_OFFSET32(tx_stat_dot3statsmultiplecollisionframes_hi),
+	STATS_OFFSET32(tx_stat_dot3statsdeferredtransmissions_hi),
+	STATS_OFFSET32(tx_stat_dot3statsexcessivecollisions_hi),
+	STATS_OFFSET32(tx_stat_dot3statslatecollisions_hi),
+	STATS_OFFSET32(tx_stat_etherstatscollisions_hi),	/* 20 */
+	STATS_OFFSET32(rx_stat_etherstatsfragments_hi),
+	STATS_OFFSET32(rx_stat_etherstatsjabbers_hi),
+	STATS_OFFSET32(rx_stat_etherstatsundersizepkts_hi),
 	STATS_OFFSET32(jabber_packets_received),
-	STATS_OFFSET32(error_runt_packets_received),
-	STATS_OFFSET32(error_jabber_packets_received),
-	STATS_OFFSET32(pause_xon_frames_received),
-	STATS_OFFSET32(pause_xoff_frames_received),
-	STATS_OFFSET32(pause_xon_frames_transmitted),
-	STATS_OFFSET32(pause_xoff_frames_transmitted),
-	STATS_OFFSET32(control_frames_received),
+	STATS_OFFSET32(tx_stat_etherstatspkts64octets_hi),
+	STATS_OFFSET32(tx_stat_etherstatspkts65octetsto127octets_hi),
+	STATS_OFFSET32(tx_stat_etherstatspkts128octetsto255octets_hi),
+	STATS_OFFSET32(tx_stat_etherstatspkts256octetsto511octets_hi),
+	STATS_OFFSET32(tx_stat_etherstatspkts512octetsto1023octets_hi),
+	STATS_OFFSET32(tx_stat_etherstatspkts1024octetsto1522octets_hi),/*30*=
/
+	STATS_OFFSET32(etherstatspktsover1522octets_hi),
+	STATS_OFFSET32(rx_stat_xonpauseframesreceived_hi),
+	STATS_OFFSET32(rx_stat_xoffpauseframesreceived_hi),
+	STATS_OFFSET32(tx_stat_outxonsent_hi),
+	STATS_OFFSET32(tx_stat_outxoffsent_hi),
+	STATS_OFFSET32(rx_stat_maccontrolframesreceived_hi),
 	STATS_OFFSET32(mac_filter_discard),
-	STATS_OFFSET32(no_buff_discard),			/* 30 */
-	STATS_OFFSET32(brb_discard),
-	STATS_OFFSET32(brb_truncate_discard),
-	STATS_OFFSET32(xxoverflow_discard)
+	STATS_OFFSET32(no_buff_discard),
+	STATS_OFFSET32(xxoverflow_discard),
+	STATS_OFFSET32(brb_drop_hi),				/* 40 */
+	STATS_OFFSET32(brb_truncate_discard)
 };
=20
 static u8 bnx2x_stats_len_arr[BNX2X_NUM_STATS] =3D {
-	8, 0, 8, 0, 8, 8, 8, 8, 8, 8,
-	4, 0, 4, 4, 4, 4, 4, 4, 4, 4,
-	4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
-	4, 4, 4, 4
+	8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
+	8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
+	8, 8, 8, 4, 8, 8, 8, 8, 8, 8,
+	8, 8, 8, 8, 8, 8, 4, 4, 4, 8,
+	4
 };
=20
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u=
8 *buf)
@@ -7381,7 +7738,7 @@ static void bnx2x_get_ethtool_stats(struct net_de=
vice *dev,
 				    struct ethtool_stats *stats, u64 *buf)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
-	u32 *hw_stats =3D (u32 *)bnx2x_sp_check(bp, eth_stats);
+	u32 *hw_stats =3D (u32 *)&bp->eth_stats;
 	int i;
=20
 	for (i =3D 0; i < BNX2X_NUM_STATS; i++) {
@@ -7476,7 +7833,7 @@ static struct ethtool_ops bnx2x_ethtool_ops =3D {
 	.get_strings    	=3D bnx2x_get_strings,
 	.phys_id		=3D bnx2x_phys_id,
 	.get_stats_count	=3D bnx2x_get_stats_count,
-	.get_ethtool_stats      =3D bnx2x_get_ethtool_stats
+	.get_ethtool_stats	=3D bnx2x_get_ethtool_stats,
 };
=20
 /* end of ethtool_ops */
@@ -7594,7 +7951,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 	fp =3D &bp->fp[fp_index];
 	if (unlikely(bnx2x_tx_avail(bp->fp) <
 					(skb_shinfo(skb)->nr_frags + 3))) {
-		bp->slowpath->eth_stats.driver_xoff++,
+		bp->eth_stats.driver_xoff++,
 		netif_stop_queue(dev);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -7826,7 +8183,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
=20
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
 		netif_stop_queue(dev);
-		bp->slowpath->eth_stats.driver_xoff++;
+		bp->eth_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >=3D MAX_SKB_FRAGS + 3)
 			netif_wake_queue(dev);
 	}
@@ -8155,6 +8512,7 @@ static int __devinit bnx2x_init_dev(struct pci_de=
v *pdev,
 		}
=20
 		pci_set_master(pdev);
+		pci_save_state(pdev);
 	}
=20
 	bp->pm_cap =3D pci_find_capability(pdev, PCI_CAP_ID_PM);
--=20
1.5.5




