From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH] acxsm: Reduce the number of ACX_PACKED instructions
Date: Sat, 25 Mar 2006 21:01:16 +0100
Message-ID: <11433168763687-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net, Carlos Martin <carlos@cmartin.tk>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: 
To: netdev@vger.kernel.org
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Up to now, we were using ACX_PACKED after every field. I've finally
found out how to use only one at the end of each struct whilst
maintaining the typedef where it is now.

This should also apply to acx with a bit of fuzz, but I consider it to
be in maintenance mode, so this doesn't qualify for it.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

---

 acx_struct.h |  874 +++++++++++++++++++++++++++++-----------------------=
------
 common.c     |   26 +-
 ioctl.c      |   10 -
 usb.c        |    8 -
 4 files changed, 457 insertions(+), 461 deletions(-)

5fb2fdfd8c028a40921bbf9ef7ec4c53c03fcab4
diff --git a/acx_struct.h b/acx_struct.h
index 227b6e3..8c92302 100644
--- a/acx_struct.h
+++ b/acx_struct.h
@@ -522,9 +522,9 @@ DEF_IE(111_IE_DOT11_INVAL_1013,			0x1013
  * --vda
  */
 typedef struct phy_hdr {
-	u8	unknown[4] ACX_PACKED;
-	u8	acx111_unknown[4] ACX_PACKED;
-} phy_hdr_t;
+	u8	unknown[4];
+	u8	acx111_unknown[4];
+} ACX_PACKED phy_hdr_t;
=20
 /* seems to be a bit similar to hfa384x_rx_frame.
  * These fields are still not quite obvious, though.
@@ -584,22 +584,22 @@ time: 4 bytes:
 */
=20
 typedef struct rxbuffer {
-	u16	mac_cnt_rcvd ACX_PACKED;	/* only 12 bits are len! (0xfff) */
-	u8	mac_cnt_mblks ACX_PACKED;
-	u8	mac_status ACX_PACKED;
-	u8	phy_stat_baseband ACX_PACKED;	/* bit 0x80: used LNA (Low-Noise Ampli=
fier) */
-	u8	phy_plcp_signal ACX_PACKED;
-	u8	phy_level ACX_PACKED;		/* PHY stat */
-	u8	phy_snr ACX_PACKED;		/* PHY stat */
-	u32	time ACX_PACKED;		/* timestamp upon MAC rcv first byte */
+	u16	mac_cnt_rcvd;	/* only 12 bits are len! (0xfff) */
+	u8	mac_cnt_mblks;
+	u8	mac_status;
+	u8	phy_stat_baseband;	/* bit 0x80: used LNA (Low-Noise Amplifier) */
+	u8	phy_plcp_signal;
+	u8	phy_level;		/* PHY stat */
+	u8	phy_snr;		/* PHY stat */
+	u32	time;		/* timestamp upon MAC rcv first byte */
 /* 4-byte (acx100) or 8-byte (acx111) phy header will be here
 ** if RX_CFG1_INCLUDE_PHY_HDR is in effect:
 **	phy_hdr_t phy			*/
-	wlan_hdr_a3_t hdr_a3 ACX_PACKED;
+	wlan_hdr_a3_t hdr_a3;
 	/* maximally sized data part of wlan packet */
-	u8	data_a3[WLAN_A4FR_MAXLEN_WEP_FCS - WLAN_HDR_A3_LEN] ACX_PACKED;
+	u8	data_a3[WLAN_A4FR_MAXLEN_WEP_FCS - WLAN_HDR_A3_LEN];
 	/* can add hdr/data_a4 if needed */
-} rxbuffer_t;
+} ACX_PACKED rxbuffer_t;
=20
=20
 /*--- Firmware statistics ----------------------------------------------=
------*/
@@ -609,93 +609,93 @@ typedef struct rxbuffer {
 #define FW_STATS_FUTURE_EXTENSION	100
=20
 typedef struct fw_stats_tx {
-	u32	tx_desc_of ACX_PACKED;
-} fw_stats_tx_t;
+	u32	tx_desc_of;
+} ACX_PACKED fw_stats_tx_t;
=20
 typedef struct fw_stats_rx {
-	u32	rx_oom ACX_PACKED;
-	u32	rx_hdr_of ACX_PACKED;
-	u32	rx_hw_stuck ACX_PACKED; /* old: u32	rx_hdr_use_next */
-	u32	rx_dropped_frame ACX_PACKED;
-	u32	rx_frame_ptr_err ACX_PACKED;
-	u32	rx_xfr_hint_trig ACX_PACKED;
-	u32	rx_aci_events ACX_PACKED; /* later versions only */
-	u32	rx_aci_resets ACX_PACKED; /* later versions only */
-} fw_stats_rx_t;
+	u32	rx_oom;
+	u32	rx_hdr_of;
+	u32	rx_hw_stuck; /* old: u32	rx_hdr_use_next */
+	u32	rx_dropped_frame;
+	u32	rx_frame_ptr_err;
+	u32	rx_xfr_hint_trig;
+	u32	rx_aci_events; /* later versions only */
+	u32	rx_aci_resets; /* later versions only */
+} ACX_PACKED fw_stats_rx_t;
=20
 typedef struct fw_stats_dma {
-	u32	rx_dma_req ACX_PACKED;
-	u32	rx_dma_err ACX_PACKED;
-	u32	tx_dma_req ACX_PACKED;
-	u32	tx_dma_err ACX_PACKED;
-} fw_stats_dma_t;
+	u32	rx_dma_req;
+	u32	rx_dma_err;
+	u32	tx_dma_req;
+	u32	tx_dma_err;
+} ACX_PACKED fw_stats_dma_t;
=20
 typedef struct fw_stats_irq {
-	u32	cmd_cplt ACX_PACKED;
-	u32	fiq ACX_PACKED;
-	u32	rx_hdrs ACX_PACKED;
-	u32	rx_cmplt ACX_PACKED;
-	u32	rx_mem_of ACX_PACKED;
-	u32	rx_rdys ACX_PACKED;
-	u32	irqs ACX_PACKED;
-	u32	tx_procs ACX_PACKED;
-	u32	decrypt_done ACX_PACKED;
-	u32	dma_0_done ACX_PACKED;
-	u32	dma_1_done ACX_PACKED;
-	u32	tx_exch_complet ACX_PACKED;
-	u32	commands ACX_PACKED;
-	u32	rx_procs ACX_PACKED;
-	u32	hw_pm_mode_changes ACX_PACKED;
-	u32	host_acks ACX_PACKED;
-	u32	pci_pm ACX_PACKED;
-	u32	acm_wakeups ACX_PACKED;
-} fw_stats_irq_t;
+	u32	cmd_cplt;
+	u32	fiq;
+	u32	rx_hdrs;
+	u32	rx_cmplt;
+	u32	rx_mem_of;
+	u32	rx_rdys;
+	u32	irqs;
+	u32	tx_procs;
+	u32	decrypt_done;
+	u32	dma_0_done;
+	u32	dma_1_done;
+	u32	tx_exch_complet;
+	u32	commands;
+	u32	rx_procs;
+	u32	hw_pm_mode_changes;
+	u32	host_acks;
+	u32	pci_pm;
+	u32	acm_wakeups;
+} ACX_PACKED fw_stats_irq_t;
=20
 typedef struct fw_stats_wep {
-	u32	wep_key_count ACX_PACKED;
-	u32	wep_default_key_count ACX_PACKED;
-	u32	dot11_def_key_mib ACX_PACKED;
-	u32	wep_key_not_found ACX_PACKED;
-	u32	wep_decrypt_fail ACX_PACKED;
-	u32	wep_pkt_decrypt ACX_PACKED;
-	u32	wep_decrypt_irqs ACX_PACKED;
-} fw_stats_wep_t;
+	u32	wep_key_count;
+	u32	wep_default_key_count;
+	u32	dot11_def_key_mib;
+	u32	wep_key_not_found;
+	u32	wep_decrypt_fail;
+	u32	wep_pkt_decrypt;
+	u32	wep_decrypt_irqs;
+} ACX_PACKED fw_stats_wep_t;
=20
 typedef struct fw_stats_pwr {
-	u32	tx_start_ctr ACX_PACKED;
-	u32	no_ps_tx_too_short ACX_PACKED;
-	u32	rx_start_ctr ACX_PACKED;
-	u32	no_ps_rx_too_short ACX_PACKED;
-	u32	lppd_started ACX_PACKED;
-	u32	no_lppd_too_noisy ACX_PACKED;
-	u32	no_lppd_too_short ACX_PACKED;
-	u32	no_lppd_matching_frame ACX_PACKED;
-} fw_stats_pwr_t;
+	u32	tx_start_ctr;
+	u32	no_ps_tx_too_short;
+	u32	rx_start_ctr;
+	u32	no_ps_rx_too_short;
+	u32	lppd_started;
+	u32	no_lppd_too_noisy;
+	u32	no_lppd_too_short;
+	u32	no_lppd_matching_frame;
+} ACX_PACKED fw_stats_pwr_t;
=20
 typedef struct fw_stats_mic {
-	u32 mic_rx_pkts ACX_PACKED;
-	u32 mic_calc_fail ACX_PACKED;
-} fw_stats_mic_t;
+	u32 mic_rx_pkts;
+	u32 mic_calc_fail;
+} ACX_PACKED fw_stats_mic_t;
=20
 typedef struct fw_stats_aes {
-	u32 aes_enc_fail ACX_PACKED;
-	u32 aes_dec_fail ACX_PACKED;
-	u32 aes_enc_pkts ACX_PACKED;
-	u32 aes_dec_pkts ACX_PACKED;
-	u32 aes_enc_irq ACX_PACKED;
-	u32 aes_dec_irq ACX_PACKED;
-} fw_stats_aes_t;
+	u32 aes_enc_fail;
+	u32 aes_dec_fail;
+	u32 aes_enc_pkts;
+	u32 aes_dec_pkts;
+	u32 aes_enc_irq;
+	u32 aes_dec_irq;
+} ACX_PACKED fw_stats_aes_t;
=20
 typedef struct fw_stats_event {
-	u32 heartbeat ACX_PACKED;
-	u32 calibration ACX_PACKED;
-	u32 rx_mismatch ACX_PACKED;
-	u32 rx_mem_empty ACX_PACKED;
-	u32 rx_pool ACX_PACKED;
-	u32 oom_late ACX_PACKED;
-	u32 phy_tx_err ACX_PACKED;
-	u32 tx_stuck ACX_PACKED;
-} fw_stats_event_t;
+	u32 heartbeat;
+	u32 calibration;
+	u32 rx_mismatch;
+	u32 rx_mem_empty;
+	u32 rx_pool;
+	u32 oom_late;
+	u32 phy_tx_err;
+	u32 tx_stuck;
+} ACX_PACKED fw_stats_event_t;
=20
 /* mainly for size calculation only */
 typedef struct fw_stats {
@@ -716,11 +716,11 @@ typedef struct fw_stats {
 /* Firmware version struct */
=20
 typedef struct fw_ver {
-	u16	cmd ACX_PACKED;
-	u16	size ACX_PACKED;
-	char	fw_id[20] ACX_PACKED;
-	u32	hw_id ACX_PACKED;
-} fw_ver_t;
+	u16	cmd;
+	u16	size;
+	char	fw_id[20];
+	u32	hw_id;
+} ACX_PACKED fw_ver_t;
=20
 #define FW_ID_SIZE 20
=20
@@ -789,8 +789,8 @@ struct client {
  * Attempts to use acx_ptr without macros result in compile-time errors =
*/
=20
 typedef struct {
-	u32	v ACX_PACKED;
-} acx_ptr;
+	u32	v;
+} ACX_PACKED acx_ptr;
=20
 #if ACX_DEBUG
 #define CHECK32(n) BUG_ON(sizeof(n)>4 && (long)(n)>0xffffff00)
@@ -892,59 +892,59 @@ typedef struct {
 /* Outside of "#ifdef PCI" because USB needs to know sizeof()
 ** of txdesc and rxdesc: */
 struct txdesc {
-	acx_ptr	pNextDesc ACX_PACKED;	/* pointer to next txdesc */
-	acx_ptr	HostMemPtr ACX_PACKED;			/* 0x04 */
-	acx_ptr	AcxMemPtr ACX_PACKED;			/* 0x08 */
-	u32	tx_time ACX_PACKED;			/* 0x0c */
-	u16	total_length ACX_PACKED;		/* 0x10 */
-	u16	Reserved ACX_PACKED;			/* 0x12 */
+	acx_ptr	pNextDesc;	/* pointer to next txdesc */
+	acx_ptr	HostMemPtr;			/* 0x04 */
+	acx_ptr	AcxMemPtr;			/* 0x08 */
+	u32	tx_time;			/* 0x0c */
+	u16	total_length;		/* 0x10 */
+	u16	Reserved;			/* 0x12 */
=20
 /* The following 16 bytes do not change when acx100 owns the descriptor =
*/
 /* BUG: fw clears last byte of this area which is supposedly reserved
 ** for driver use. amd64 blew up. We dare not use it now */
-	u32	dummy[4] ACX_PACKED;
+	u32	dummy[4];
=20
-	u8	Ctl_8 ACX_PACKED;			/* 0x24, 8bit value */
-	u8	Ctl2_8 ACX_PACKED;			/* 0x25, 8bit value */
-	u8	error ACX_PACKED;			/* 0x26 */
-	u8	ack_failures ACX_PACKED;		/* 0x27 */
-	u8	rts_failures ACX_PACKED;		/* 0x28 */
-	u8	rts_ok ACX_PACKED;			/* 0x29 */
+	u8	Ctl_8;			/* 0x24, 8bit value */
+	u8	Ctl2_8;			/* 0x25, 8bit value */
+	u8	error;			/* 0x26 */
+	u8	ack_failures;		/* 0x27 */
+	u8	rts_failures;		/* 0x28 */
+	u8	rts_ok;			/* 0x29 */
 	union {
 		struct {
-			u8	rate ACX_PACKED;	/* 0x2a */
-			u8	queue_ctrl ACX_PACKED;	/* 0x2b */
-		} r1 ACX_PACKED;
+			u8	rate;	/* 0x2a */
+			u8	queue_ctrl;	/* 0x2b */
+		} ACX_PACKED r1;
 		struct {
-			u16	rate111 ACX_PACKED;	/* 0x2a */
-		} r2 ACX_PACKED;
-	} u ACX_PACKED;
-	u32	queue_info ACX_PACKED;			/* 0x2c (acx100, reserved on acx111) */
-};		/* size : 48 =3D 0x30 */
+			u16	rate111;	/* 0x2a */
+		} ACX_PACKED r2;
+	} u;
+	u32	queue_info;			/* 0x2c (acx100, reserved on acx111) */
+} ACX_PACKED;		/* size : 48 =3D 0x30 */
 /* NB: acx111 txdesc structure is 4 byte larger */
 /* All these 4 extra bytes are reserved. tx alloc code takes them into a=
ccount */
=20
 struct rxdesc {
-	acx_ptr	pNextDesc ACX_PACKED;			/* 0x00 */
-	acx_ptr	HostMemPtr ACX_PACKED;			/* 0x04 */
-	acx_ptr	ACXMemPtr ACX_PACKED;			/* 0x08 */
-	u32	rx_time ACX_PACKED;			/* 0x0c */
-	u16	total_length ACX_PACKED;		/* 0x10 */
-	u16	WEP_length ACX_PACKED;			/* 0x12 */
-	u32	WEP_ofs ACX_PACKED;			/* 0x14 */
+	acx_ptr	pNextDesc;			/* 0x00 */
+	acx_ptr	HostMemPtr;			/* 0x04 */
+	acx_ptr	ACXMemPtr;			/* 0x08 */
+	u32	rx_time;			/* 0x0c */
+	u16	total_length;		/* 0x10 */
+	u16	WEP_length;			/* 0x12 */
+	u32	WEP_ofs;			/* 0x14 */
=20
 /* the following 16 bytes do not change when acx100 owns the descriptor =
*/
-	u8	driverWorkspace[16] ACX_PACKED;		/* 0x18 */
+	u8	driverWorkspace[16];		/* 0x18 */
=20
-	u8	Ctl_8 ACX_PACKED;
-	u8	rate ACX_PACKED;
-	u8	error ACX_PACKED;
-	u8	SNR ACX_PACKED;				/* Signal-to-Noise Ratio */
-	u8	RxLevel ACX_PACKED;
-	u8	queue_ctrl ACX_PACKED;
-	u16	unknown ACX_PACKED;
-	u32	unknown2 ACX_PACKED;
-};		/* size 52 =3D 0x34 */
+	u8	Ctl_8;
+	u8	rate;
+	u8	error;
+	u8	SNR;				/* Signal-to-Noise Ratio */
+	u8	RxLevel;
+	u8	queue_ctrl;
+	u16	unknown;
+	u32	unknown2;
+} ACX_PACKED;		/* size 52 =3D 0x34 */
=20
 #ifdef ACX_PCI
=20
@@ -1013,30 +1013,30 @@ enum {
 #define INT_TRIG_CMD		0x01
=20
 struct txhostdesc {
-	acx_ptr	data_phy ACX_PACKED;			/* 0x00 [u8 *] */
-	u16	data_offset ACX_PACKED;			/* 0x04 */
-	u16	reserved ACX_PACKED;			/* 0x06 */
-	u16	Ctl_16 ACX_PACKED;	/* 16bit value, endianness!! */
-	u16	length ACX_PACKED;			/* 0x0a */
-	acx_ptr	desc_phy_next ACX_PACKED;		/* 0x0c [txhostdesc *] */
-	acx_ptr	pNext ACX_PACKED;			/* 0x10 [txhostdesc *] */
-	u32	Status ACX_PACKED;			/* 0x14, unused on Tx */
+	acx_ptr	data_phy;			/* 0x00 [u8 *] */
+	u16	data_offset;			/* 0x04 */
+	u16	reserved;			/* 0x06 */
+	u16	Ctl_16;	/* 16bit value, endianness!! */
+	u16	length;			/* 0x0a */
+	acx_ptr	desc_phy_next;		/* 0x0c [txhostdesc *] */
+	acx_ptr	pNext;			/* 0x10 [txhostdesc *] */
+	u32	Status;			/* 0x14, unused on Tx */
 /* From here on you can use this area as you want (variable length, too!=
) */
-	u8	*data ACX_PACKED;
-};
+	u8	*data;
+} ACX_PACKED;
=20
 struct rxhostdesc {
-	acx_ptr	data_phy ACX_PACKED;			/* 0x00 [rxbuffer_t *] */
-	u16	data_offset ACX_PACKED;			/* 0x04 */
-	u16	reserved ACX_PACKED;			/* 0x06 */
-	u16	Ctl_16 ACX_PACKED;			/* 0x08; 16bit value, endianness!! */
-	u16	length ACX_PACKED;			/* 0x0a */
-	acx_ptr	desc_phy_next ACX_PACKED;		/* 0x0c [rxhostdesc_t *] */
-	acx_ptr	pNext ACX_PACKED;			/* 0x10 [rxhostdesc_t *] */
-	u32	Status ACX_PACKED;			/* 0x14 */
+	acx_ptr	data_phy;			/* 0x00 [rxbuffer_t *] */
+	u16	data_offset;			/* 0x04 */
+	u16	reserved;			/* 0x06 */
+	u16	Ctl_16;			/* 0x08; 16bit value, endianness!! */
+	u16	length;			/* 0x0a */
+	acx_ptr	desc_phy_next;		/* 0x0c [rxhostdesc_t *] */
+	acx_ptr	pNext;			/* 0x10 [rxhostdesc_t *] */
+	u32	Status;			/* 0x14 */
 /* From here on you can use this area as you want (variable length, too!=
) */
-	rxbuffer_t *data ACX_PACKED;
-};
+	rxbuffer_t *data;
+} ACX_PACKED;
=20
 #endif /* ACX_PCI */
=20
@@ -1050,30 +1050,30 @@ struct rxhostdesc {
 /* Size of header (everything up to data[]) */
 #define USB_TXBUF_HDRSIZE	14
 typedef struct usb_txbuffer {
-	u16	desc ACX_PACKED;
-	u16	mpdu_len ACX_PACKED;
-	u8	queue_index ACX_PACKED;
-	u8	rate ACX_PACKED;
-	u32	hostdata ACX_PACKED;
-	u8	ctrl1 ACX_PACKED;
-	u8	ctrl2 ACX_PACKED;
-	u16	data_len ACX_PACKED;
+	u16	desc;
+	u16	mpdu_len;
+	u8	queue_index;
+	u8	rate;
+	u32	hostdata;
+	u8	ctrl1;
+	u8	ctrl2;
+	u16	data_len;
 	/* wlan packet content is placed here: */
-	u8	data[WLAN_A4FR_MAXLEN_WEP_FCS] ACX_PACKED;
-} usb_txbuffer_t;
+	u8	data[WLAN_A4FR_MAXLEN_WEP_FCS];
+} ACX_PACKED usb_txbuffer_t;
=20
 /* USB returns either rx packets (see rxbuffer) or
 ** these "tx status" structs: */
 typedef struct usb_txstatus {
-	u16	mac_cnt_rcvd ACX_PACKED;	/* only 12 bits are len! (0xfff) */
-	u8	queue_index ACX_PACKED;
-	u8	mac_status ACX_PACKED;		/* seen 0x20 on tx failure */
-	u32	hostdata ACX_PACKED;
-	u8	rate ACX_PACKED;
-	u8	ack_failures ACX_PACKED;
-	u8	rts_failures ACX_PACKED;
-	u8	rts_ok ACX_PACKED;
-} usb_txstatus_t;
+	u16	mac_cnt_rcvd;	/* only 12 bits are len! (0xfff) */
+	u8	queue_index;
+	u8	mac_status;		/* seen 0x20 on tx failure */
+	u32	hostdata;
+	u8	rate;
+	u8	ack_failures;
+	u8	rts_failures;
+	u8	rts_ok;
+} ACX_PACKED usb_txstatus_t;
=20
 typedef struct usb_tx {
 	unsigned	busy:1;
@@ -1104,72 +1104,71 @@ typedef struct usb_rx {
 /* Config Option structs */
=20
 typedef struct co_antennas {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u8	list[2] ACX_PACKED;
-} co_antennas_t;
+	u8	type;
+	u8	len;
+	u8	list[2];
+} ACX_PACKED co_antennas_t;
=20
 typedef struct co_powerlevels {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u16	list[8] ACX_PACKED;
-} co_powerlevels_t;
+	u8	type;
+	u8	len;
+	u16	list[8];
+} ACX_PACKED co_powerlevels_t;
=20
 typedef struct co_datarates {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u8	list[8] ACX_PACKED;
-} co_datarates_t;
+	u8	type;
+	u8	len;
+	u8	list[8];
+} ACX_PACKED co_datarates_t;
=20
 typedef struct co_domains {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u8	list[6] ACX_PACKED;
-} co_domains_t;
+	u8	type;
+	u8	len;
+	u8	list[6];
+} ACX_PACKED co_domains_t;
=20
 typedef struct co_product_id {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u8	list[128] ACX_PACKED;
-} co_product_id_t;
+	u8	type;
+	u8	len;
+	u8	list[128];
+} ACX_PACKED co_product_id_t;
=20
 typedef struct co_manuf_id {
-	u8	type ACX_PACKED;
-	u8	len ACX_PACKED;
-	u8	list[128] ACX_PACKED;
-} co_manuf_t;
+	u8	type;
+	u8	len;
+	u8	list[128];
+} ACX_PACKED co_manuf_t;
=20
 typedef struct co_fixed {
-	char	NVSv[8] ACX_PACKED;
+	char	NVSv[8];
 /*	u16	NVS_vendor_offs;	ACX111-only */
 /*	u16	unknown;		ACX111-only */
-	u8	MAC[6] ACX_PACKED;	/* ACX100-only */
-	u16	probe_delay ACX_PACKED;	/* ACX100-only */
-	u32	eof_memory ACX_PACKED;
-	u8	dot11CCAModes ACX_PACKED;
-	u8	dot11Diversity ACX_PACKED;
-	u8	dot11ShortPreambleOption ACX_PACKED;
-	u8	dot11PBCCOption ACX_PACKED;
-	u8	dot11ChannelAgility ACX_PACKED;
-	u8	dot11PhyType ACX_PACKED; /* FIXME: does 802.11 call it "dot11PHYType=
"? */
-	u8	dot11TempType ACX_PACKED;
-	u8	table_count ACX_PACKED;
-} co_fixed_t;
+	u8	MAC[6];	/* ACX100-only */
+	u16	probe_delay;	/* ACX100-only */
+	u32	eof_memory;
+	u8	dot11CCAModes;
+	u8	dot11Diversity;
+	u8	dot11ShortPreambleOption;
+	u8	dot11PBCCOption;
+	u8	dot11ChannelAgility;
+	u8	dot11PhyType; /* FIXME: does 802.11 call it "dot11PHYType"? */
+	u8	dot11TempType;
+	u8	table_count;
+} ACX_PACKED co_fixed_t;
=20
 typedef struct acx111_ie_configoption {
-	u16			type ACX_PACKED;
-	u16			len ACX_PACKED;
+	u16			type;
+	u16			len;
 /* Do not access below members directly, they are in fact variable lengt=
h */
-	co_fixed_t		fixed ACX_PACKED;
-	co_antennas_t		antennas ACX_PACKED;
-	co_powerlevels_t	power_levels ACX_PACKED;
-	co_datarates_t		data_rates ACX_PACKED;
-	co_domains_t		domains ACX_PACKED;
-	co_product_id_t		product_id ACX_PACKED;
-	co_manuf_t		manufacturer ACX_PACKED;
+	co_fixed_t		fixed;
+	co_antennas_t		antennas;
+	co_powerlevels_t	power_levels;
+	co_datarates_t		data_rates;
+	co_domains_t		domains;
+	co_product_id_t		product_id;
+	co_manuf_t		manufacturer;
 	u8			_padding[4];
-} acx111_ie_configoption_t;
-
+} ACX_PACKED acx111_ie_configoption_t;
=20
 /***********************************************************************
 ** Main acx per-device data structure
@@ -1601,108 +1600,108 @@ ndev2adev(struct net_device *ndev)
 /***********************************************************************
 */
 typedef struct acx100_ie_memblocksize {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u16	size ACX_PACKED;
-} acx100_ie_memblocksize_t;
+	u16	type;
+	u16	len;
+	u16	size;
+} ACX_PACKED acx100_ie_memblocksize_t;
=20
 typedef struct acx100_ie_queueconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u32	AreaSize ACX_PACKED;
-	u32	RxQueueStart ACX_PACKED;
-	u8	QueueOptions ACX_PACKED;
-	u8	NumTxQueues ACX_PACKED;
-	u8	NumRxDesc ACX_PACKED;	 /* for USB only */
-	u8	pad1 ACX_PACKED;
-	u32	QueueEnd ACX_PACKED;
-	u32	HostQueueEnd ACX_PACKED; /* QueueEnd2 */
-	u32	TxQueueStart ACX_PACKED;
-	u8	TxQueuePri ACX_PACKED;
-	u8	NumTxDesc ACX_PACKED;
-	u16	pad2 ACX_PACKED;
-} acx100_ie_queueconfig_t;
+	u16	type;
+	u16	len;
+	u32	AreaSize;
+	u32	RxQueueStart;
+	u8	QueueOptions;
+	u8	NumTxQueues;
+	u8	NumRxDesc;	 /* for USB only */
+	u8	pad1;
+	u32	QueueEnd;
+	u32	HostQueueEnd; /* QueueEnd2 */
+	u32	TxQueueStart;
+	u8	TxQueuePri;
+	u8	NumTxDesc;
+	u16	pad2;
+} ACX_PACKED acx100_ie_queueconfig_t;
=20
 typedef struct acx111_ie_queueconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u32	tx_memory_block_address ACX_PACKED;
-	u32	rx_memory_block_address ACX_PACKED;
-	u32	rx1_queue_address ACX_PACKED;
-	u32	reserved1 ACX_PACKED;
-	u32	tx1_queue_address ACX_PACKED;
-	u8	tx1_attributes ACX_PACKED;
-	u16	reserved2 ACX_PACKED;
-	u8	reserved3 ACX_PACKED;
-} acx111_ie_queueconfig_t;
+	u16	type;
+	u16	len;
+	u32	tx_memory_block_address;
+	u32	rx_memory_block_address;
+	u32	rx1_queue_address;
+	u32	reserved1;
+	u32	tx1_queue_address;
+	u8	tx1_attributes;
+	u16	reserved2;
+	u8	reserved3;
+} ACX_PACKED acx111_ie_queueconfig_t;
=20
 typedef struct acx100_ie_memconfigoption {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u32	DMA_config ACX_PACKED;
-	acx_ptr	pRxHostDesc ACX_PACKED;
-	u32	rx_mem ACX_PACKED;
-	u32	tx_mem ACX_PACKED;
-	u16	RxBlockNum ACX_PACKED;
-	u16	TxBlockNum ACX_PACKED;
-} acx100_ie_memconfigoption_t;
+	u16	type;
+	u16	len;
+	u32	DMA_config;
+	acx_ptr	pRxHostDesc;
+	u32	rx_mem;
+	u32	tx_mem;
+	u16	RxBlockNum;
+	u16	TxBlockNum;
+} ACX_PACKED acx100_ie_memconfigoption_t;
=20
 typedef struct acx111_ie_memoryconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u16	no_of_stations ACX_PACKED;
-	u16	memory_block_size ACX_PACKED;
-	u8	tx_rx_memory_block_allocation ACX_PACKED;
-	u8	count_rx_queues ACX_PACKED;
-	u8	count_tx_queues ACX_PACKED;
-	u8	options ACX_PACKED;
-	u8	fragmentation ACX_PACKED;
-	u16	reserved1 ACX_PACKED;
-	u8	reserved2 ACX_PACKED;
+	u16	type;
+	u16	len;
+	u16	no_of_stations;
+	u16	memory_block_size;
+	u8	tx_rx_memory_block_allocation;
+	u8	count_rx_queues;
+	u8	count_tx_queues;
+	u8	options;
+	u8	fragmentation;
+	u16	reserved1;
+	u8	reserved2;
=20
 	/* start of rx1 block */
-	u8	rx_queue1_count_descs ACX_PACKED;
-	u8	rx_queue1_reserved1 ACX_PACKED;
-	u8	rx_queue1_type ACX_PACKED; /* must be set to 7 */
-	u8	rx_queue1_prio ACX_PACKED; /* must be set to 0 */
-	acx_ptr	rx_queue1_host_rx_start ACX_PACKED;
+	u8	rx_queue1_count_descs;
+	u8	rx_queue1_reserved1;
+	u8	rx_queue1_type; /* must be set to 7 */
+	u8	rx_queue1_prio; /* must be set to 0 */
+	acx_ptr	rx_queue1_host_rx_start;
 	/* end of rx1 block */
=20
 	/* start of tx1 block */
-	u8	tx_queue1_count_descs ACX_PACKED;
-	u8	tx_queue1_reserved1 ACX_PACKED;
-	u8	tx_queue1_reserved2 ACX_PACKED;
-	u8	tx_queue1_attributes ACX_PACKED;
+	u8	tx_queue1_count_descs;
+	u8	tx_queue1_reserved1;
+	u8	tx_queue1_reserved2;
+	u8	tx_queue1_attributes;
 	/* end of tx1 block */
-} acx111_ie_memoryconfig_t;
+} ACX_PACKED acx111_ie_memoryconfig_t;
=20
 typedef struct acx_ie_memmap {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u32	CodeStart ACX_PACKED;
-	u32	CodeEnd ACX_PACKED;
-	u32	WEPCacheStart ACX_PACKED;
-	u32	WEPCacheEnd ACX_PACKED;
-	u32	PacketTemplateStart ACX_PACKED;
-	u32	PacketTemplateEnd ACX_PACKED;
-	u32	QueueStart ACX_PACKED;
-	u32	QueueEnd ACX_PACKED;
-	u32	PoolStart ACX_PACKED;
-	u32	PoolEnd ACX_PACKED;
-} acx_ie_memmap_t;
+	u16	type;
+	u16	len;
+	u32	CodeStart;
+	u32	CodeEnd;
+	u32	WEPCacheStart;
+	u32	WEPCacheEnd;
+	u32	PacketTemplateStart;
+	u32	PacketTemplateEnd;
+	u32	QueueStart;
+	u32	QueueEnd;
+	u32	PoolStart;
+	u32	PoolEnd;
+} ACX_PACKED acx_ie_memmap_t;
=20
 typedef struct acx111_ie_feature_config {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u32	feature_options ACX_PACKED;
-	u32	data_flow_options ACX_PACKED;
-} acx111_ie_feature_config_t;
+	u16	type;
+	u16	len;
+	u32	feature_options;
+	u32	data_flow_options;
+} ACX_PACKED acx111_ie_feature_config_t;
=20
 typedef struct acx111_ie_tx_level {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u8	level ACX_PACKED;
-} acx111_ie_tx_level_t;
+	u16	type;
+	u16	len;
+	u8	level;
+} ACX_PACKED acx111_ie_tx_level_t;
=20
 #define PS_CFG_ENABLE		0x80
 #define PS_CFG_PENDING		0x40 /* status flag when entering PS */
@@ -1719,25 +1718,25 @@ typedef struct acx111_ie_tx_level {
 #define PS_OPT_STILL_RCV_BCASTS	0x01
=20
 typedef struct acx100_ie_powersave {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u8	wakeup_cfg ACX_PACKED;
-	u8	listen_interval ACX_PACKED; /* for EACH_ITVL: wake up every "beacon =
units" interval */
-	u8	options ACX_PACKED;
-	u8	hangover_period ACX_PACKED; /* remaining wake time after Tx MPDU w/ =
PS bit, in values of 1/1024 seconds */
-	u16	enhanced_ps_transition_time ACX_PACKED; /* rem. wake time for Enh. =
PS */
-} acx100_ie_powersave_t;
+	u16	type;
+	u16	len;
+	u8	wakeup_cfg;
+	u8	listen_interval; /* for EACH_ITVL: wake up every "beacon units" inte=
rval */
+	u8	options;
+	u8	hangover_period; /* remaining wake time after Tx MPDU w/ PS bit, in =
values of 1/1024 seconds */
+	u16	enhanced_ps_transition_time; /* rem. wake time for Enh. PS */
+} ACX_PACKED acx100_ie_powersave_t;
=20
 typedef struct acx111_ie_powersave {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u8	wakeup_cfg ACX_PACKED;
-	u8	listen_interval ACX_PACKED; /* for EACH_ITVL: wake up every "beacon =
units" interval */
-	u8	options ACX_PACKED;
-	u8	hangover_period ACX_PACKED; /* remaining wake time after Tx MPDU w/ =
PS bit, in values of 1/1024 seconds */
-	u32	beacon_rx_time ACX_PACKED;
-	u32	enhanced_ps_transition_time ACX_PACKED; /* rem. wake time for Enh. =
PS */
-} acx111_ie_powersave_t;
+	u16	type;
+	u16	len;
+	u8	wakeup_cfg;
+	u8	listen_interval; /* for EACH_ITVL: wake up every "beacon units" inte=
rval */
+	u8	options;
+	u8	hangover_period; /* remaining wake time after Tx MPDU w/ PS bit, in =
values of 1/1024 seconds */
+	u32	beacon_rx_time;
+	u32	enhanced_ps_transition_time; /* rem. wake time for Enh. PS */
+} ACX_PACKED acx111_ie_powersave_t;
=20
=20
 /***********************************************************************
@@ -1764,14 +1763,14 @@ typedef struct acx111_ie_powersave {
 ** Background scan can be active or passive, just like normal one */
 #define ACX_SCAN_OPT_BACKGROUND	0x02
 typedef struct acx100_scan {
-	u16	count ACX_PACKED;	/* number of scans to do, 0xffff =3D=3D continuou=
s */
-	u16	start_chan ACX_PACKED;
-	u16	flags ACX_PACKED;	/* channel list mask; 0x8000 =3D=3D all channels?=
 */
-	u8	max_rate ACX_PACKED;	/* max. probe rate */
-	u8	options ACX_PACKED;	/* bit mask, see defines above */
-	u16	chan_duration ACX_PACKED;
-	u16	max_probe_delay ACX_PACKED;
-} acx100_scan_t;			/* length 0xc */
+	u16	count;	/* number of scans to do, 0xffff =3D=3D continuous */
+	u16	start_chan;
+	u16	flags;	/* channel list mask; 0x8000 =3D=3D all channels? */
+	u8	max_rate;	/* max. probe rate */
+	u8	options;	/* bit mask, see defines above */
+	u16	chan_duration;
+	u16	max_probe_delay;
+} ACX_PACKED acx100_scan_t; 			/* length 0xc */
=20
 #define ACX111_SCAN_RATE_6	0x0B
 #define ACX111_SCAN_RATE_9	0x0F
@@ -1786,22 +1785,21 @@ typedef struct acx100_scan {
 #define ACX111_SCAN_MOD_PBCC	0x80
 #define ACX111_SCAN_MOD_OFDM	0x40
 typedef struct acx111_scan {
-	u16	count ACX_PACKED;		/* number of scans to do */
-	u8	channel_list_select ACX_PACKED; /* 0: scan all channels, 1: from cha=
n_list only */
-	u16	reserved1 ACX_PACKED;
-	u8	reserved2 ACX_PACKED;
-	u8	rate ACX_PACKED;		/* rate for probe requests (if active scan) */
-	u8	options ACX_PACKED;		/* bit mask, see defines above */
-	u16	chan_duration ACX_PACKED;	/* min time to wait for reply on one chan=
nel (in TU) */
+	u16	count;		/* number of scans to do */
+	u8	channel_list_select; /* 0: scan all channels, 1: from chan_list only=
 */
+	u16	reserved1;
+	u8	reserved2;
+	u8	rate;		/* rate for probe requests (if active scan) */
+	u8	options;		/* bit mask, see defines above */
+	u16	chan_duration;	/* min time to wait for reply on one channel (in TU)=
 */
 						/* (active scan only) (802.11 section 11.1.3.2.2) */
-	u16	max_probe_delay ACX_PACKED;	/* max time to wait for reply on one ch=
annel (active scan) */
+	u16	max_probe_delay;	/* max time to wait for reply on one channel (acti=
ve scan) */
 						/* time to listen on a channel (passive scan) */
-	u8	modulation ACX_PACKED;
-	u8	channel_list[26] ACX_PACKED;	/* bits 7:0 first byte: channels 8:1 */
+	u8	modulation;
+	u8	channel_list[26];	/* bits 7:0 first byte: channels 8:1 */
 						/* bits 7:0 second byte: channels 16:9 */
 						/* 26 bytes is enough to cover 802.11a */
-} acx111_scan_t;
-
+} ACX_PACKED acx111_scan_t;
=20
 /*
 ** Radio calibration command structure
@@ -1810,10 +1808,9 @@ typedef struct acx111_cmd_radiocalib {
 /* 0x80000000 =3D=3D automatic calibration by firmware, according to int=
erval;
  * bits 0..3: select calibration methods to go through:
  * calib based on DC, AfeDC, Tx mismatch, Tx equilization */
-	u32	methods ACX_PACKED;
-	u32	interval ACX_PACKED;
-} acx111_cmd_radiocalib_t;
-
+	u32	methods;
+	u32	interval;
+} ACX_PACKED acx111_cmd_radiocalib_t;
=20
 /*
 ** Packet template structures
@@ -1836,53 +1833,52 @@ typedef struct acx111_cmd_radiocalib {
 **   rest must be zero filled.
 ** - variable length fields shown only in comments */
 typedef struct acx_template_tim {
-	u16	size ACX_PACKED;
-	u8	tim_eid ACX_PACKED;	/* 00 1 TIM IE ID * */
-	u8	len ACX_PACKED;		/* 01 1 Length * */
-	u8	dtim_cnt ACX_PACKED;	/* 02 1 DTIM Count */
-	u8	dtim_period ACX_PACKED;	/* 03 1 DTIM Period */
-	u8	bitmap_ctrl ACX_PACKED;	/* 04 1 Bitmap Control * (except bit0) */
+	u16	size;
+	u8	tim_eid;	/* 00 1 TIM IE ID * */
+	u8	len;		/* 01 1 Length * */
+	u8	dtim_cnt;	/* 02 1 DTIM Count */
+	u8	dtim_period;	/* 03 1 DTIM Period */
+	u8	bitmap_ctrl;	/* 04 1 Bitmap Control * (except bit0) */
 					/* 05 n Partial Virtual Bitmap * */
-	u8	variable[0x100 - 1-1-1-1-1] ACX_PACKED;
-} acx_template_tim_t;
+	u8	variable[0x100 - 1-1-1-1-1];
+} ACX_PACKED acx_template_tim_t;
=20
 typedef struct acx_template_probereq {
-	u16	size ACX_PACKED;
-	u16	fc ACX_PACKED;		/* 00 2 fc * */
-	u16	dur ACX_PACKED;		/* 02 2 Duration */
-	u8	da[6] ACX_PACKED;	/* 04 6 Destination Address * */
-	u8	sa[6] ACX_PACKED;	/* 0A 6 Source Address * */
-	u8	bssid[6] ACX_PACKED;	/* 10 6 BSSID * */
-	u16	seq ACX_PACKED;		/* 16 2 Sequence Control */
+	u16	size;
+	u16	fc;		/* 00 2 fc * */
+	u16	dur;		/* 02 2 Duration */
+	u8	da[6];	/* 04 6 Destination Address * */
+	u8	sa[6];	/* 0A 6 Source Address * */
+	u8	bssid[6];	/* 10 6 BSSID * */
+	u16	seq;		/* 16 2 Sequence Control */
 					/* 18 n SSID * */
 					/* nn n Supported Rates * */
-	u8	variable[0x44 - 2-2-6-6-6-2] ACX_PACKED;
-} acx_template_probereq_t;
+	u8	variable[0x44 - 2-2-6-6-6-2];
+} ACX_PACKED acx_template_probereq_t;
=20
 typedef struct acx_template_proberesp {
-	u16	size ACX_PACKED;
-	u16	fc ACX_PACKED;		/* 00 2 fc * (bits [15:12] and [10:8] per 802.11 se=
ction 7.1.3.1) */
-	u16	dur ACX_PACKED;		/* 02 2 Duration */
-	u8	da[6] ACX_PACKED;	/* 04 6 Destination Address */
-	u8	sa[6] ACX_PACKED;	/* 0A 6 Source Address */
-	u8	bssid[6] ACX_PACKED;	/* 10 6 BSSID */
-	u16	seq ACX_PACKED;		/* 16 2 Sequence Control */
-	u8	timestamp[8] ACX_PACKED;/* 18 8 Timestamp */
-	u16	beacon_interval ACX_PACKED; /* 20 2 Beacon Interval * */
-	u16	cap ACX_PACKED;		/* 22 2 Capability Information * */
+	u16	size;
+	u16	fc;		/* 00 2 fc * (bits [15:12] and [10:8] per 802.11 section 7.1.3=
.1) */
+	u16	dur;		/* 02 2 Duration */
+	u8	da[6];	/* 04 6 Destination Address */
+	u8	sa[6];	/* 0A 6 Source Address */
+	u8	bssid[6];	/* 10 6 BSSID */
+	u16	seq;		/* 16 2 Sequence Control */
+	u8	timestamp[8];/* 18 8 Timestamp */
+	u16	beacon_interval; /* 20 2 Beacon Interval * */
+	u16	cap;		/* 22 2 Capability Information * */
 					/* 24 n SSID * */
 					/* nn n Supported Rates * */
 					/* nn 1 DS Parameter Set * */
-	u8	variable[0x54 - 2-2-6-6-6-2-8-2-2] ACX_PACKED;
-} acx_template_proberesp_t;
+	u8	variable[0x54 - 2-2-6-6-6-2-8-2-2];
+} ACX_PACKED acx_template_proberesp_t;
 #define acx_template_beacon_t acx_template_proberesp_t
 #define acx_template_beacon acx_template_proberesp
=20
 typedef struct acx_template_nullframe {
-	u16	size ACX_PACKED;
-	struct wlan_hdr_a3 hdr ACX_PACKED;
-} acx_template_nullframe_t;
-
+	u16	size;
+	struct wlan_hdr_a3 hdr;
+} ACX_PACKED acx_template_nullframe_t;
=20
 /*
 ** JOIN command structure
@@ -1890,28 +1886,28 @@ typedef struct acx_template_nullframe {
 ** as opposed to acx100, acx111 dtim interval is AFTER rates_basic111.
 ** NOTE: took me about an hour to get !@#$%^& packing right --> struct p=
acking is eeeeevil... */
 typedef struct acx_joinbss {
-	u8	bssid[ETH_ALEN] ACX_PACKED;
-	u16	beacon_interval ACX_PACKED;
+	u8	bssid[ETH_ALEN];
+	u16	beacon_interval;
 	union {
 		struct {
-			u8	dtim_interval ACX_PACKED;
-			u8	rates_basic ACX_PACKED;
-			u8	rates_supported ACX_PACKED;
-		} acx100 ACX_PACKED;
+			u8	dtim_interval;
+			u8	rates_basic;
+			u8	rates_supported;
+		} ACX_PACKED acx100;
 		struct {
-			u16	rates_basic ACX_PACKED;
-			u8	dtim_interval ACX_PACKED;
-		} acx111 ACX_PACKED;
-	} u ACX_PACKED;
-	u8	genfrm_txrate ACX_PACKED;	/* generated frame (bcn, proberesp, RTS, P=
Spoll) tx rate */
-	u8	genfrm_mod_pre ACX_PACKED;	/* generated frame modulation/preamble:
+			u16	rates_basic;
+			u8	dtim_interval;
+		} ACX_PACKED acx111;
+	} u;
+	u8	genfrm_txrate;	/* generated frame (bcn, proberesp, RTS, PSpoll) tx r=
ate */
+	u8	genfrm_mod_pre;	/* generated frame modulation/preamble:
 						** bit7: PBCC, bit6: OFDM (else CCK/DQPSK/DBPSK)
 						** bit5: short pre */
-	u8	macmode ACX_PACKED;	/* BSS Type, must be one of ACX_MODE_xxx */
-	u8	channel ACX_PACKED;
-	u8	essid_len ACX_PACKED;
-	char	essid[IW_ESSID_MAX_SIZE] ACX_PACKED;
-} acx_joinbss_t;
+	u8	macmode;	/* BSS Type, must be one of ACX_MODE_xxx */
+	u8	channel;
+	u8	essid_len;
+	char	essid[IW_ESSID_MAX_SIZE];
+} ACX_PACKED acx_joinbss_t;
=20
 #define JOINBSS_RATES_1		0x01
 #define JOINBSS_RATES_2		0x02
@@ -1942,64 +1938,64 @@ typedef struct acx_joinbss {
 /***********************************************************************
 */
 typedef struct mem_read_write {
-	u16	addr ACX_PACKED;
-	u16	type ACX_PACKED; /* 0x0 int. RAM / 0xffff MAC reg. / 0x81 PHY RAM /=
 0x82 PHY reg.; or maybe it's actually 0x30 for MAC? Better verify it by =
writing and reading back and checking whether the value holds! */
-	u32	len ACX_PACKED;
-	u32	data ACX_PACKED;
-} mem_read_write_t;
+	u16	addr;
+	u16	type; /* 0x0 int. RAM / 0xffff MAC reg. / 0x81 PHY RAM / 0x82 PHY r=
eg.; or maybe it's actually 0x30 for MAC? Better verify it by writing and=
 reading back and checking whether the value holds! */
+	u32	len;
+	u32	data;
+} ACX_PACKED mem_read_write_t;
=20
 typedef struct firmware_image {
-	u32	chksum ACX_PACKED;
-	u32	size ACX_PACKED;
-	u8	data[1] ACX_PACKED; /* the byte array of the actual firmware... */
-} firmware_image_t;
+	u32	chksum;
+	u32	size;
+	u8	data[1]; /* the byte array of the actual firmware... */
+} ACX_PACKED firmware_image_t;
=20
 typedef struct acx_cmd_radioinit {
-	u32	offset ACX_PACKED;
-	u32	len ACX_PACKED;
-} acx_cmd_radioinit_t;
+	u32	offset;
+	u32	len;
+} ACX_PACKED acx_cmd_radioinit_t;
=20
 typedef struct acx100_ie_wep_options {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u16	NumKeys ACX_PACKED;	/* max # of keys */
-	u8	WEPOption ACX_PACKED;	/* 0 =3D=3D decrypt default key only, 1 =3D=3D=
 override decrypt */
-	u8	Pad ACX_PACKED;		/* used only for acx111 */
-} acx100_ie_wep_options_t;
+	u16	type;
+	u16	len;
+	u16	NumKeys;	/* max # of keys */
+	u8	WEPOption;	/* 0 =3D=3D decrypt default key only, 1 =3D=3D override d=
ecrypt */
+	u8	Pad;		/* used only for acx111 */
+} ACX_PACKED acx100_ie_wep_options_t;
=20
 typedef struct ie_dot11WEPDefaultKey {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u8	action ACX_PACKED;
-	u8	keySize ACX_PACKED;
-	u8	defaultKeyNum ACX_PACKED;
-	u8	key[29] ACX_PACKED;	/* check this! was Key[19] */
-} ie_dot11WEPDefaultKey_t;
+	u16	type;
+	u16	len;
+	u8	action;
+	u8	keySize;
+	u8	defaultKeyNum;
+	u8	key[29];	/* check this! was Key[19] */
+} ACX_PACKED ie_dot11WEPDefaultKey_t;
=20
 typedef struct acx111WEPDefaultKey {
-	u8	MacAddr[ETH_ALEN] ACX_PACKED;
-	u16	action ACX_PACKED;	/* NOTE: this is a u16, NOT a u8!! */
-	u16	reserved ACX_PACKED;
-	u8	keySize ACX_PACKED;
-	u8	type ACX_PACKED;
-	u8	index ACX_PACKED;
-	u8	defaultKeyNum ACX_PACKED;
-	u8	counter[6] ACX_PACKED;
-	u8	key[32] ACX_PACKED;	/* up to 32 bytes (for TKIP!) */
-} acx111WEPDefaultKey_t;
+	u8	MacAddr[ETH_ALEN];
+	u16	action;	/* NOTE: this is a u16, NOT a u8!! */
+	u16	reserved;
+	u8	keySize;
+	u8	type;
+	u8	index;
+	u8	defaultKeyNum;
+	u8	counter[6];
+	u8	key[32];	/* up to 32 bytes (for TKIP!) */
+} ACX_PACKED acx111WEPDefaultKey_t;
=20
 typedef struct ie_dot11WEPDefaultKeyID {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
-	u8	KeyID ACX_PACKED;
-} ie_dot11WEPDefaultKeyID_t;
+	u16	type;
+	u16	len;
+	u8	KeyID;
+} ACX_PACKED ie_dot11WEPDefaultKeyID_t;
=20
 typedef struct acx100_cmd_wep_mgmt {
-	u8	MacAddr[ETH_ALEN] ACX_PACKED;
-	u16	Action ACX_PACKED;
-	u16	KeySize ACX_PACKED;
-	u8	Key[29] ACX_PACKED; /* 29*8 =3D=3D 232bits =3D=3D WEP256 */
-} acx100_cmd_wep_mgmt_t;
+	u8	MacAddr[ETH_ALEN];
+	u16	Action;
+	u16	KeySize;
+	u8	Key[29]; /* 29*8 =3D=3D 232bits =3D=3D WEP256 */
+} ACX_PACKED acx100_cmd_wep_mgmt_t;
=20
 /* UNUSED?
 typedef struct defaultkey {
@@ -2008,17 +2004,17 @@ typedef struct defaultkey {
 */
=20
 typedef struct acx_ie_generic {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	u16	type;
+	u16	len;
 	union {
 		/* struct wep wp ACX_PACKED; */
 		/* Association ID IE: just a 16bit value: */
 		u16	aid;
 		/* UNUSED? struct defaultkey dkey ACX_PACKED; */
 		/* generic member for quick implementation of commands */
-		u8	bytes[32] ACX_PACKED;
-	} m ACX_PACKED;
-} acx_ie_generic_t;
+		u8	bytes[32];
+	} m;
+} ACX_PACKED acx_ie_generic_t;
=20
 /***********************************************************************
 */
diff --git a/common.c b/common.c
index 623e70d..ff6152d 100644
--- a/common.c
+++ b/common.c
@@ -1097,11 +1097,11 @@ void
 great_inquisitor(acx_device_t *adev)
 {
 	static struct {
-		u16	type ACX_PACKED;
-		u16	len ACX_PACKED;
+		u16	type;
+		u16	len;
 		/* 0x200 was too large here: */
-		u8	data[0x100 - 4] ACX_PACKED;
-	} ie;
+		u8	data[0x100 - 4];
+	} ACX_PACKED ie;
 	u16 type;
=20
 	FN_ENTER;
@@ -2341,11 +2341,11 @@ static void
 acx_s_initialize_rx_config(acx_device_t *adev)
 {
 	struct {
-		u16	id ACX_PACKED;
-		u16	len ACX_PACKED;
-		u16	rx_cfg1 ACX_PACKED;
-		u16	rx_cfg2 ACX_PACKED;
-	} cfg;
+		u16	id;
+		u16	len;
+		u16	rx_cfg1;
+		u16	rx_cfg2;
+	} ACX_PACKED cfg;
=20
 	switch (adev->mode) {
 	case ACX_MODE_OFF:
@@ -6941,10 +6941,10 @@ acx_s_update_card_settings(acx_device_t=20
 		ie_dot11WEPDefaultKeyID_t dkey;
 #ifdef DEBUG_WEP
 		struct {
-			u16 type ACX_PACKED;
-			u16 len ACX_PACKED;
-			u8  val ACX_PACKED;
-		} keyindic;
+			u16 type;
+			u16 len;
+			u8  val;
+		} ACX_PACKED keyindic;
 #endif
 		log(L_INIT, "updating WEP key settings\n");
=20
diff --git a/ioctl.c b/ioctl.c
index 6c548ca..ca3c42e 100644
--- a/ioctl.c
+++ b/ioctl.c
@@ -2168,11 +2168,11 @@ acx_ioctl_get_phy_chan_busy_percentage(
 {
 	acx_device_t *adev =3D ndev2adev(ndev);
 	struct { /* added ACX_PACKED, not tested --vda */
-		u16 type ACX_PACKED;
-		u16 len ACX_PACKED;
-		u32 busytime ACX_PACKED;
-		u32 totaltime ACX_PACKED;
-	} usage;
+		u16 type;
+		u16 len;
+		u32 busytime;
+		u32 totaltime;
+	} ACX_PACKED usage;
 	int result;
=20
 	acx_sem_lock(adev);
diff --git a/usb.c b/usb.c
index 5833d04..51290ed 100644
--- a/usb.c
+++ b/usb.c
@@ -305,10 +305,10 @@ acxusb_s_issue_cmd_timeo_debug(
=20
 	struct usb_device *usbdev;
 	struct {
-		u16	cmd ACX_PACKED;
-		u16	status ACX_PACKED;
-		u8	data[1] ACX_PACKED;
-	} *loc;
+		u16	cmd;
+		u16	status;
+		u8	data[1];
+	} ACX_PACKED *loc;
 	const char *devname;
 	int acklen, blocklen, inpipe, outpipe;
 	int cmd_status;
--=20
1.2.4.g3103




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
