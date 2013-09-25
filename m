From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/11] brcm80211: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:23 -0700
Message-ID: <9bd91f3c00bd8dd54339499a9253b31c6bac7c7b.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  30 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |  27 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |  12 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |  23 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |  92 +++--
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |  18 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.h    |  22 +-
 drivers/net/wireless/brcm80211/brcmsmac/antsel.h   |  14 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.h  |  20 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |  38 +--
 drivers/net/wireless/brcm80211/brcmsmac/main.h     | 110 +++---
 .../net/wireless/brcm80211/brcmsmac/phy/phy_hal.h  | 219 ++++++------
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  | 371 ++++++++++-----------
 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h |  91 +++--
 drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |   4 +-
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      | 145 ++++----
 drivers/net/wireless/brcm80211/brcmsmac/rate.h     |  48 ++-
 drivers/net/wireless/brcm80211/brcmsmac/stf.h      |  31 +-
 .../net/wireless/brcm80211/brcmsmac/ucode_loader.h |  16 +-
 drivers/net/wireless/brcm80211/include/brcmu_d11.h |   2 +-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |  44 ++-
 21 files changed, 644 insertions(+), 733 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
index 2eb9e64..34af9d1 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
@@ -632,29 +632,29 @@ struct brcmf_skb_reorder_data {
 	u8 *reorder;
 };
 
-extern int brcmf_netdev_wait_pend8021x(struct net_device *ndev);
+int brcmf_netdev_wait_pend8021x(struct net_device *ndev);
 
 /* Return pointer to interface name */
-extern char *brcmf_ifname(struct brcmf_pub *drvr, int idx);
+char *brcmf_ifname(struct brcmf_pub *drvr, int idx);
 
 /* Query dongle */
-extern int brcmf_proto_cdc_query_dcmd(struct brcmf_pub *drvr, int ifidx,
-				       uint cmd, void *buf, uint len);
-extern int brcmf_proto_cdc_set_dcmd(struct brcmf_pub *drvr, int ifidx, uint cmd,
-				    void *buf, uint len);
+int brcmf_proto_cdc_query_dcmd(struct brcmf_pub *drvr, int ifidx, uint cmd,
+			       void *buf, uint len);
+int brcmf_proto_cdc_set_dcmd(struct brcmf_pub *drvr, int ifidx, uint cmd,
+			     void *buf, uint len);
 
 /* Remove any protocol-specific data header. */
-extern int brcmf_proto_hdrpull(struct brcmf_pub *drvr, bool do_fws, u8 *ifidx,
-			       struct sk_buff *rxp);
+int brcmf_proto_hdrpull(struct brcmf_pub *drvr, bool do_fws, u8 *ifidx,
+			struct sk_buff *rxp);
 
-extern int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
-extern struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx,
-				     s32 ifidx, char *name, u8 *mac_addr);
-extern void brcmf_del_if(struct brcmf_pub *drvr, s32 bssidx);
+int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
+struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bssidx, s32 ifidx,
+			      char *name, u8 *mac_addr);
+void brcmf_del_if(struct brcmf_pub *drvr, s32 bssidx);
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state);
-extern u32 brcmf_get_chip_info(struct brcmf_if *ifp);
-extern void brcmf_txfinalize(struct brcmf_pub *drvr, struct sk_buff *txp,
-			     bool success);
+u32 brcmf_get_chip_info(struct brcmf_if *ifp);
+void brcmf_txfinalize(struct brcmf_pub *drvr, struct sk_buff *txp,
+		      bool success);
 
 #endif				/* _BRCMF_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
index f7c1985..5bc0276 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
@@ -132,34 +132,33 @@ struct pktq *brcmf_bus_gettxq(struct brcmf_bus *bus)
  * interface functions from common layer
  */
 
-extern bool brcmf_c_prec_enq(struct device *dev, struct pktq *q,
-			 struct sk_buff *pkt, int prec);
+bool brcmf_c_prec_enq(struct device *dev, struct pktq *q, struct sk_buff *pkt,
+		      int prec);
 
 /* Receive frame for delivery to OS.  Callee disposes of rxp. */
-extern void brcmf_rx_frames(struct device *dev, struct sk_buff_head *rxlist);
+void brcmf_rx_frames(struct device *dev, struct sk_buff_head *rxlist);
 
 /* Indication from bus module regarding presence/insertion of dongle. */
-extern int brcmf_attach(uint bus_hdrlen, struct device *dev);
+int brcmf_attach(uint bus_hdrlen, struct device *dev);
 /* Indication from bus module regarding removal/absence of dongle */
-extern void brcmf_detach(struct device *dev);
+void brcmf_detach(struct device *dev);
 /* Indication from bus module that dongle should be reset */
-extern void brcmf_dev_reset(struct device *dev);
+void brcmf_dev_reset(struct device *dev);
 /* Indication from bus module to change flow-control state */
-extern void brcmf_txflowblock(struct device *dev, bool state);
+void brcmf_txflowblock(struct device *dev, bool state);
 
 /* Notify the bus has transferred the tx packet to firmware */
-extern void brcmf_txcomplete(struct device *dev, struct sk_buff *txp,
-			     bool success);
+void brcmf_txcomplete(struct device *dev, struct sk_buff *txp, bool success);
 
-extern int brcmf_bus_start(struct device *dev);
+int brcmf_bus_start(struct device *dev);
 
 #ifdef CONFIG_BRCMFMAC_SDIO
-extern void brcmf_sdio_exit(void);
-extern void brcmf_sdio_init(void);
+void brcmf_sdio_exit(void);
+void brcmf_sdio_init(void);
 #endif
 #ifdef CONFIG_BRCMFMAC_USB
-extern void brcmf_usb_exit(void);
-extern void brcmf_usb_init(void);
+void brcmf_usb_exit(void);
+void brcmf_usb_init(void);
 #endif
 
 #endif				/* _BRCMF_BUS_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h
index ef91798..53c6e71 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h
@@ -22,21 +22,21 @@
  */
 
 /* Linkage, sets prot link and updates hdrlen in pub */
-extern int brcmf_proto_attach(struct brcmf_pub *drvr);
+int brcmf_proto_attach(struct brcmf_pub *drvr);
 
 /* Unlink, frees allocated protocol memory (including brcmf_proto) */
-extern void brcmf_proto_detach(struct brcmf_pub *drvr);
+void brcmf_proto_detach(struct brcmf_pub *drvr);
 
 /* Stop protocol: sync w/dongle state. */
-extern void brcmf_proto_stop(struct brcmf_pub *drvr);
+void brcmf_proto_stop(struct brcmf_pub *drvr);
 
 /* Add any protocol-specific data header.
  * Caller must reserve prot_hdrlen prepend space.
  */
-extern void brcmf_proto_hdrpush(struct brcmf_pub *, int ifidx, u8 offset,
-				struct sk_buff *txp);
+void brcmf_proto_hdrpush(struct brcmf_pub *, int ifidx, u8 offset,
+			 struct sk_buff *txp);
 
 /* Sets dongle media info (drv_version, mac address). */
-extern int brcmf_c_preinit_dcmds(struct brcmf_if *ifp);
+int brcmf_c_preinit_dcmds(struct brcmf_if *ifp);
 
 #endif				/* _BRCMF_PROTO_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h b/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h
index 83c041f..f0780ee 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h
@@ -215,17 +215,16 @@ struct sdpcmd_regs {
 	u16 PAD[0x80];
 };
 
-extern int brcmf_sdio_chip_attach(struct brcmf_sdio_dev *sdiodev,
-				  struct chip_info **ci_ptr, u32 regs);
-extern void brcmf_sdio_chip_detach(struct chip_info **ci_ptr);
-extern void brcmf_sdio_chip_drivestrengthinit(struct brcmf_sdio_dev *sdiodev,
-					      struct chip_info *ci,
-					      u32 drivestrength);
-extern u8 brcmf_sdio_chip_getinfidx(struct chip_info *ci, u16 coreid);
-extern void brcmf_sdio_chip_enter_download(struct brcmf_sdio_dev *sdiodev,
-					   struct chip_info *ci);
-extern bool brcmf_sdio_chip_exit_download(struct brcmf_sdio_dev *sdiodev,
-					  struct chip_info *ci, char *nvram_dat,
-					  uint nvram_sz);
+int brcmf_sdio_chip_attach(struct brcmf_sdio_dev *sdiodev,
+			   struct chip_info **ci_ptr, u32 regs);
+void brcmf_sdio_chip_detach(struct chip_info **ci_ptr);
+void brcmf_sdio_chip_drivestrengthinit(struct brcmf_sdio_dev *sdiodev,
+				       struct chip_info *ci, u32 drivestrength);
+u8 brcmf_sdio_chip_getinfidx(struct chip_info *ci, u16 coreid);
+void brcmf_sdio_chip_enter_download(struct brcmf_sdio_dev *sdiodev,
+				    struct chip_info *ci);
+bool brcmf_sdio_chip_exit_download(struct brcmf_sdio_dev *sdiodev,
+				   struct chip_info *ci, char *nvram_dat,
+				   uint nvram_sz);
 
 #endif		/* _BRCMFMAC_SDIO_CHIP_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h b/drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h
index 2b5407f..c9b06b4 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h
@@ -181,18 +181,18 @@ struct brcmf_sdio_dev {
 };
 
 /* Register/deregister interrupt handler. */
-extern int brcmf_sdio_intr_register(struct brcmf_sdio_dev *sdiodev);
-extern int brcmf_sdio_intr_unregister(struct brcmf_sdio_dev *sdiodev);
+int brcmf_sdio_intr_register(struct brcmf_sdio_dev *sdiodev);
+int brcmf_sdio_intr_unregister(struct brcmf_sdio_dev *sdiodev);
 
 /* sdio device register access interface */
-extern u8 brcmf_sdio_regrb(struct brcmf_sdio_dev *sdiodev, u32 addr, int *ret);
-extern u32 brcmf_sdio_regrl(struct brcmf_sdio_dev *sdiodev, u32 addr, int *ret);
-extern void brcmf_sdio_regwb(struct brcmf_sdio_dev *sdiodev, u32 addr,
-			     u8 data, int *ret);
-extern void brcmf_sdio_regwl(struct brcmf_sdio_dev *sdiodev, u32 addr,
-			     u32 data, int *ret);
-extern int brcmf_sdio_regrw_helper(struct brcmf_sdio_dev *sdiodev, u32 addr,
-				   void *data, bool write);
+u8 brcmf_sdio_regrb(struct brcmf_sdio_dev *sdiodev, u32 addr, int *ret);
+u32 brcmf_sdio_regrl(struct brcmf_sdio_dev *sdiodev, u32 addr, int *ret);
+void brcmf_sdio_regwb(struct brcmf_sdio_dev *sdiodev, u32 addr, u8 data,
+		      int *ret);
+void brcmf_sdio_regwl(struct brcmf_sdio_dev *sdiodev, u32 addr, u32 data,
+		      int *ret);
+int brcmf_sdio_regrw_helper(struct brcmf_sdio_dev *sdiodev, u32 addr,
+			    void *data, bool write);
 
 /* Buffer transfer to/from device (client) core via cmd53.
  *   fn:       function number
@@ -206,22 +206,17 @@ extern int brcmf_sdio_regrw_helper(struct brcmf_sdio_dev *sdiodev, u32 addr,
  * Returns 0 or error code.
  * NOTE: Async operation is not currently supported.
  */
-extern int
-brcmf_sdcard_send_pkt(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
-		      uint flags, struct sk_buff_head *pktq);
-extern int
-brcmf_sdcard_send_buf(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
-		      uint flags, u8 *buf, uint nbytes);
-
-extern int
-brcmf_sdcard_recv_pkt(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
-		      uint flags, struct sk_buff *pkt);
-extern int
-brcmf_sdcard_recv_buf(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
-		      uint flags, u8 *buf, uint nbytes);
-extern int
-brcmf_sdcard_recv_chain(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
-			uint flags, struct sk_buff_head *pktq);
+int brcmf_sdcard_send_pkt(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
+			  uint flags, struct sk_buff_head *pktq);
+int brcmf_sdcard_send_buf(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
+			  uint flags, u8 *buf, uint nbytes);
+
+int brcmf_sdcard_recv_pkt(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
+			  uint flags, struct sk_buff *pkt);
+int brcmf_sdcard_recv_buf(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
+			  uint flags, u8 *buf, uint nbytes);
+int brcmf_sdcard_recv_chain(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
+			    uint flags, struct sk_buff_head *pktq);
 
 /* Flags bits */
 
@@ -237,46 +232,43 @@ brcmf_sdcard_recv_chain(struct brcmf_sdio_dev *sdiodev, u32 addr, uint fn,
  *   nbytes:   number of bytes to transfer to/from buf
  * Returns 0 or error code.
  */
-extern int brcmf_sdcard_rwdata(struct brcmf_sdio_dev *sdiodev, uint rw,
-			       u32 addr, u8 *buf, uint nbytes);
-extern int brcmf_sdio_ramrw(struct brcmf_sdio_dev *sdiodev, bool write,
-			    u32 address, u8 *data, uint size);
+int brcmf_sdcard_rwdata(struct brcmf_sdio_dev *sdiodev, uint rw, u32 addr,
+			u8 *buf, uint nbytes);
+int brcmf_sdio_ramrw(struct brcmf_sdio_dev *sdiodev, bool write, u32 address,
+		     u8 *data, uint size);
 
 /* Issue an abort to the specified function */
-extern int brcmf_sdcard_abort(struct brcmf_sdio_dev *sdiodev, uint fn);
+int brcmf_sdcard_abort(struct brcmf_sdio_dev *sdiodev, uint fn);
 
 /* platform specific/high level functions */
-extern int brcmf_sdio_probe(struct brcmf_sdio_dev *sdiodev);
-extern int brcmf_sdio_remove(struct brcmf_sdio_dev *sdiodev);
+int brcmf_sdio_probe(struct brcmf_sdio_dev *sdiodev);
+int brcmf_sdio_remove(struct brcmf_sdio_dev *sdiodev);
 
 /* attach, return handler on success, NULL if failed.
  *  The handler shall be provided by all subsequent calls. No local cache
  *  cfghdl points to the starting address of pci device mapped memory
  */
-extern int brcmf_sdioh_attach(struct brcmf_sdio_dev *sdiodev);
-extern void brcmf_sdioh_detach(struct brcmf_sdio_dev *sdiodev);
+int brcmf_sdioh_attach(struct brcmf_sdio_dev *sdiodev);
+void brcmf_sdioh_detach(struct brcmf_sdio_dev *sdiodev);
 
 /* read or write one byte using cmd52 */
-extern int brcmf_sdioh_request_byte(struct brcmf_sdio_dev *sdiodev, uint rw,
-				    uint fnc, uint addr, u8 *byte);
+int brcmf_sdioh_request_byte(struct brcmf_sdio_dev *sdiodev, uint rw, uint fnc,
+			     uint addr, u8 *byte);
 
 /* read or write 2/4 bytes using cmd53 */
-extern int
-brcmf_sdioh_request_word(struct brcmf_sdio_dev *sdiodev,
-			 uint rw, uint fnc, uint addr,
-			 u32 *word, uint nbyte);
+int brcmf_sdioh_request_word(struct brcmf_sdio_dev *sdiodev, uint rw, uint fnc,
+			     uint addr, u32 *word, uint nbyte);
 
 /* Watchdog timer interface for pm ops */
-extern void brcmf_sdio_wdtmr_enable(struct brcmf_sdio_dev *sdiodev,
-				    bool enable);
+void brcmf_sdio_wdtmr_enable(struct brcmf_sdio_dev *sdiodev, bool enable);
 
-extern void *brcmf_sdbrcm_probe(u32 regsva, struct brcmf_sdio_dev *sdiodev);
-extern void brcmf_sdbrcm_disconnect(void *ptr);
-extern void brcmf_sdbrcm_isr(void *arg);
+void *brcmf_sdbrcm_probe(u32 regsva, struct brcmf_sdio_dev *sdiodev);
+void brcmf_sdbrcm_disconnect(void *ptr);
+void brcmf_sdbrcm_isr(void *arg);
 
-extern void brcmf_sdbrcm_wd_timer(struct brcmf_sdio *bus, uint wdtick);
+void brcmf_sdbrcm_wd_timer(struct brcmf_sdio *bus, uint wdtick);
 
-extern void brcmf_pm_resume_wait(struct brcmf_sdio_dev *sdiodev,
-				 wait_queue_head_t *wq);
-extern bool brcmf_pm_resume_error(struct brcmf_sdio_dev *sdiodev);
+void brcmf_pm_resume_wait(struct brcmf_sdio_dev *sdiodev,
+			  wait_queue_head_t *wq);
+bool brcmf_pm_resume_error(struct brcmf_sdio_dev *sdiodev);
 #endif				/* _BRCM_SDH_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.h b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.h
index a8a267b..2d08c15 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.h
@@ -172,19 +172,19 @@ struct si_info {
 
 
 /* AMBA Interconnect exported externs */
-extern u32 ai_core_cflags(struct bcma_device *core, u32 mask, u32 val);
+u32 ai_core_cflags(struct bcma_device *core, u32 mask, u32 val);
 
 /* === exported functions === */
-extern struct si_pub *ai_attach(struct bcma_bus *pbus);
-extern void ai_detach(struct si_pub *sih);
-extern uint ai_cc_reg(struct si_pub *sih, uint regoff, u32 mask, u32 val);
-extern void ai_clkctl_init(struct si_pub *sih);
-extern u16 ai_clkctl_fast_pwrup_delay(struct si_pub *sih);
-extern bool ai_clkctl_cc(struct si_pub *sih, enum bcma_clkmode mode);
-extern bool ai_deviceremoved(struct si_pub *sih);
+struct si_pub *ai_attach(struct bcma_bus *pbus);
+void ai_detach(struct si_pub *sih);
+uint ai_cc_reg(struct si_pub *sih, uint regoff, u32 mask, u32 val);
+void ai_clkctl_init(struct si_pub *sih);
+u16 ai_clkctl_fast_pwrup_delay(struct si_pub *sih);
+bool ai_clkctl_cc(struct si_pub *sih, enum bcma_clkmode mode);
+bool ai_deviceremoved(struct si_pub *sih);
 
 /* Enable Ex-PA for 4313 */
-extern void ai_epa_4313war(struct si_pub *sih);
+void ai_epa_4313war(struct si_pub *sih);
 
 static inline u32 ai_get_cccaps(struct si_pub *sih)
 {
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.h b/drivers/net/wireless/brcm80211/brcmsmac/ampdu.h
index 73d01e5..03bdcf2 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/ampdu.h
@@ -37,17 +37,17 @@ struct brcms_ampdu_session {
 	u16 dma_len;
 };
 
-extern void brcms_c_ampdu_reset_session(struct brcms_ampdu_session *session,
-					struct brcms_c_info *wlc);
-extern int brcms_c_ampdu_add_frame(struct brcms_ampdu_session *session,
-				   struct sk_buff *p);
-extern void brcms_c_ampdu_finalize(struct brcms_ampdu_session *session);
+void brcms_c_ampdu_reset_session(struct brcms_ampdu_session *session,
+				 struct brcms_c_info *wlc);
+int brcms_c_ampdu_add_frame(struct brcms_ampdu_session *session,
+			    struct sk_buff *p);
+void brcms_c_ampdu_finalize(struct brcms_ampdu_session *session);
 
-extern struct ampdu_info *brcms_c_ampdu_attach(struct brcms_c_info *wlc);
-extern void brcms_c_ampdu_detach(struct ampdu_info *ampdu);
-extern void brcms_c_ampdu_dotxstatus(struct ampdu_info *ampdu, struct scb *scb,
-				 struct sk_buff *p, struct tx_status *txs);
-extern void brcms_c_ampdu_macaddr_upd(struct brcms_c_info *wlc);
-extern void brcms_c_ampdu_shm_upd(struct ampdu_info *ampdu);
+struct ampdu_info *brcms_c_ampdu_attach(struct brcms_c_info *wlc);
+void brcms_c_ampdu_detach(struct ampdu_info *ampdu);
+void brcms_c_ampdu_dotxstatus(struct ampdu_info *ampdu, struct scb *scb,
+			      struct sk_buff *p, struct tx_status *txs);
+void brcms_c_ampdu_macaddr_upd(struct brcms_c_info *wlc);
+void brcms_c_ampdu_shm_upd(struct ampdu_info *ampdu);
 
 #endif				/* _BRCM_AMPDU_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/antsel.h b/drivers/net/wireless/brcm80211/brcmsmac/antsel.h
index 97ea388..a3d487a 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/antsel.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/antsel.h
@@ -17,13 +17,11 @@
 #ifndef _BRCM_ANTSEL_H_
 #define _BRCM_ANTSEL_H_
 
-extern struct antsel_info *brcms_c_antsel_attach(struct brcms_c_info *wlc);
-extern void brcms_c_antsel_detach(struct antsel_info *asi);
-extern void brcms_c_antsel_init(struct antsel_info *asi);
-extern void brcms_c_antsel_antcfg_get(struct antsel_info *asi, bool usedef,
-				  bool sel,
-				  u8 id, u8 fbid, u8 *antcfg,
-				  u8 *fbantcfg);
-extern u8 brcms_c_antsel_antsel2id(struct antsel_info *asi, u16 antsel);
+struct antsel_info *brcms_c_antsel_attach(struct brcms_c_info *wlc);
+void brcms_c_antsel_detach(struct antsel_info *asi);
+void brcms_c_antsel_init(struct antsel_info *asi);
+void brcms_c_antsel_antcfg_get(struct antsel_info *asi, bool usedef, bool sel,
+			       u8 id, u8 fbid, u8 *antcfg, u8 *fbantcfg);
+u8 brcms_c_antsel_antsel2id(struct antsel_info *asi, u16 antsel);
 
 #endif /* _BRCM_ANTSEL_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/channel.h b/drivers/net/wireless/brcm80211/brcmsmac/channel.h
index 006483a..39dd3a5 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/channel.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/channel.h
@@ -32,20 +32,16 @@
 
 #define BRCMS_DFS_EU (BRCMS_DFS_TPC | BRCMS_RADAR_TYPE_EU) /* Flag for DFS EU */
 
-extern struct brcms_cm_info *
-brcms_c_channel_mgr_attach(struct brcms_c_info *wlc);
+struct brcms_cm_info *brcms_c_channel_mgr_attach(struct brcms_c_info *wlc);
 
-extern void brcms_c_channel_mgr_detach(struct brcms_cm_info *wlc_cm);
+void brcms_c_channel_mgr_detach(struct brcms_cm_info *wlc_cm);
 
-extern bool brcms_c_valid_chanspec_db(struct brcms_cm_info *wlc_cm,
-				      u16 chspec);
+bool brcms_c_valid_chanspec_db(struct brcms_cm_info *wlc_cm, u16 chspec);
 
-extern void brcms_c_channel_reg_limits(struct brcms_cm_info *wlc_cm,
-				   u16 chanspec,
-				   struct txpwr_limits *txpwr);
-extern void brcms_c_channel_set_chanspec(struct brcms_cm_info *wlc_cm,
-				     u16 chanspec,
-				     u8 local_constraint_qdbm);
-extern void brcms_c_regd_init(struct brcms_c_info *wlc);
+void brcms_c_channel_reg_limits(struct brcms_cm_info *wlc_cm, u16 chanspec,
+				struct txpwr_limits *txpwr);
+void brcms_c_channel_set_chanspec(struct brcms_cm_info *wlc_cm, u16 chanspec,
+				  u8 local_constraint_qdbm);
+void brcms_c_regd_init(struct brcms_c_info *wlc);
 
 #endif				/* _WLC_CHANNEL_H */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
index 4090032..198053d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
@@ -88,26 +88,26 @@ struct brcms_info {
 };
 
 /* misc callbacks */
-extern void brcms_init(struct brcms_info *wl);
-extern uint brcms_reset(struct brcms_info *wl);
-extern void brcms_intrson(struct brcms_info *wl);
-extern u32 brcms_intrsoff(struct brcms_info *wl);
-extern void brcms_intrsrestore(struct brcms_info *wl, u32 macintmask);
-extern int brcms_up(struct brcms_info *wl);
-extern void brcms_down(struct brcms_info *wl);
-extern void brcms_txflowcontrol(struct brcms_info *wl, struct brcms_if *wlif,
-				bool state, int prio);
-extern bool brcms_rfkill_set_hw_state(struct brcms_info *wl);
+void brcms_init(struct brcms_info *wl);
+uint brcms_reset(struct brcms_info *wl);
+void brcms_intrson(struct brcms_info *wl);
+u32 brcms_intrsoff(struct brcms_info *wl);
+void brcms_intrsrestore(struct brcms_info *wl, u32 macintmask);
+int brcms_up(struct brcms_info *wl);
+void brcms_down(struct brcms_info *wl);
+void brcms_txflowcontrol(struct brcms_info *wl, struct brcms_if *wlif,
+			 bool state, int prio);
+bool brcms_rfkill_set_hw_state(struct brcms_info *wl);
 
 /* timer functions */
-extern struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
-				      void (*fn) (void *arg), void *arg,
-				      const char *name);
-extern void brcms_free_timer(struct brcms_timer *timer);
-extern void brcms_add_timer(struct brcms_timer *timer, uint ms, int periodic);
-extern bool brcms_del_timer(struct brcms_timer *timer);
-extern void brcms_dpc(unsigned long data);
-extern void brcms_timer(struct brcms_timer *t);
-extern void brcms_fatal_error(struct brcms_info *wl);
+struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
+				     void (*fn) (void *arg), void *arg,
+				     const char *name);
+void brcms_free_timer(struct brcms_timer *timer);
+void brcms_add_timer(struct brcms_timer *timer, uint ms, int periodic);
+bool brcms_del_timer(struct brcms_timer *timer);
+void brcms_dpc(unsigned long data);
+void brcms_timer(struct brcms_timer *t);
+void brcms_fatal_error(struct brcms_info *wl);
 
 #endif				/* _BRCM_MAC80211_IF_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.h b/drivers/net/wireless/brcm80211/brcmsmac/main.h
index b5d7a38..c4d135c 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.h
@@ -616,66 +616,54 @@ struct brcms_bss_cfg {
 	struct brcms_bss_info *current_bss;
 };
 
-extern int brcms_c_txfifo(struct brcms_c_info *wlc, uint fifo,
-			   struct sk_buff *p);
-extern int brcms_b_xmtfifo_sz_get(struct brcms_hardware *wlc_hw, uint fifo,
-		   uint *blocks);
-
-extern int brcms_c_set_gmode(struct brcms_c_info *wlc, u8 gmode, bool config);
-extern void brcms_c_mac_promisc(struct brcms_c_info *wlc, uint filter_flags);
-extern u16 brcms_c_calc_lsig_len(struct brcms_c_info *wlc, u32 ratespec,
-				uint mac_len);
-extern u32 brcms_c_rspec_to_rts_rspec(struct brcms_c_info *wlc,
-					     u32 rspec,
-					     bool use_rspec, u16 mimo_ctlchbw);
-extern u16 brcms_c_compute_rtscts_dur(struct brcms_c_info *wlc, bool cts_only,
-				      u32 rts_rate,
-				      u32 frame_rate,
-				      u8 rts_preamble_type,
-				      u8 frame_preamble_type, uint frame_len,
-				      bool ba);
-extern void brcms_c_inval_dma_pkts(struct brcms_hardware *hw,
-			       struct ieee80211_sta *sta,
-			       void (*dma_callback_fn));
-extern void brcms_c_update_probe_resp(struct brcms_c_info *wlc, bool suspend);
-extern int brcms_c_set_nmode(struct brcms_c_info *wlc);
-extern void brcms_c_beacon_phytxctl_txant_upd(struct brcms_c_info *wlc,
-					  u32 bcn_rate);
-extern void brcms_b_antsel_type_set(struct brcms_hardware *wlc_hw,
-				     u8 antsel_type);
-extern void brcms_b_set_chanspec(struct brcms_hardware *wlc_hw,
-				  u16 chanspec,
-				  bool mute, struct txpwr_limits *txpwr);
-extern void brcms_b_write_shm(struct brcms_hardware *wlc_hw, uint offset,
-			      u16 v);
-extern u16 brcms_b_read_shm(struct brcms_hardware *wlc_hw, uint offset);
-extern void brcms_b_mhf(struct brcms_hardware *wlc_hw, u8 idx, u16 mask,
-			u16 val, int bands);
-extern void brcms_b_corereset(struct brcms_hardware *wlc_hw, u32 flags);
-extern void brcms_b_mctrl(struct brcms_hardware *wlc_hw, u32 mask, u32 val);
-extern void brcms_b_phy_reset(struct brcms_hardware *wlc_hw);
-extern void brcms_b_bw_set(struct brcms_hardware *wlc_hw, u16 bw);
-extern void brcms_b_core_phypll_reset(struct brcms_hardware *wlc_hw);
-extern void brcms_c_ucode_wake_override_set(struct brcms_hardware *wlc_hw,
-					u32 override_bit);
-extern void brcms_c_ucode_wake_override_clear(struct brcms_hardware *wlc_hw,
-					  u32 override_bit);
-extern void brcms_b_write_template_ram(struct brcms_hardware *wlc_hw,
-				       int offset, int len, void *buf);
-extern u16 brcms_b_rate_shm_offset(struct brcms_hardware *wlc_hw, u8 rate);
-extern void brcms_b_copyto_objmem(struct brcms_hardware *wlc_hw,
-				   uint offset, const void *buf, int len,
-				   u32 sel);
-extern void brcms_b_copyfrom_objmem(struct brcms_hardware *wlc_hw, uint offset,
-				     void *buf, int len, u32 sel);
-extern void brcms_b_switch_macfreq(struct brcms_hardware *wlc_hw, u8 spurmode);
-extern u16 brcms_b_get_txant(struct brcms_hardware *wlc_hw);
-extern void brcms_b_phyclk_fgc(struct brcms_hardware *wlc_hw, bool clk);
-extern void brcms_b_macphyclk_set(struct brcms_hardware *wlc_hw, bool clk);
-extern void brcms_b_core_phypll_ctl(struct brcms_hardware *wlc_hw, bool on);
-extern void brcms_b_txant_set(struct brcms_hardware *wlc_hw, u16 phytxant);
-extern void brcms_b_band_stf_ss_set(struct brcms_hardware *wlc_hw,
-				    u8 stf_mode);
-extern void brcms_c_init_scb(struct scb *scb);
+int brcms_c_txfifo(struct brcms_c_info *wlc, uint fifo, struct sk_buff *p);
+int brcms_b_xmtfifo_sz_get(struct brcms_hardware *wlc_hw, uint fifo,
+			   uint *blocks);
+
+int brcms_c_set_gmode(struct brcms_c_info *wlc, u8 gmode, bool config);
+void brcms_c_mac_promisc(struct brcms_c_info *wlc, uint filter_flags);
+u16 brcms_c_calc_lsig_len(struct brcms_c_info *wlc, u32 ratespec, uint mac_len);
+u32 brcms_c_rspec_to_rts_rspec(struct brcms_c_info *wlc, u32 rspec,
+			       bool use_rspec, u16 mimo_ctlchbw);
+u16 brcms_c_compute_rtscts_dur(struct brcms_c_info *wlc, bool cts_only,
+			       u32 rts_rate, u32 frame_rate,
+			       u8 rts_preamble_type, u8 frame_preamble_type,
+			       uint frame_len, bool ba);
+void brcms_c_inval_dma_pkts(struct brcms_hardware *hw,
+			    struct ieee80211_sta *sta, void (*dma_callback_fn));
+void brcms_c_update_probe_resp(struct brcms_c_info *wlc, bool suspend);
+int brcms_c_set_nmode(struct brcms_c_info *wlc);
+void brcms_c_beacon_phytxctl_txant_upd(struct brcms_c_info *wlc, u32 bcn_rate);
+void brcms_b_antsel_type_set(struct brcms_hardware *wlc_hw, u8 antsel_type);
+void brcms_b_set_chanspec(struct brcms_hardware *wlc_hw, u16 chanspec,
+			  bool mute, struct txpwr_limits *txpwr);
+void brcms_b_write_shm(struct brcms_hardware *wlc_hw, uint offset, u16 v);
+u16 brcms_b_read_shm(struct brcms_hardware *wlc_hw, uint offset);
+void brcms_b_mhf(struct brcms_hardware *wlc_hw, u8 idx, u16 mask, u16 val,
+		 int bands);
+void brcms_b_corereset(struct brcms_hardware *wlc_hw, u32 flags);
+void brcms_b_mctrl(struct brcms_hardware *wlc_hw, u32 mask, u32 val);
+void brcms_b_phy_reset(struct brcms_hardware *wlc_hw);
+void brcms_b_bw_set(struct brcms_hardware *wlc_hw, u16 bw);
+void brcms_b_core_phypll_reset(struct brcms_hardware *wlc_hw);
+void brcms_c_ucode_wake_override_set(struct brcms_hardware *wlc_hw,
+				     u32 override_bit);
+void brcms_c_ucode_wake_override_clear(struct brcms_hardware *wlc_hw,
+				       u32 override_bit);
+void brcms_b_write_template_ram(struct brcms_hardware *wlc_hw, int offset,
+				int len, void *buf);
+u16 brcms_b_rate_shm_offset(struct brcms_hardware *wlc_hw, u8 rate);
+void brcms_b_copyto_objmem(struct brcms_hardware *wlc_hw, uint offset,
+			   const void *buf, int len, u32 sel);
+void brcms_b_copyfrom_objmem(struct brcms_hardware *wlc_hw, uint offset,
+			     void *buf, int len, u32 sel);
+void brcms_b_switch_macfreq(struct brcms_hardware *wlc_hw, u8 spurmode);
+u16 brcms_b_get_txant(struct brcms_hardware *wlc_hw);
+void brcms_b_phyclk_fgc(struct brcms_hardware *wlc_hw, bool clk);
+void brcms_b_macphyclk_set(struct brcms_hardware *wlc_hw, bool clk);
+void brcms_b_core_phypll_ctl(struct brcms_hardware *wlc_hw, bool on);
+void brcms_b_txant_set(struct brcms_hardware *wlc_hw, u16 phytxant);
+void brcms_b_band_stf_ss_set(struct brcms_hardware *wlc_hw, u8 stf_mode);
+void brcms_c_init_scb(struct scb *scb);
 
 #endif				/* _BRCM_MAIN_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
index e34a71e..4d3734f 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
@@ -179,121 +179,106 @@ struct shared_phy_params {
 };
 
 
-extern struct shared_phy *wlc_phy_shared_attach(struct shared_phy_params *shp);
-extern struct brcms_phy_pub *wlc_phy_attach(struct shared_phy *sh,
-					    struct bcma_device *d11core,
-					    int bandtype, struct wiphy *wiphy);
-extern void wlc_phy_detach(struct brcms_phy_pub *ppi);
-
-extern bool wlc_phy_get_phyversion(struct brcms_phy_pub *pih, u16 *phytype,
-				   u16 *phyrev, u16 *radioid,
-				   u16 *radiover);
-extern bool wlc_phy_get_encore(struct brcms_phy_pub *pih);
-extern u32 wlc_phy_get_coreflags(struct brcms_phy_pub *pih);
-
-extern void wlc_phy_hw_clk_state_upd(struct brcms_phy_pub *ppi, bool newstate);
-extern void wlc_phy_hw_state_upd(struct brcms_phy_pub *ppi, bool newstate);
-extern void wlc_phy_init(struct brcms_phy_pub *ppi, u16 chanspec);
-extern void wlc_phy_watchdog(struct brcms_phy_pub *ppi);
-extern int wlc_phy_down(struct brcms_phy_pub *ppi);
-extern u32 wlc_phy_clk_bwbits(struct brcms_phy_pub *pih);
-extern void wlc_phy_cal_init(struct brcms_phy_pub *ppi);
-extern void wlc_phy_antsel_init(struct brcms_phy_pub *ppi, bool lut_init);
-
-extern void wlc_phy_chanspec_set(struct brcms_phy_pub *ppi,
-				 u16 chanspec);
-extern u16 wlc_phy_chanspec_get(struct brcms_phy_pub *ppi);
-extern void wlc_phy_chanspec_radio_set(struct brcms_phy_pub *ppi,
-				       u16 newch);
-extern u16 wlc_phy_bw_state_get(struct brcms_phy_pub *ppi);
-extern void wlc_phy_bw_state_set(struct brcms_phy_pub *ppi, u16 bw);
-
-extern int wlc_phy_rssi_compute(struct brcms_phy_pub *pih,
-				struct d11rxhdr *rxh);
-extern void wlc_phy_por_inform(struct brcms_phy_pub *ppi);
-extern void wlc_phy_noise_sample_intr(struct brcms_phy_pub *ppi);
-extern bool wlc_phy_bist_check_phy(struct brcms_phy_pub *ppi);
-
-extern void wlc_phy_set_deaf(struct brcms_phy_pub *ppi, bool user_flag);
-
-extern void wlc_phy_switch_radio(struct brcms_phy_pub *ppi, bool on);
-extern void wlc_phy_anacore(struct brcms_phy_pub *ppi, bool on);
-
-
-extern void wlc_phy_BSSinit(struct brcms_phy_pub *ppi, bool bonlyap, int rssi);
-
-extern void wlc_phy_chanspec_ch14_widefilter_set(struct brcms_phy_pub *ppi,
-						 bool wide_filter);
-extern void wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
-					  struct brcms_chanvec *channels);
-extern u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi,
-					 uint band);
-
-extern void wlc_phy_txpower_sromlimit(struct brcms_phy_pub *ppi, uint chan,
-				      u8 *_min_, u8 *_max_, int rate);
-extern void wlc_phy_txpower_sromlimit_max_get(struct brcms_phy_pub *ppi,
-					      uint chan, u8 *_max_, u8 *_min_);
-extern void wlc_phy_txpower_boardlimit_band(struct brcms_phy_pub *ppi,
-					    uint band, s32 *, s32 *, u32 *);
-extern void wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi,
-				      struct txpwr_limits *,
-				      u16 chanspec);
-extern int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm,
-			       bool *override);
-extern int wlc_phy_txpower_set(struct brcms_phy_pub *ppi, uint qdbm,
-			       bool override);
-extern void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
-				       struct txpwr_limits *);
-extern bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi);
-extern void wlc_phy_txpower_hw_ctrl_set(struct brcms_phy_pub *ppi,
-					bool hwpwrctrl);
-extern u8 wlc_phy_txpower_get_target_min(struct brcms_phy_pub *ppi);
-extern u8 wlc_phy_txpower_get_target_max(struct brcms_phy_pub *ppi);
-extern bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *pih);
-
-extern void wlc_phy_stf_chain_init(struct brcms_phy_pub *pih, u8 txchain,
-				   u8 rxchain);
-extern void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain,
-				  u8 rxchain);
-extern void wlc_phy_stf_chain_get(struct brcms_phy_pub *pih, u8 *txchain,
-				  u8 *rxchain);
-extern u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih);
-extern s8 wlc_phy_stf_ssmode_get(struct brcms_phy_pub *pih,
-				 u16 chanspec);
-extern void wlc_phy_ldpc_override_set(struct brcms_phy_pub *ppi, bool val);
-
-extern void wlc_phy_cal_perical(struct brcms_phy_pub *ppi, u8 reason);
-extern void wlc_phy_noise_sample_request_external(struct brcms_phy_pub *ppi);
-extern void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock);
-extern void wlc_phy_cal_papd_recal(struct brcms_phy_pub *ppi);
-
-extern void wlc_phy_ant_rxdiv_set(struct brcms_phy_pub *ppi, u8 val);
-extern void wlc_phy_clear_tssi(struct brcms_phy_pub *ppi);
-extern void wlc_phy_hold_upd(struct brcms_phy_pub *ppi, u32 id, bool val);
-extern void wlc_phy_mute_upd(struct brcms_phy_pub *ppi, bool val, u32 flags);
-
-extern void wlc_phy_antsel_type_set(struct brcms_phy_pub *ppi, u8 antsel_type);
-
-extern void wlc_phy_txpower_get_current(struct brcms_phy_pub *ppi,
-					struct tx_power *power, uint channel);
-
-extern void wlc_phy_initcal_enable(struct brcms_phy_pub *pih, bool initcal);
-extern bool wlc_phy_test_ison(struct brcms_phy_pub *ppi);
-extern void wlc_phy_txpwr_percent_set(struct brcms_phy_pub *ppi,
-				      u8 txpwr_percent);
-extern void wlc_phy_ofdm_rateset_war(struct brcms_phy_pub *pih, bool war);
-extern void wlc_phy_bf_preempt_enable(struct brcms_phy_pub *pih,
-				      bool bf_preempt);
-extern void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap);
-
-extern void wlc_phy_runbist_config(struct brcms_phy_pub *ppi, bool start_end);
-
-extern void wlc_phy_freqtrack_start(struct brcms_phy_pub *ppi);
-extern void wlc_phy_freqtrack_end(struct brcms_phy_pub *ppi);
-
-extern const u8 *wlc_phy_get_ofdm_rate_lookup(void);
-
-extern s8 wlc_phy_get_tx_power_offset_by_mcs(struct brcms_phy_pub *ppi,
-					     u8 mcs_offset);
-extern s8 wlc_phy_get_tx_power_offset(struct brcms_phy_pub *ppi, u8 tbl_offset);
+struct shared_phy *wlc_phy_shared_attach(struct shared_phy_params *shp);
+struct brcms_phy_pub *wlc_phy_attach(struct shared_phy *sh,
+				     struct bcma_device *d11core, int bandtype,
+				     struct wiphy *wiphy);
+void wlc_phy_detach(struct brcms_phy_pub *ppi);
+
+bool wlc_phy_get_phyversion(struct brcms_phy_pub *pih, u16 *phytype,
+			    u16 *phyrev, u16 *radioid, u16 *radiover);
+bool wlc_phy_get_encore(struct brcms_phy_pub *pih);
+u32 wlc_phy_get_coreflags(struct brcms_phy_pub *pih);
+
+void wlc_phy_hw_clk_state_upd(struct brcms_phy_pub *ppi, bool newstate);
+void wlc_phy_hw_state_upd(struct brcms_phy_pub *ppi, bool newstate);
+void wlc_phy_init(struct brcms_phy_pub *ppi, u16 chanspec);
+void wlc_phy_watchdog(struct brcms_phy_pub *ppi);
+int wlc_phy_down(struct brcms_phy_pub *ppi);
+u32 wlc_phy_clk_bwbits(struct brcms_phy_pub *pih);
+void wlc_phy_cal_init(struct brcms_phy_pub *ppi);
+void wlc_phy_antsel_init(struct brcms_phy_pub *ppi, bool lut_init);
+
+void wlc_phy_chanspec_set(struct brcms_phy_pub *ppi, u16 chanspec);
+u16 wlc_phy_chanspec_get(struct brcms_phy_pub *ppi);
+void wlc_phy_chanspec_radio_set(struct brcms_phy_pub *ppi, u16 newch);
+u16 wlc_phy_bw_state_get(struct brcms_phy_pub *ppi);
+void wlc_phy_bw_state_set(struct brcms_phy_pub *ppi, u16 bw);
+
+int wlc_phy_rssi_compute(struct brcms_phy_pub *pih, struct d11rxhdr *rxh);
+void wlc_phy_por_inform(struct brcms_phy_pub *ppi);
+void wlc_phy_noise_sample_intr(struct brcms_phy_pub *ppi);
+bool wlc_phy_bist_check_phy(struct brcms_phy_pub *ppi);
+
+void wlc_phy_set_deaf(struct brcms_phy_pub *ppi, bool user_flag);
+
+void wlc_phy_switch_radio(struct brcms_phy_pub *ppi, bool on);
+void wlc_phy_anacore(struct brcms_phy_pub *ppi, bool on);
+
+
+void wlc_phy_BSSinit(struct brcms_phy_pub *ppi, bool bonlyap, int rssi);
+
+void wlc_phy_chanspec_ch14_widefilter_set(struct brcms_phy_pub *ppi,
+					  bool wide_filter);
+void wlc_phy_chanspec_band_validch(struct brcms_phy_pub *ppi, uint band,
+				   struct brcms_chanvec *channels);
+u16 wlc_phy_chanspec_band_firstch(struct brcms_phy_pub *ppi, uint band);
+
+void wlc_phy_txpower_sromlimit(struct brcms_phy_pub *ppi, uint chan, u8 *_min_,
+			       u8 *_max_, int rate);
+void wlc_phy_txpower_sromlimit_max_get(struct brcms_phy_pub *ppi, uint chan,
+				       u8 *_max_, u8 *_min_);
+void wlc_phy_txpower_boardlimit_band(struct brcms_phy_pub *ppi, uint band,
+				     s32 *, s32 *, u32 *);
+void wlc_phy_txpower_limit_set(struct brcms_phy_pub *ppi, struct txpwr_limits *,
+			       u16 chanspec);
+int wlc_phy_txpower_get(struct brcms_phy_pub *ppi, uint *qdbm, bool *override);
+int wlc_phy_txpower_set(struct brcms_phy_pub *ppi, uint qdbm, bool override);
+void wlc_phy_txpower_target_set(struct brcms_phy_pub *ppi,
+				struct txpwr_limits *);
+bool wlc_phy_txpower_hw_ctrl_get(struct brcms_phy_pub *ppi);
+void wlc_phy_txpower_hw_ctrl_set(struct brcms_phy_pub *ppi, bool hwpwrctrl);
+u8 wlc_phy_txpower_get_target_min(struct brcms_phy_pub *ppi);
+u8 wlc_phy_txpower_get_target_max(struct brcms_phy_pub *ppi);
+bool wlc_phy_txpower_ipa_ison(struct brcms_phy_pub *pih);
+
+void wlc_phy_stf_chain_init(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain);
+void wlc_phy_stf_chain_set(struct brcms_phy_pub *pih, u8 txchain, u8 rxchain);
+void wlc_phy_stf_chain_get(struct brcms_phy_pub *pih, u8 *txchain, u8 *rxchain);
+u8 wlc_phy_stf_chain_active_get(struct brcms_phy_pub *pih);
+s8 wlc_phy_stf_ssmode_get(struct brcms_phy_pub *pih, u16 chanspec);
+void wlc_phy_ldpc_override_set(struct brcms_phy_pub *ppi, bool val);
+
+void wlc_phy_cal_perical(struct brcms_phy_pub *ppi, u8 reason);
+void wlc_phy_noise_sample_request_external(struct brcms_phy_pub *ppi);
+void wlc_phy_edcrs_lock(struct brcms_phy_pub *pih, bool lock);
+void wlc_phy_cal_papd_recal(struct brcms_phy_pub *ppi);
+
+void wlc_phy_ant_rxdiv_set(struct brcms_phy_pub *ppi, u8 val);
+void wlc_phy_clear_tssi(struct brcms_phy_pub *ppi);
+void wlc_phy_hold_upd(struct brcms_phy_pub *ppi, u32 id, bool val);
+void wlc_phy_mute_upd(struct brcms_phy_pub *ppi, bool val, u32 flags);
+
+void wlc_phy_antsel_type_set(struct brcms_phy_pub *ppi, u8 antsel_type);
+
+void wlc_phy_txpower_get_current(struct brcms_phy_pub *ppi,
+				 struct tx_power *power, uint channel);
+
+void wlc_phy_initcal_enable(struct brcms_phy_pub *pih, bool initcal);
+bool wlc_phy_test_ison(struct brcms_phy_pub *ppi);
+void wlc_phy_txpwr_percent_set(struct brcms_phy_pub *ppi, u8 txpwr_percent);
+void wlc_phy_ofdm_rateset_war(struct brcms_phy_pub *pih, bool war);
+void wlc_phy_bf_preempt_enable(struct brcms_phy_pub *pih, bool bf_preempt);
+void wlc_phy_machwcap_set(struct brcms_phy_pub *ppi, u32 machwcap);
+
+void wlc_phy_runbist_config(struct brcms_phy_pub *ppi, bool start_end);
+
+void wlc_phy_freqtrack_start(struct brcms_phy_pub *ppi);
+void wlc_phy_freqtrack_end(struct brcms_phy_pub *ppi);
+
+const u8 *wlc_phy_get_ofdm_rate_lookup(void);
+
+s8 wlc_phy_get_tx_power_offset_by_mcs(struct brcms_phy_pub *ppi,
+				      u8 mcs_offset);
+s8 wlc_phy_get_tx_power_offset(struct brcms_phy_pub *ppi, u8 tbl_offset);
 #endif                          /* _BRCM_PHY_HAL_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
index 1dc767c..4960f7d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
@@ -910,113 +910,103 @@ struct lcnphy_radio_regs {
 	u8 do_init_g;
 };
 
-extern u16 read_phy_reg(struct brcms_phy *pi, u16 addr);
-extern void write_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
-extern void and_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
-extern void or_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
-extern void mod_phy_reg(struct brcms_phy *pi, u16 addr, u16 mask, u16 val);
-
-extern u16 read_radio_reg(struct brcms_phy *pi, u16 addr);
-extern void or_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
-extern void and_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
-extern void mod_radio_reg(struct brcms_phy *pi, u16 addr, u16 mask,
-			  u16 val);
-extern void xor_radio_reg(struct brcms_phy *pi, u16 addr, u16 mask);
-
-extern void write_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
-
-extern void wlc_phyreg_enter(struct brcms_phy_pub *pih);
-extern void wlc_phyreg_exit(struct brcms_phy_pub *pih);
-extern void wlc_radioreg_enter(struct brcms_phy_pub *pih);
-extern void wlc_radioreg_exit(struct brcms_phy_pub *pih);
-
-extern void wlc_phy_read_table(struct brcms_phy *pi,
-			       const struct phytbl_info *ptbl_info,
-			       u16 tblAddr, u16 tblDataHi,
-			       u16 tblDatalo);
-extern void wlc_phy_write_table(struct brcms_phy *pi,
-				const struct phytbl_info *ptbl_info,
-				u16 tblAddr, u16 tblDataHi, u16 tblDatalo);
-extern void wlc_phy_table_addr(struct brcms_phy *pi, uint tbl_id,
-			       uint tbl_offset, u16 tblAddr, u16 tblDataHi,
-			       u16 tblDataLo);
-extern void wlc_phy_table_data_write(struct brcms_phy *pi, uint width, u32 val);
-
-extern void write_phy_channel_reg(struct brcms_phy *pi, uint val);
-extern void wlc_phy_txpower_update_shm(struct brcms_phy *pi);
-
-extern u8 wlc_phy_nbits(s32 value);
-extern void wlc_phy_compute_dB(u32 *cmplx_pwr, s8 *p_dB, u8 core);
-
-extern uint wlc_phy_init_radio_regs_allbands(struct brcms_phy *pi,
-					     struct radio_20xx_regs *radioregs);
-extern uint wlc_phy_init_radio_regs(struct brcms_phy *pi,
-				    const struct radio_regs *radioregs,
-				    u16 core_offset);
-
-extern void wlc_phy_txpower_ipa_upd(struct brcms_phy *pi);
-
-extern void wlc_phy_do_dummy_tx(struct brcms_phy *pi, bool ofdm, bool pa_on);
-extern void wlc_phy_papd_decode_epsilon(u32 epsilon, s32 *eps_real,
-					s32 *eps_imag);
-
-extern void wlc_phy_cal_perical_mphase_reset(struct brcms_phy *pi);
-extern void wlc_phy_cal_perical_mphase_restart(struct brcms_phy *pi);
-
-extern bool wlc_phy_attach_nphy(struct brcms_phy *pi);
-extern bool wlc_phy_attach_lcnphy(struct brcms_phy *pi);
-
-extern void wlc_phy_detach_lcnphy(struct brcms_phy *pi);
-
-extern void wlc_phy_init_nphy(struct brcms_phy *pi);
-extern void wlc_phy_init_lcnphy(struct brcms_phy *pi);
-
-extern void wlc_phy_cal_init_nphy(struct brcms_phy *pi);
-extern void wlc_phy_cal_init_lcnphy(struct brcms_phy *pi);
-
-extern void wlc_phy_chanspec_set_nphy(struct brcms_phy *pi,
-				      u16 chanspec);
-extern void wlc_phy_chanspec_set_lcnphy(struct brcms_phy *pi,
-					u16 chanspec);
-extern void wlc_phy_chanspec_set_fixup_lcnphy(struct brcms_phy *pi,
-					      u16 chanspec);
-extern int wlc_phy_channel2freq(uint channel);
-extern int wlc_phy_chanspec_freq2bandrange_lpssn(uint);
-extern int wlc_phy_chanspec_bandrange_get(struct brcms_phy *, u16 chanspec);
-
-extern void wlc_lcnphy_set_tx_pwr_ctrl(struct brcms_phy *pi, u16 mode);
-extern s8 wlc_lcnphy_get_current_tx_pwr_idx(struct brcms_phy *pi);
-
-extern void wlc_phy_txpower_recalc_target_nphy(struct brcms_phy *pi);
-extern void wlc_lcnphy_txpower_recalc_target(struct brcms_phy *pi);
-extern void wlc_phy_txpower_recalc_target_lcnphy(struct brcms_phy *pi);
-
-extern void wlc_lcnphy_set_tx_pwr_by_index(struct brcms_phy *pi, int index);
-extern void wlc_lcnphy_tx_pu(struct brcms_phy *pi, bool bEnable);
-extern void wlc_lcnphy_stop_tx_tone(struct brcms_phy *pi);
-extern void wlc_lcnphy_start_tx_tone(struct brcms_phy *pi, s32 f_kHz,
-				     u16 max_val, bool iqcalmode);
-
-extern void wlc_phy_txpower_sromlimit_get_nphy(struct brcms_phy *pi, uint chan,
-					       u8 *max_pwr, u8 rate_id);
-extern void wlc_phy_ofdm_to_mcs_powers_nphy(u8 *power, u8 rate_mcs_start,
-					    u8 rate_mcs_end,
-					    u8 rate_ofdm_start);
-extern void wlc_phy_mcs_to_ofdm_powers_nphy(u8 *power,
-					    u8 rate_ofdm_start,
-					    u8 rate_ofdm_end,
-					    u8 rate_mcs_start);
-
-extern u16 wlc_lcnphy_tempsense(struct brcms_phy *pi, bool mode);
-extern s16 wlc_lcnphy_tempsense_new(struct brcms_phy *pi, bool mode);
-extern s8 wlc_lcnphy_tempsense_degree(struct brcms_phy *pi, bool mode);
-extern s8 wlc_lcnphy_vbatsense(struct brcms_phy *pi, bool mode);
-extern void wlc_phy_carrier_suppress_lcnphy(struct brcms_phy *pi);
-extern void wlc_lcnphy_crsuprs(struct brcms_phy *pi, int channel);
-extern void wlc_lcnphy_epa_switch(struct brcms_phy *pi, bool mode);
-extern void wlc_2064_vco_cal(struct brcms_phy *pi);
-
-extern void wlc_phy_txpower_recalc_target(struct brcms_phy *pi);
+u16 read_phy_reg(struct brcms_phy *pi, u16 addr);
+void write_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
+void and_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
+void or_phy_reg(struct brcms_phy *pi, u16 addr, u16 val);
+void mod_phy_reg(struct brcms_phy *pi, u16 addr, u16 mask, u16 val);
+
+u16 read_radio_reg(struct brcms_phy *pi, u16 addr);
+void or_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
+void and_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
+void mod_radio_reg(struct brcms_phy *pi, u16 addr, u16 mask, u16 val);
+void xor_radio_reg(struct brcms_phy *pi, u16 addr, u16 mask);
+
+void write_radio_reg(struct brcms_phy *pi, u16 addr, u16 val);
+
+void wlc_phyreg_enter(struct brcms_phy_pub *pih);
+void wlc_phyreg_exit(struct brcms_phy_pub *pih);
+void wlc_radioreg_enter(struct brcms_phy_pub *pih);
+void wlc_radioreg_exit(struct brcms_phy_pub *pih);
+
+void wlc_phy_read_table(struct brcms_phy *pi,
+			const struct phytbl_info *ptbl_info,
+			u16 tblAddr, u16 tblDataHi, u16 tblDatalo);
+void wlc_phy_write_table(struct brcms_phy *pi,
+			 const struct phytbl_info *ptbl_info,
+			 u16 tblAddr, u16 tblDataHi, u16 tblDatalo);
+void wlc_phy_table_addr(struct brcms_phy *pi, uint tbl_id, uint tbl_offset,
+			u16 tblAddr, u16 tblDataHi, u16 tblDataLo);
+void wlc_phy_table_data_write(struct brcms_phy *pi, uint width, u32 val);
+
+void write_phy_channel_reg(struct brcms_phy *pi, uint val);
+void wlc_phy_txpower_update_shm(struct brcms_phy *pi);
+
+u8 wlc_phy_nbits(s32 value);
+void wlc_phy_compute_dB(u32 *cmplx_pwr, s8 *p_dB, u8 core);
+
+uint wlc_phy_init_radio_regs_allbands(struct brcms_phy *pi,
+				      struct radio_20xx_regs *radioregs);
+uint wlc_phy_init_radio_regs(struct brcms_phy *pi,
+			     const struct radio_regs *radioregs,
+			     u16 core_offset);
+
+void wlc_phy_txpower_ipa_upd(struct brcms_phy *pi);
+
+void wlc_phy_do_dummy_tx(struct brcms_phy *pi, bool ofdm, bool pa_on);
+void wlc_phy_papd_decode_epsilon(u32 epsilon, s32 *eps_real, s32 *eps_imag);
+
+void wlc_phy_cal_perical_mphase_reset(struct brcms_phy *pi);
+void wlc_phy_cal_perical_mphase_restart(struct brcms_phy *pi);
+
+bool wlc_phy_attach_nphy(struct brcms_phy *pi);
+bool wlc_phy_attach_lcnphy(struct brcms_phy *pi);
+
+void wlc_phy_detach_lcnphy(struct brcms_phy *pi);
+
+void wlc_phy_init_nphy(struct brcms_phy *pi);
+void wlc_phy_init_lcnphy(struct brcms_phy *pi);
+
+void wlc_phy_cal_init_nphy(struct brcms_phy *pi);
+void wlc_phy_cal_init_lcnphy(struct brcms_phy *pi);
+
+void wlc_phy_chanspec_set_nphy(struct brcms_phy *pi, u16 chanspec);
+void wlc_phy_chanspec_set_lcnphy(struct brcms_phy *pi, u16 chanspec);
+void wlc_phy_chanspec_set_fixup_lcnphy(struct brcms_phy *pi, u16 chanspec);
+int wlc_phy_channel2freq(uint channel);
+int wlc_phy_chanspec_freq2bandrange_lpssn(uint);
+int wlc_phy_chanspec_bandrange_get(struct brcms_phy *, u16 chanspec);
+
+void wlc_lcnphy_set_tx_pwr_ctrl(struct brcms_phy *pi, u16 mode);
+s8 wlc_lcnphy_get_current_tx_pwr_idx(struct brcms_phy *pi);
+
+void wlc_phy_txpower_recalc_target_nphy(struct brcms_phy *pi);
+void wlc_lcnphy_txpower_recalc_target(struct brcms_phy *pi);
+void wlc_phy_txpower_recalc_target_lcnphy(struct brcms_phy *pi);
+
+void wlc_lcnphy_set_tx_pwr_by_index(struct brcms_phy *pi, int index);
+void wlc_lcnphy_tx_pu(struct brcms_phy *pi, bool bEnable);
+void wlc_lcnphy_stop_tx_tone(struct brcms_phy *pi);
+void wlc_lcnphy_start_tx_tone(struct brcms_phy *pi, s32 f_kHz, u16 max_val,
+			      bool iqcalmode);
+
+void wlc_phy_txpower_sromlimit_get_nphy(struct brcms_phy *pi, uint chan,
+					u8 *max_pwr, u8 rate_id);
+void wlc_phy_ofdm_to_mcs_powers_nphy(u8 *power, u8 rate_mcs_start,
+				     u8 rate_mcs_end, u8 rate_ofdm_start);
+void wlc_phy_mcs_to_ofdm_powers_nphy(u8 *power, u8 rate_ofdm_start,
+				     u8 rate_ofdm_end, u8 rate_mcs_start);
+
+u16 wlc_lcnphy_tempsense(struct brcms_phy *pi, bool mode);
+s16 wlc_lcnphy_tempsense_new(struct brcms_phy *pi, bool mode);
+s8 wlc_lcnphy_tempsense_degree(struct brcms_phy *pi, bool mode);
+s8 wlc_lcnphy_vbatsense(struct brcms_phy *pi, bool mode);
+void wlc_phy_carrier_suppress_lcnphy(struct brcms_phy *pi);
+void wlc_lcnphy_crsuprs(struct brcms_phy *pi, int channel);
+void wlc_lcnphy_epa_switch(struct brcms_phy *pi, bool mode);
+void wlc_2064_vco_cal(struct brcms_phy *pi);
+
+void wlc_phy_txpower_recalc_target(struct brcms_phy *pi);
 
 #define LCNPHY_TBL_ID_PAPDCOMPDELTATBL	0x18
 #define LCNPHY_TX_POWER_TABLE_SIZE	128
@@ -1030,26 +1020,24 @@ extern void wlc_phy_txpower_recalc_target(struct brcms_phy *pi);
 
 #define LCNPHY_TX_PWR_CTRL_TEMPBASED	0xE001
 
-extern void wlc_lcnphy_write_table(struct brcms_phy *pi,
-				   const struct phytbl_info *pti);
-extern void wlc_lcnphy_read_table(struct brcms_phy *pi,
-				  struct phytbl_info *pti);
-extern void wlc_lcnphy_set_tx_iqcc(struct brcms_phy *pi, u16 a, u16 b);
-extern void wlc_lcnphy_set_tx_locc(struct brcms_phy *pi, u16 didq);
-extern void wlc_lcnphy_get_tx_iqcc(struct brcms_phy *pi, u16 *a, u16 *b);
-extern u16 wlc_lcnphy_get_tx_locc(struct brcms_phy *pi);
-extern void wlc_lcnphy_get_radio_loft(struct brcms_phy *pi, u8 *ei0,
-				      u8 *eq0, u8 *fi0, u8 *fq0);
-extern void wlc_lcnphy_calib_modes(struct brcms_phy *pi, uint mode);
-extern void wlc_lcnphy_deaf_mode(struct brcms_phy *pi, bool mode);
-extern bool wlc_phy_tpc_isenabled_lcnphy(struct brcms_phy *pi);
-extern void wlc_lcnphy_tx_pwr_update_npt(struct brcms_phy *pi);
-extern s32 wlc_lcnphy_tssi2dbm(s32 tssi, s32 a1, s32 b0, s32 b1);
-extern void wlc_lcnphy_get_tssi(struct brcms_phy *pi, s8 *ofdm_pwr,
-				s8 *cck_pwr);
-extern void wlc_lcnphy_tx_power_adjustment(struct brcms_phy_pub *ppi);
-
-extern s32 wlc_lcnphy_rx_signal_power(struct brcms_phy *pi, s32 gain_index);
+void wlc_lcnphy_write_table(struct brcms_phy *pi,
+			    const struct phytbl_info *pti);
+void wlc_lcnphy_read_table(struct brcms_phy *pi, struct phytbl_info *pti);
+void wlc_lcnphy_set_tx_iqcc(struct brcms_phy *pi, u16 a, u16 b);
+void wlc_lcnphy_set_tx_locc(struct brcms_phy *pi, u16 didq);
+void wlc_lcnphy_get_tx_iqcc(struct brcms_phy *pi, u16 *a, u16 *b);
+u16 wlc_lcnphy_get_tx_locc(struct brcms_phy *pi);
+void wlc_lcnphy_get_radio_loft(struct brcms_phy *pi, u8 *ei0, u8 *eq0, u8 *fi0,
+			       u8 *fq0);
+void wlc_lcnphy_calib_modes(struct brcms_phy *pi, uint mode);
+void wlc_lcnphy_deaf_mode(struct brcms_phy *pi, bool mode);
+bool wlc_phy_tpc_isenabled_lcnphy(struct brcms_phy *pi);
+void wlc_lcnphy_tx_pwr_update_npt(struct brcms_phy *pi);
+s32 wlc_lcnphy_tssi2dbm(s32 tssi, s32 a1, s32 b0, s32 b1);
+void wlc_lcnphy_get_tssi(struct brcms_phy *pi, s8 *ofdm_pwr, s8 *cck_pwr);
+void wlc_lcnphy_tx_power_adjustment(struct brcms_phy_pub *ppi);
+
+s32 wlc_lcnphy_rx_signal_power(struct brcms_phy *pi, s32 gain_index);
 
 #define NPHY_MAX_HPVGA1_INDEX		10
 #define NPHY_DEF_HPVGA1_INDEXLIMIT	7
@@ -1060,9 +1048,8 @@ struct phy_iq_est {
 	u32 q_pwr;
 };
 
-extern void wlc_phy_stay_in_carriersearch_nphy(struct brcms_phy *pi,
-					       bool enable);
-extern void wlc_nphy_deaf_mode(struct brcms_phy *pi, bool mode);
+void wlc_phy_stay_in_carriersearch_nphy(struct brcms_phy *pi, bool enable);
+void wlc_nphy_deaf_mode(struct brcms_phy *pi, bool mode);
 
 #define wlc_phy_write_table_nphy(pi, pti) \
 	wlc_phy_write_table(pi, pti, 0x72, 0x74, 0x73)
@@ -1076,10 +1063,10 @@ extern void wlc_nphy_deaf_mode(struct brcms_phy *pi, bool mode);
 #define wlc_nphy_table_data_write(pi, w, v) \
 	wlc_phy_table_data_write((pi), (w), (v))
 
-extern void wlc_phy_table_read_nphy(struct brcms_phy *pi, u32, u32 l, u32 o,
-				    u32 w, void *d);
-extern void wlc_phy_table_write_nphy(struct brcms_phy *pi, u32, u32, u32,
-				     u32, const void *);
+void wlc_phy_table_read_nphy(struct brcms_phy *pi, u32, u32 l, u32 o, u32 w,
+			     void *d);
+void wlc_phy_table_write_nphy(struct brcms_phy *pi, u32, u32, u32, u32,
+			      const void *);
 
 #define	PHY_IPA(pi) \
 	((pi->ipa2g_on && CHSPEC_IS2G(pi->radio_chanspec)) || \
@@ -1089,73 +1076,67 @@ extern void wlc_phy_table_write_nphy(struct brcms_phy *pi, u32, u32, u32,
 	if (NREV_LT((pi)->pubpi.phy_rev, 3)) \
 		(void)bcma_read32(pi->d11core, D11REGOFFS(maccontrol))
 
-extern void wlc_phy_cal_perical_nphy_run(struct brcms_phy *pi, u8 caltype);
-extern void wlc_phy_aci_reset_nphy(struct brcms_phy *pi);
-extern void wlc_phy_pa_override_nphy(struct brcms_phy *pi, bool en);
-
-extern u8 wlc_phy_get_chan_freq_range_nphy(struct brcms_phy *pi, uint chan);
-extern void wlc_phy_switch_radio_nphy(struct brcms_phy *pi, bool on);
-
-extern void wlc_phy_stf_chain_upd_nphy(struct brcms_phy *pi);
-
-extern void wlc_phy_force_rfseq_nphy(struct brcms_phy *pi, u8 cmd);
-extern s16 wlc_phy_tempsense_nphy(struct brcms_phy *pi);
-
-extern u16 wlc_phy_classifier_nphy(struct brcms_phy *pi, u16 mask, u16 val);
-
-extern void wlc_phy_rx_iq_est_nphy(struct brcms_phy *pi, struct phy_iq_est *est,
-				   u16 num_samps, u8 wait_time,
-				   u8 wait_for_crs);
-
-extern void wlc_phy_rx_iq_coeffs_nphy(struct brcms_phy *pi, u8 write,
-				      struct nphy_iq_comp *comp);
-extern void wlc_phy_aci_and_noise_reduction_nphy(struct brcms_phy *pi);
-
-extern void wlc_phy_rxcore_setstate_nphy(struct brcms_phy_pub *pih,
-					 u8 rxcore_bitmask);
-extern u8 wlc_phy_rxcore_getstate_nphy(struct brcms_phy_pub *pih);
-
-extern void wlc_phy_txpwrctrl_enable_nphy(struct brcms_phy *pi, u8 ctrl_type);
-extern void wlc_phy_txpwr_fixpower_nphy(struct brcms_phy *pi);
-extern void wlc_phy_txpwr_apply_nphy(struct brcms_phy *pi);
-extern void wlc_phy_txpwr_papd_cal_nphy(struct brcms_phy *pi);
-extern u16 wlc_phy_txpwr_idx_get_nphy(struct brcms_phy *pi);
-
-extern struct nphy_txgains wlc_phy_get_tx_gain_nphy(struct brcms_phy *pi);
-extern int wlc_phy_cal_txiqlo_nphy(struct brcms_phy *pi,
-				   struct nphy_txgains target_gain,
-				   bool full, bool m);
-extern int wlc_phy_cal_rxiq_nphy(struct brcms_phy *pi,
-				 struct nphy_txgains target_gain,
-				 u8 type, bool d);
-extern void wlc_phy_txpwr_index_nphy(struct brcms_phy *pi, u8 core_mask,
-				     s8 txpwrindex, bool res);
-extern void wlc_phy_rssisel_nphy(struct brcms_phy *pi, u8 core, u8 rssi_type);
-extern int wlc_phy_poll_rssi_nphy(struct brcms_phy *pi, u8 rssi_type,
-				  s32 *rssi_buf, u8 nsamps);
-extern void wlc_phy_rssi_cal_nphy(struct brcms_phy *pi);
-extern int wlc_phy_aci_scan_nphy(struct brcms_phy *pi);
-extern void wlc_phy_cal_txgainctrl_nphy(struct brcms_phy *pi,
-					s32 dBm_targetpower, bool debug);
-extern int wlc_phy_tx_tone_nphy(struct brcms_phy *pi, u32 f_kHz, u16 max_val,
-				u8 mode, u8, bool);
-extern void wlc_phy_stopplayback_nphy(struct brcms_phy *pi);
-extern void wlc_phy_est_tonepwr_nphy(struct brcms_phy *pi, s32 *qdBm_pwrbuf,
-				     u8 num_samps);
-extern void wlc_phy_radio205x_vcocal_nphy(struct brcms_phy *pi);
-
-extern int wlc_phy_rssi_compute_nphy(struct brcms_phy *pi,
-				     struct d11rxhdr *rxh);
+void wlc_phy_cal_perical_nphy_run(struct brcms_phy *pi, u8 caltype);
+void wlc_phy_aci_reset_nphy(struct brcms_phy *pi);
+void wlc_phy_pa_override_nphy(struct brcms_phy *pi, bool en);
+
+u8 wlc_phy_get_chan_freq_range_nphy(struct brcms_phy *pi, uint chan);
+void wlc_phy_switch_radio_nphy(struct brcms_phy *pi, bool on);
+
+void wlc_phy_stf_chain_upd_nphy(struct brcms_phy *pi);
+
+void wlc_phy_force_rfseq_nphy(struct brcms_phy *pi, u8 cmd);
+s16 wlc_phy_tempsense_nphy(struct brcms_phy *pi);
+
+u16 wlc_phy_classifier_nphy(struct brcms_phy *pi, u16 mask, u16 val);
+
+void wlc_phy_rx_iq_est_nphy(struct brcms_phy *pi, struct phy_iq_est *est,
+			    u16 num_samps, u8 wait_time, u8 wait_for_crs);
+
+void wlc_phy_rx_iq_coeffs_nphy(struct brcms_phy *pi, u8 write,
+			       struct nphy_iq_comp *comp);
+void wlc_phy_aci_and_noise_reduction_nphy(struct brcms_phy *pi);
+
+void wlc_phy_rxcore_setstate_nphy(struct brcms_phy_pub *pih, u8 rxcore_bitmask);
+u8 wlc_phy_rxcore_getstate_nphy(struct brcms_phy_pub *pih);
+
+void wlc_phy_txpwrctrl_enable_nphy(struct brcms_phy *pi, u8 ctrl_type);
+void wlc_phy_txpwr_fixpower_nphy(struct brcms_phy *pi);
+void wlc_phy_txpwr_apply_nphy(struct brcms_phy *pi);
+void wlc_phy_txpwr_papd_cal_nphy(struct brcms_phy *pi);
+u16 wlc_phy_txpwr_idx_get_nphy(struct brcms_phy *pi);
+
+struct nphy_txgains wlc_phy_get_tx_gain_nphy(struct brcms_phy *pi);
+int wlc_phy_cal_txiqlo_nphy(struct brcms_phy *pi,
+			    struct nphy_txgains target_gain, bool full, bool m);
+int wlc_phy_cal_rxiq_nphy(struct brcms_phy *pi, struct nphy_txgains target_gain,
+			  u8 type, bool d);
+void wlc_phy_txpwr_index_nphy(struct brcms_phy *pi, u8 core_mask,
+			      s8 txpwrindex, bool res);
+void wlc_phy_rssisel_nphy(struct brcms_phy *pi, u8 core, u8 rssi_type);
+int wlc_phy_poll_rssi_nphy(struct brcms_phy *pi, u8 rssi_type,
+			   s32 *rssi_buf, u8 nsamps);
+void wlc_phy_rssi_cal_nphy(struct brcms_phy *pi);
+int wlc_phy_aci_scan_nphy(struct brcms_phy *pi);
+void wlc_phy_cal_txgainctrl_nphy(struct brcms_phy *pi, s32 dBm_targetpower,
+				 bool debug);
+int wlc_phy_tx_tone_nphy(struct brcms_phy *pi, u32 f_kHz, u16 max_val, u8 mode,
+			 u8, bool);
+void wlc_phy_stopplayback_nphy(struct brcms_phy *pi);
+void wlc_phy_est_tonepwr_nphy(struct brcms_phy *pi, s32 *qdBm_pwrbuf,
+			      u8 num_samps);
+void wlc_phy_radio205x_vcocal_nphy(struct brcms_phy *pi);
+
+int wlc_phy_rssi_compute_nphy(struct brcms_phy *pi, struct d11rxhdr *rxh);
 
 #define NPHY_TESTPATTERN_BPHY_EVM   0
 #define NPHY_TESTPATTERN_BPHY_RFCS  1
 
-extern void wlc_phy_nphy_tkip_rifs_war(struct brcms_phy *pi, u8 rifs);
+void wlc_phy_nphy_tkip_rifs_war(struct brcms_phy *pi, u8 rifs);
 
 void wlc_phy_get_pwrdet_offsets(struct brcms_phy *pi, s8 *cckoffset,
 				s8 *ofdmoffset);
-extern s8 wlc_phy_upd_rssi_offset(struct brcms_phy *pi, s8 rssi,
-				  u16 chanspec);
+s8 wlc_phy_upd_rssi_offset(struct brcms_phy *pi, s8 rssi, u16 chanspec);
 
-extern bool wlc_phy_n_txpower_ipa_ison(struct brcms_phy *pih);
+bool wlc_phy_n_txpower_ipa_ison(struct brcms_phy *pih);
 #endif				/* _BRCM_PHY_INT_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h b/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h
index 2c5b66b..dd87747 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h
@@ -124,56 +124,49 @@
 
 struct brcms_phy;
 
-extern struct phy_shim_info *wlc_phy_shim_attach(struct brcms_hardware *wlc_hw,
-						 struct brcms_info *wl,
-						 struct brcms_c_info *wlc);
-extern void wlc_phy_shim_detach(struct phy_shim_info *physhim);
+struct phy_shim_info *wlc_phy_shim_attach(struct brcms_hardware *wlc_hw,
+					  struct brcms_info *wl,
+					  struct brcms_c_info *wlc);
+void wlc_phy_shim_detach(struct phy_shim_info *physhim);
 
 /* PHY to WL utility functions */
-extern struct wlapi_timer *wlapi_init_timer(struct phy_shim_info *physhim,
-					    void (*fn) (struct brcms_phy *pi),
-					    void *arg, const char *name);
-extern void wlapi_free_timer(struct wlapi_timer *t);
-extern void wlapi_add_timer(struct wlapi_timer *t, uint ms, int periodic);
-extern bool wlapi_del_timer(struct wlapi_timer *t);
-extern void wlapi_intrson(struct phy_shim_info *physhim);
-extern u32 wlapi_intrsoff(struct phy_shim_info *physhim);
-extern void wlapi_intrsrestore(struct phy_shim_info *physhim,
-			       u32 macintmask);
-
-extern void wlapi_bmac_write_shm(struct phy_shim_info *physhim, uint offset,
-				 u16 v);
-extern u16 wlapi_bmac_read_shm(struct phy_shim_info *physhim, uint offset);
-extern void wlapi_bmac_mhf(struct phy_shim_info *physhim, u8 idx,
-			   u16 mask, u16 val, int bands);
-extern void wlapi_bmac_corereset(struct phy_shim_info *physhim, u32 flags);
-extern void wlapi_suspend_mac_and_wait(struct phy_shim_info *physhim);
-extern void wlapi_switch_macfreq(struct phy_shim_info *physhim, u8 spurmode);
-extern void wlapi_enable_mac(struct phy_shim_info *physhim);
-extern void wlapi_bmac_mctrl(struct phy_shim_info *physhim, u32 mask,
-			     u32 val);
-extern void wlapi_bmac_phy_reset(struct phy_shim_info *physhim);
-extern void wlapi_bmac_bw_set(struct phy_shim_info *physhim, u16 bw);
-extern void wlapi_bmac_phyclk_fgc(struct phy_shim_info *physhim, bool clk);
-extern void wlapi_bmac_macphyclk_set(struct phy_shim_info *physhim, bool clk);
-extern void wlapi_bmac_core_phypll_ctl(struct phy_shim_info *physhim, bool on);
-extern void wlapi_bmac_core_phypll_reset(struct phy_shim_info *physhim);
-extern void wlapi_bmac_ucode_wake_override_phyreg_set(struct phy_shim_info *
-						      physhim);
-extern void wlapi_bmac_ucode_wake_override_phyreg_clear(struct phy_shim_info *
-							physhim);
-extern void wlapi_bmac_write_template_ram(struct phy_shim_info *physhim, int o,
-					  int len, void *buf);
-extern u16 wlapi_bmac_rate_shm_offset(struct phy_shim_info *physhim,
-					 u8 rate);
-extern void wlapi_ucode_sample_init(struct phy_shim_info *physhim);
-extern void wlapi_copyfrom_objmem(struct phy_shim_info *physhim, uint,
-				  void *buf, int, u32 sel);
-extern void wlapi_copyto_objmem(struct phy_shim_info *physhim, uint,
-				const void *buf, int, u32);
-
-extern void wlapi_high_update_phy_mode(struct phy_shim_info *physhim,
-				       u32 phy_mode);
-extern u16 wlapi_bmac_get_txant(struct phy_shim_info *physhim);
+struct wlapi_timer *wlapi_init_timer(struct phy_shim_info *physhim,
+				     void (*fn)(struct brcms_phy *pi),
+				     void *arg, const char *name);
+void wlapi_free_timer(struct wlapi_timer *t);
+void wlapi_add_timer(struct wlapi_timer *t, uint ms, int periodic);
+bool wlapi_del_timer(struct wlapi_timer *t);
+void wlapi_intrson(struct phy_shim_info *physhim);
+u32 wlapi_intrsoff(struct phy_shim_info *physhim);
+void wlapi_intrsrestore(struct phy_shim_info *physhim, u32 macintmask);
+
+void wlapi_bmac_write_shm(struct phy_shim_info *physhim, uint offset, u16 v);
+u16 wlapi_bmac_read_shm(struct phy_shim_info *physhim, uint offset);
+void wlapi_bmac_mhf(struct phy_shim_info *physhim, u8 idx, u16 mask, u16 val,
+		    int bands);
+void wlapi_bmac_corereset(struct phy_shim_info *physhim, u32 flags);
+void wlapi_suspend_mac_and_wait(struct phy_shim_info *physhim);
+void wlapi_switch_macfreq(struct phy_shim_info *physhim, u8 spurmode);
+void wlapi_enable_mac(struct phy_shim_info *physhim);
+void wlapi_bmac_mctrl(struct phy_shim_info *physhim, u32 mask, u32 val);
+void wlapi_bmac_phy_reset(struct phy_shim_info *physhim);
+void wlapi_bmac_bw_set(struct phy_shim_info *physhim, u16 bw);
+void wlapi_bmac_phyclk_fgc(struct phy_shim_info *physhim, bool clk);
+void wlapi_bmac_macphyclk_set(struct phy_shim_info *physhim, bool clk);
+void wlapi_bmac_core_phypll_ctl(struct phy_shim_info *physhim, bool on);
+void wlapi_bmac_core_phypll_reset(struct phy_shim_info *physhim);
+void wlapi_bmac_ucode_wake_override_phyreg_set(struct phy_shim_info *physhim);
+void wlapi_bmac_ucode_wake_override_phyreg_clear(struct phy_shim_info *physhim);
+void wlapi_bmac_write_template_ram(struct phy_shim_info *physhim, int o,
+				   int len, void *buf);
+u16 wlapi_bmac_rate_shm_offset(struct phy_shim_info *physhim, u8 rate);
+void wlapi_ucode_sample_init(struct phy_shim_info *physhim);
+void wlapi_copyfrom_objmem(struct phy_shim_info *physhim, uint, void *buf,
+			   int, u32 sel);
+void wlapi_copyto_objmem(struct phy_shim_info *physhim, uint, const void *buf,
+			 int, u32);
+
+void wlapi_high_update_phy_mode(struct phy_shim_info *physhim, u32 phy_mode);
+u16 wlapi_bmac_get_txant(struct phy_shim_info *physhim);
 
 #endif				/* _BRCM_PHY_SHIM_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pmu.h b/drivers/net/wireless/brcm80211/brcmsmac/pmu.h
index 20e2012..a014bbc 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/pmu.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/pmu.h
@@ -20,7 +20,7 @@
 
 #include "types.h"
 
-extern u16 si_pmu_fast_pwrup_delay(struct si_pub *sih);
-extern u32 si_pmu_measure_alpclk(struct si_pub *sih);
+u16 si_pmu_fast_pwrup_delay(struct si_pub *sih);
+u32 si_pmu_measure_alpclk(struct si_pub *sih);
 
 #endif /* _BRCM_PMU_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/pub.h b/drivers/net/wireless/brcm80211/brcmsmac/pub.h
index d36ea5e..4da38cb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/pub.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/pub.h
@@ -266,83 +266,76 @@ struct brcms_antselcfg {
 };
 
 /* common functions for every port */
-extern struct brcms_c_info *
-brcms_c_attach(struct brcms_info *wl, struct bcma_device *core, uint unit,
-	       bool piomode, uint *perr);
-extern uint brcms_c_detach(struct brcms_c_info *wlc);
-extern int brcms_c_up(struct brcms_c_info *wlc);
-extern uint brcms_c_down(struct brcms_c_info *wlc);
-
-extern bool brcms_c_chipmatch(struct bcma_device *core);
-extern void brcms_c_init(struct brcms_c_info *wlc, bool mute_tx);
-extern void brcms_c_reset(struct brcms_c_info *wlc);
-
-extern void brcms_c_intrson(struct brcms_c_info *wlc);
-extern u32 brcms_c_intrsoff(struct brcms_c_info *wlc);
-extern void brcms_c_intrsrestore(struct brcms_c_info *wlc, u32 macintmask);
-extern bool brcms_c_intrsupd(struct brcms_c_info *wlc);
-extern bool brcms_c_isr(struct brcms_c_info *wlc);
-extern bool brcms_c_dpc(struct brcms_c_info *wlc, bool bounded);
-extern bool brcms_c_sendpkt_mac80211(struct brcms_c_info *wlc,
-				     struct sk_buff *sdu,
-				     struct ieee80211_hw *hw);
-extern bool brcms_c_aggregatable(struct brcms_c_info *wlc, u8 tid);
-extern void brcms_c_protection_upd(struct brcms_c_info *wlc, uint idx,
-				   int val);
-extern int brcms_c_get_header_len(void);
-extern void brcms_c_set_addrmatch(struct brcms_c_info *wlc,
-				  int match_reg_offset,
-				  const u8 *addr);
-extern void brcms_c_wme_setparams(struct brcms_c_info *wlc, u16 aci,
-			      const struct ieee80211_tx_queue_params *arg,
-			      bool suspend);
-extern struct brcms_pub *brcms_c_pub(struct brcms_c_info *wlc);
-extern void brcms_c_ampdu_flush(struct brcms_c_info *wlc,
-			    struct ieee80211_sta *sta, u16 tid);
-extern void brcms_c_ampdu_tx_operational(struct brcms_c_info *wlc, u8 tid,
-					 u8 ba_wsize, uint max_rx_ampdu_bytes);
-extern int brcms_c_module_register(struct brcms_pub *pub,
-				   const char *name, struct brcms_info *hdl,
-				   int (*down_fn)(void *handle));
-extern int brcms_c_module_unregister(struct brcms_pub *pub, const char *name,
-				     struct brcms_info *hdl);
-extern void brcms_c_suspend_mac_and_wait(struct brcms_c_info *wlc);
-extern void brcms_c_enable_mac(struct brcms_c_info *wlc);
-extern void brcms_c_associate_upd(struct brcms_c_info *wlc, bool state);
-extern void brcms_c_scan_start(struct brcms_c_info *wlc);
-extern void brcms_c_scan_stop(struct brcms_c_info *wlc);
-extern int brcms_c_get_curband(struct brcms_c_info *wlc);
-extern int brcms_c_set_channel(struct brcms_c_info *wlc, u16 channel);
-extern int brcms_c_set_rate_limit(struct brcms_c_info *wlc, u16 srl, u16 lrl);
-extern void brcms_c_get_current_rateset(struct brcms_c_info *wlc,
+struct brcms_c_info *brcms_c_attach(struct brcms_info *wl,
+				    struct bcma_device *core, uint unit,
+				    bool piomode, uint *perr);
+uint brcms_c_detach(struct brcms_c_info *wlc);
+int brcms_c_up(struct brcms_c_info *wlc);
+uint brcms_c_down(struct brcms_c_info *wlc);
+
+bool brcms_c_chipmatch(struct bcma_device *core);
+void brcms_c_init(struct brcms_c_info *wlc, bool mute_tx);
+void brcms_c_reset(struct brcms_c_info *wlc);
+
+void brcms_c_intrson(struct brcms_c_info *wlc);
+u32 brcms_c_intrsoff(struct brcms_c_info *wlc);
+void brcms_c_intrsrestore(struct brcms_c_info *wlc, u32 macintmask);
+bool brcms_c_intrsupd(struct brcms_c_info *wlc);
+bool brcms_c_isr(struct brcms_c_info *wlc);
+bool brcms_c_dpc(struct brcms_c_info *wlc, bool bounded);
+bool brcms_c_sendpkt_mac80211(struct brcms_c_info *wlc, struct sk_buff *sdu,
+			      struct ieee80211_hw *hw);
+bool brcms_c_aggregatable(struct brcms_c_info *wlc, u8 tid);
+void brcms_c_protection_upd(struct brcms_c_info *wlc, uint idx, int val);
+int brcms_c_get_header_len(void);
+void brcms_c_set_addrmatch(struct brcms_c_info *wlc, int match_reg_offset,
+			   const u8 *addr);
+void brcms_c_wme_setparams(struct brcms_c_info *wlc, u16 aci,
+			   const struct ieee80211_tx_queue_params *arg,
+			   bool suspend);
+struct brcms_pub *brcms_c_pub(struct brcms_c_info *wlc);
+void brcms_c_ampdu_flush(struct brcms_c_info *wlc, struct ieee80211_sta *sta,
+			 u16 tid);
+void brcms_c_ampdu_tx_operational(struct brcms_c_info *wlc, u8 tid,
+				  u8 ba_wsize, uint max_rx_ampdu_bytes);
+int brcms_c_module_register(struct brcms_pub *pub, const char *name,
+			    struct brcms_info *hdl,
+			    int (*down_fn)(void *handle));
+int brcms_c_module_unregister(struct brcms_pub *pub, const char *name,
+			      struct brcms_info *hdl);
+void brcms_c_suspend_mac_and_wait(struct brcms_c_info *wlc);
+void brcms_c_enable_mac(struct brcms_c_info *wlc);
+void brcms_c_associate_upd(struct brcms_c_info *wlc, bool state);
+void brcms_c_scan_start(struct brcms_c_info *wlc);
+void brcms_c_scan_stop(struct brcms_c_info *wlc);
+int brcms_c_get_curband(struct brcms_c_info *wlc);
+int brcms_c_set_channel(struct brcms_c_info *wlc, u16 channel);
+int brcms_c_set_rate_limit(struct brcms_c_info *wlc, u16 srl, u16 lrl);
+void brcms_c_get_current_rateset(struct brcms_c_info *wlc,
 				 struct brcm_rateset *currs);
-extern int brcms_c_set_rateset(struct brcms_c_info *wlc,
-					struct brcm_rateset *rs);
-extern int brcms_c_set_beacon_period(struct brcms_c_info *wlc, u16 period);
-extern u16 brcms_c_get_phy_type(struct brcms_c_info *wlc, int phyidx);
-extern void brcms_c_set_shortslot_override(struct brcms_c_info *wlc,
+int brcms_c_set_rateset(struct brcms_c_info *wlc, struct brcm_rateset *rs);
+int brcms_c_set_beacon_period(struct brcms_c_info *wlc, u16 period);
+u16 brcms_c_get_phy_type(struct brcms_c_info *wlc, int phyidx);
+void brcms_c_set_shortslot_override(struct brcms_c_info *wlc,
 				    s8 sslot_override);
-extern void brcms_c_set_beacon_listen_interval(struct brcms_c_info *wlc,
-					u8 interval);
-extern u64 brcms_c_tsf_get(struct brcms_c_info *wlc);
-extern void brcms_c_tsf_set(struct brcms_c_info *wlc, u64 tsf);
-extern int brcms_c_set_tx_power(struct brcms_c_info *wlc, int txpwr);
-extern int brcms_c_get_tx_power(struct brcms_c_info *wlc);
-extern bool brcms_c_check_radio_disabled(struct brcms_c_info *wlc);
-extern void brcms_c_mute(struct brcms_c_info *wlc, bool on);
-extern bool brcms_c_tx_flush_completed(struct brcms_c_info *wlc);
-extern void brcms_c_start_station(struct brcms_c_info *wlc, u8 *addr);
-extern void brcms_c_start_ap(struct brcms_c_info *wlc, u8 *addr,
-			     const u8 *bssid, u8 *ssid, size_t ssid_len);
-extern void brcms_c_start_adhoc(struct brcms_c_info *wlc, u8 *addr);
-extern void brcms_c_update_beacon(struct brcms_c_info *wlc);
-extern void brcms_c_set_new_beacon(struct brcms_c_info *wlc,
-				   struct sk_buff *beacon, u16 tim_offset,
-				   u16 dtim_period);
-extern void brcms_c_set_new_probe_resp(struct brcms_c_info *wlc,
-				       struct sk_buff *probe_resp);
-extern void brcms_c_enable_probe_resp(struct brcms_c_info *wlc, bool enable);
-extern void brcms_c_set_ssid(struct brcms_c_info *wlc, u8 *ssid,
-			     size_t ssid_len);
+void brcms_c_set_beacon_listen_interval(struct brcms_c_info *wlc, u8 interval);
+u64 brcms_c_tsf_get(struct brcms_c_info *wlc);
+void brcms_c_tsf_set(struct brcms_c_info *wlc, u64 tsf);
+int brcms_c_set_tx_power(struct brcms_c_info *wlc, int txpwr);
+int brcms_c_get_tx_power(struct brcms_c_info *wlc);
+bool brcms_c_check_radio_disabled(struct brcms_c_info *wlc);
+void brcms_c_mute(struct brcms_c_info *wlc, bool on);
+bool brcms_c_tx_flush_completed(struct brcms_c_info *wlc);
+void brcms_c_start_station(struct brcms_c_info *wlc, u8 *addr);
+void brcms_c_start_ap(struct brcms_c_info *wlc, u8 *addr, const u8 *bssid,
+		      u8 *ssid, size_t ssid_len);
+void brcms_c_start_adhoc(struct brcms_c_info *wlc, u8 *addr);
+void brcms_c_update_beacon(struct brcms_c_info *wlc);
+void brcms_c_set_new_beacon(struct brcms_c_info *wlc, struct sk_buff *beacon,
+			    u16 tim_offset, u16 dtim_period);
+void brcms_c_set_new_probe_resp(struct brcms_c_info *wlc,
+				struct sk_buff *probe_resp);
+void brcms_c_enable_probe_resp(struct brcms_c_info *wlc, bool enable);
+void brcms_c_set_ssid(struct brcms_c_info *wlc, u8 *ssid, size_t ssid_len);
 
 #endif				/* _BRCM_PUB_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/rate.h b/drivers/net/wireless/brcm80211/brcmsmac/rate.h
index 980d578..5bb88b7 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/rate.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/rate.h
@@ -216,34 +216,30 @@ static inline u8 cck_phy2mac_rate(u8 signal)
 
 /* sanitize, and sort a rateset with the basic bit(s) preserved, validate
  * rateset */
-extern bool
-brcms_c_rate_hwrs_filter_sort_validate(struct brcms_c_rateset *rs,
-				       const struct brcms_c_rateset *hw_rs,
-				       bool check_brate, u8 txstreams);
+bool brcms_c_rate_hwrs_filter_sort_validate(struct brcms_c_rateset *rs,
+					    const struct brcms_c_rateset *hw_rs,
+					    bool check_brate, u8 txstreams);
 /* copy rateset src to dst as-is (no masking or sorting) */
-extern void brcms_c_rateset_copy(const struct brcms_c_rateset *src,
-			     struct brcms_c_rateset *dst);
+void brcms_c_rateset_copy(const struct brcms_c_rateset *src,
+			  struct brcms_c_rateset *dst);
 
 /* would be nice to have these documented ... */
-extern u32 brcms_c_compute_rspec(struct d11rxhdr *rxh, u8 *plcp);
-
-extern void brcms_c_rateset_filter(struct brcms_c_rateset *src,
-	struct brcms_c_rateset *dst, bool basic_only, u8 rates, uint xmask,
-	bool mcsallow);
-
-extern void
-brcms_c_rateset_default(struct brcms_c_rateset *rs_tgt,
-			const struct brcms_c_rateset *rs_hw, uint phy_type,
-			int bandtype, bool cck_only, uint rate_mask,
-			bool mcsallow, u8 bw, u8 txstreams);
-
-extern s16 brcms_c_rate_legacy_phyctl(uint rate);
-
-extern void brcms_c_rateset_mcs_upd(struct brcms_c_rateset *rs, u8 txstreams);
-extern void brcms_c_rateset_mcs_clear(struct brcms_c_rateset *rateset);
-extern void brcms_c_rateset_mcs_build(struct brcms_c_rateset *rateset,
-				      u8 txstreams);
-extern void brcms_c_rateset_bw_mcs_filter(struct brcms_c_rateset *rateset,
-					  u8 bw);
+u32 brcms_c_compute_rspec(struct d11rxhdr *rxh, u8 *plcp);
+
+void brcms_c_rateset_filter(struct brcms_c_rateset *src,
+			    struct brcms_c_rateset *dst, bool basic_only,
+			    u8 rates, uint xmask, bool mcsallow);
+
+void brcms_c_rateset_default(struct brcms_c_rateset *rs_tgt,
+			     const struct brcms_c_rateset *rs_hw, uint phy_type,
+			     int bandtype, bool cck_only, uint rate_mask,
+			     bool mcsallow, u8 bw, u8 txstreams);
+
+s16 brcms_c_rate_legacy_phyctl(uint rate);
+
+void brcms_c_rateset_mcs_upd(struct brcms_c_rateset *rs, u8 txstreams);
+void brcms_c_rateset_mcs_clear(struct brcms_c_rateset *rateset);
+void brcms_c_rateset_mcs_build(struct brcms_c_rateset *rateset, u8 txstreams);
+void brcms_c_rateset_bw_mcs_filter(struct brcms_c_rateset *rateset, u8 bw);
 
 #endif				/* _BRCM_RATE_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/stf.h b/drivers/net/wireless/brcm80211/brcmsmac/stf.h
index 19f6580..ba94930 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/stf.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/stf.h
@@ -19,24 +19,19 @@
 
 #include "types.h"
 
-extern int brcms_c_stf_attach(struct brcms_c_info *wlc);
-extern void brcms_c_stf_detach(struct brcms_c_info *wlc);
+int brcms_c_stf_attach(struct brcms_c_info *wlc);
+void brcms_c_stf_detach(struct brcms_c_info *wlc);
 
-extern void brcms_c_tempsense_upd(struct brcms_c_info *wlc);
-extern void brcms_c_stf_ss_algo_channel_get(struct brcms_c_info *wlc,
-					u16 *ss_algo_channel,
-					u16 chanspec);
-extern int brcms_c_stf_ss_update(struct brcms_c_info *wlc,
-			     struct brcms_band *band);
-extern void brcms_c_stf_phy_txant_upd(struct brcms_c_info *wlc);
-extern int brcms_c_stf_txchain_set(struct brcms_c_info *wlc, s32 int_val,
-			       bool force);
-extern bool brcms_c_stf_stbc_rx_set(struct brcms_c_info *wlc, s32 int_val);
-extern void brcms_c_stf_phy_txant_upd(struct brcms_c_info *wlc);
-extern void brcms_c_stf_phy_chain_calc(struct brcms_c_info *wlc);
-extern u16 brcms_c_stf_phytxchain_sel(struct brcms_c_info *wlc,
-				      u32 rspec);
-extern u16 brcms_c_stf_d11hdrs_phyctl_txant(struct brcms_c_info *wlc,
-					u32 rspec);
+void brcms_c_tempsense_upd(struct brcms_c_info *wlc);
+void brcms_c_stf_ss_algo_channel_get(struct brcms_c_info *wlc,
+				     u16 *ss_algo_channel, u16 chanspec);
+int brcms_c_stf_ss_update(struct brcms_c_info *wlc, struct brcms_band *band);
+void brcms_c_stf_phy_txant_upd(struct brcms_c_info *wlc);
+int brcms_c_stf_txchain_set(struct brcms_c_info *wlc, s32 int_val, bool force);
+bool brcms_c_stf_stbc_rx_set(struct brcms_c_info *wlc, s32 int_val);
+void brcms_c_stf_phy_txant_upd(struct brcms_c_info *wlc);
+void brcms_c_stf_phy_chain_calc(struct brcms_c_info *wlc);
+u16 brcms_c_stf_phytxchain_sel(struct brcms_c_info *wlc, u32 rspec);
+u16 brcms_c_stf_d11hdrs_phyctl_txant(struct brcms_c_info *wlc, u32 rspec);
 
 #endif				/* _BRCM_STF_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h b/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h
index 18750a8..c87dd89 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h
@@ -43,16 +43,14 @@ struct brcms_ucode {
 	u32 *bcm43xx_bomminor;
 };
 
-extern int
-brcms_ucode_data_init(struct brcms_info *wl, struct brcms_ucode *ucode);
+int brcms_ucode_data_init(struct brcms_info *wl, struct brcms_ucode *ucode);
 
-extern void brcms_ucode_data_free(struct brcms_ucode *ucode);
+void brcms_ucode_data_free(struct brcms_ucode *ucode);
 
-extern int brcms_ucode_init_buf(struct brcms_info *wl, void **pbuf,
-				unsigned int idx);
-extern int brcms_ucode_init_uint(struct brcms_info *wl, size_t *n_bytes,
-				 unsigned int idx);
-extern void brcms_ucode_free_buf(void *);
-extern int  brcms_check_firmwares(struct brcms_info *wl);
+int brcms_ucode_init_buf(struct brcms_info *wl, void **pbuf, unsigned int idx);
+int brcms_ucode_init_uint(struct brcms_info *wl, size_t *n_bytes,
+			  unsigned int idx);
+void brcms_ucode_free_buf(void *);
+int  brcms_check_firmwares(struct brcms_info *wl);
 
 #endif	/* _BRCM_UCODE_H_ */
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_d11.h b/drivers/net/wireless/brcm80211/include/brcmu_d11.h
index 92623f0..8660a2c 100644
--- a/drivers/net/wireless/brcm80211/include/brcmu_d11.h
+++ b/drivers/net/wireless/brcm80211/include/brcmu_d11.h
@@ -140,6 +140,6 @@ struct brcmu_d11inf {
 	void (*decchspec)(struct brcmu_chan *ch);
 };
 
-extern void brcmu_d11_attach(struct brcmu_d11inf *d11inf);
+void brcmu_d11_attach(struct brcmu_d11inf *d11inf);
 
 #endif	/* _BRCMU_CHANNELS_H_ */
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_utils.h b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
index 898cacb..8ba445b 100644
--- a/drivers/net/wireless/brcm80211/include/brcmu_utils.h
+++ b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
@@ -114,31 +114,29 @@ static inline struct sk_buff *pktq_ppeek_tail(struct pktq *pq, int prec)
 	return skb_peek_tail(&pq->q[prec].skblist);
 }
 
-extern struct sk_buff *brcmu_pktq_penq(struct pktq *pq, int prec,
-				 struct sk_buff *p);
-extern struct sk_buff *brcmu_pktq_penq_head(struct pktq *pq, int prec,
-				      struct sk_buff *p);
-extern struct sk_buff *brcmu_pktq_pdeq(struct pktq *pq, int prec);
-extern struct sk_buff *brcmu_pktq_pdeq_tail(struct pktq *pq, int prec);
-extern struct sk_buff *brcmu_pktq_pdeq_match(struct pktq *pq, int prec,
-					     bool (*match_fn)(struct sk_buff *p,
-							      void *arg),
-					     void *arg);
+struct sk_buff *brcmu_pktq_penq(struct pktq *pq, int prec, struct sk_buff *p);
+struct sk_buff *brcmu_pktq_penq_head(struct pktq *pq, int prec,
+				     struct sk_buff *p);
+struct sk_buff *brcmu_pktq_pdeq(struct pktq *pq, int prec);
+struct sk_buff *brcmu_pktq_pdeq_tail(struct pktq *pq, int prec);
+struct sk_buff *brcmu_pktq_pdeq_match(struct pktq *pq, int prec,
+				      bool (*match_fn)(struct sk_buff *p,
+						       void *arg),
+				      void *arg);
 
 /* packet primitives */
-extern struct sk_buff *brcmu_pkt_buf_get_skb(uint len);
-extern void brcmu_pkt_buf_free_skb(struct sk_buff *skb);
+struct sk_buff *brcmu_pkt_buf_get_skb(uint len);
+void brcmu_pkt_buf_free_skb(struct sk_buff *skb);
 
 /* Empty the queue at particular precedence level */
 /* callback function fn(pkt, arg) returns true if pkt belongs to if */
-extern void brcmu_pktq_pflush(struct pktq *pq, int prec,
-	bool dir, bool (*fn)(struct sk_buff *, void *), void *arg);
+void brcmu_pktq_pflush(struct pktq *pq, int prec, bool dir,
+		       bool (*fn)(struct sk_buff *, void *), void *arg);
 
 /* operations on a set of precedences in packet queue */
 
-extern int brcmu_pktq_mlen(struct pktq *pq, uint prec_bmp);
-extern struct sk_buff *brcmu_pktq_mdeq(struct pktq *pq, uint prec_bmp,
-	int *prec_out);
+int brcmu_pktq_mlen(struct pktq *pq, uint prec_bmp);
+struct sk_buff *brcmu_pktq_mdeq(struct pktq *pq, uint prec_bmp, int *prec_out);
 
 /* operations on packet queue as a whole */
 
@@ -167,11 +165,11 @@ static inline bool pktq_empty(struct pktq *pq)
 	return pq->len == 0;
 }
 
-extern void brcmu_pktq_init(struct pktq *pq, int num_prec, int max_len);
+void brcmu_pktq_init(struct pktq *pq, int num_prec, int max_len);
 /* prec_out may be NULL if caller is not interested in return value */
-extern struct sk_buff *brcmu_pktq_peek_tail(struct pktq *pq, int *prec_out);
-extern void brcmu_pktq_flush(struct pktq *pq, bool dir,
-		bool (*fn)(struct sk_buff *, void *), void *arg);
+struct sk_buff *brcmu_pktq_peek_tail(struct pktq *pq, int *prec_out);
+void brcmu_pktq_flush(struct pktq *pq, bool dir,
+		      bool (*fn)(struct sk_buff *, void *), void *arg);
 
 /* externs */
 /* ip address */
@@ -204,13 +202,13 @@ static inline u16 brcmu_maskget16(u16 var, u16 mask, u8 shift)
 /* externs */
 /* format/print */
 #ifdef DEBUG
-extern void brcmu_prpkt(const char *msg, struct sk_buff *p0);
+void brcmu_prpkt(const char *msg, struct sk_buff *p0);
 #else
 #define brcmu_prpkt(a, b)
 #endif				/* DEBUG */
 
 #ifdef DEBUG
-extern __printf(3, 4)
+__printf(3, 4)
 void brcmu_dbg_hex_dump(const void *data, size_t size, const char *fmt, ...);
 #else
 __printf(3, 4)
-- 
1.8.1.2.459.gbcd45b4.dirty
