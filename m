From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/8] brcm80211: Use normal DEBUG define
Date: Sun, 15 Jan 2012 00:38:38 -0800
Message-ID: <319f83d04cd15de77b030d1be436bd96f011a2e4.1326616556.git.joe@perches.com>
References: <cover.1326616556.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Henry Ptasinski <henryp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kan Yan <kanyan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1326616556.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Current CONFIG_BRCMDBG flag when enabled does not
necessarily enable proper pr_debug output when
DEBUG is not also enabled.

Remove BCMDBG define and just use DEBUG instead.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/brcm80211/Makefile            |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    4 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    6 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   86 ++++++++++----------
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |    6 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |    8 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   18 ++--
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   42 +++++-----
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    2 +-
 drivers/net/wireless/brcm80211/brcmutil/utils.c    |    4 +-
 .../net/wireless/brcm80211/include/brcmu_utils.h   |    4 +-
 16 files changed, 102 insertions(+), 102 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/Makefile b/drivers/net/wireless/brcm80211/Makefile
index f41c047..b987920 100644
--- a/drivers/net/wireless/brcm80211/Makefile
+++ b/drivers/net/wireless/brcm80211/Makefile
@@ -16,7 +16,7 @@
 # CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 
 # common flags
-subdir-ccflags-$(CONFIG_BRCMDBG)	+= -DBCMDBG
+subdir-ccflags-$(CONFIG_BRCMDBG)	+= -DDEBUG
 
 obj-$(CONFIG_BRCMUTIL)	+= brcmutil/
 obj-$(CONFIG_BRCMFMAC)	+= brcmfmac/
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
index e58ea40..07686a7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
@@ -644,9 +644,9 @@ extern char *brcmf_ifname(struct brcmf_pub *drvr, int idx);
 extern int brcmf_proto_cdc_query_dcmd(struct brcmf_pub *drvr, int ifidx,
 				       uint cmd, void *buf, uint len);
 
-#ifdef BCMDBG
+#ifdef DEBUG
 extern int brcmf_write_to_file(struct brcmf_pub *drvr, const u8 *buf, int size);
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 extern int brcmf_ifname2idx(struct brcmf_pub *drvr, char *name);
 extern int brcmf_c_host_event(struct brcmf_pub *drvr, int *idx,
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
index a51d8f5..9385c84 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -38,7 +38,7 @@
 #define BRCMF_PKT_FILTER_PATTERN_FIXED_LEN	\
 	offsetof(struct brcmf_pkt_filter_pattern_le, mask_and_pattern)
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static const char brcmf_version[] =
 	"Dongle Host Driver, version " BRCMF_VERSION_STR "\nCompiled on "
 	__DATE__ " at " __TIME__;
@@ -133,7 +133,7 @@ bool brcmf_c_prec_enq(struct device *dev, struct pktq *q,
 	return p != NULL;
 }
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static void
 brcmf_c_show_host_event(struct brcmf_event_msg *event, void *event_data)
 {
@@ -430,7 +430,7 @@ brcmf_c_show_host_event(struct brcmf_event_msg *event, void *event_data)
 		brcmf_dbg(EVENT, "\n");
 	}
 }
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 int
 brcmf_c_host_event(struct brcmf_pub *drvr, int *ifidx, void *pktdata,
@@ -518,9 +518,9 @@ brcmf_c_host_event(struct brcmf_pub *drvr, int *ifidx, void *pktdata,
 		break;
 	}
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	brcmf_c_show_host_event(event, event_data);
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	return 0;
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
index bb26ee3..8b2060b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
@@ -32,7 +32,7 @@
 #define BRCMF_BTA_VAL	0x1000
 #define BRCMF_ISCAN_VAL 0x2000
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 
 #define brcmf_dbg(level, fmt, ...)					\
 do {									\
@@ -56,7 +56,7 @@ do {									\
 #define BRCMF_BYTES_ON()	(brcmf_msg_level & BRCMF_BYTES_VAL)
 #define BRCMF_GLOM_ON()		(brcmf_msg_level & BRCMF_GLOM_VAL)
 
-#else	/* (defined BCMDBG) || (defined BCMDBG) */
+#else	/* (defined DEBUG) || (defined DEBUG) */
 
 #define brcmf_dbg(level, fmt, ...) no_printk(fmt, ##__VA_ARGS__)
 
@@ -66,7 +66,7 @@ do {									\
 #define BRCMF_BYTES_ON()	0
 #define BRCMF_GLOM_ON()		0
 
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
 
 extern int brcmf_msg_level;
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index eb9eb76..96f47e6 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -1146,7 +1146,7 @@ int brcmf_netdev_wait_pend8021x(struct net_device *ndev)
 	return pend;
 }
 
-#ifdef BCMDBG
+#ifdef DEBUG
 int brcmf_write_to_file(struct brcmf_pub *drvr, const u8 *buf, int size)
 {
 	int ret = 0;
@@ -1180,4 +1180,4 @@ exit:
 
 	return ret;
 }
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index f7eeee1..7157a60 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -40,7 +40,7 @@
 
 #define DCMD_RESP_TIMEOUT  2000	/* In milli second */
 
-#ifdef BCMDBG
+#ifdef DEBUG
 
 #define BRCMF_TRAP_INFO_SIZE	80
 
@@ -84,7 +84,7 @@ struct rte_console {
 	char cbuf[CBUF_LEN];
 };
 
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 #include <chipcommon.h>
 
 #include "dhd_bus.h"
@@ -416,7 +416,7 @@ struct sdpcmd_regs {
 	u16 PAD[0x80];
 };
 
-#ifdef BCMDBG
+#ifdef DEBUG
 /* Device console log buffer state */
 struct brcmf_console {
 	uint count;		/* Poll interval msec counter */
@@ -426,7 +426,7 @@ struct brcmf_console {
 	u8 *buf;		/* Log buffer (host copy) */
 	uint last;		/* Last buffer read index */
 };
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 struct sdpcm_shared {
 	u32 flags;
@@ -507,11 +507,11 @@ struct brcmf_sdio {
 	uint polltick;		/* Tick counter */
 	uint pollcnt;		/* Count of active polls */
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	uint console_interval;
 	struct brcmf_console console;	/* Console output polling support */
 	uint console_addr;	/* Console address from shared struct */
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	uint regfails;		/* Count of R_REG failures */
 
@@ -587,10 +587,10 @@ struct brcmf_sdio {
 #define CLK_PENDING	2	/* Not used yet */
 #define CLK_AVAIL	3
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static int qcount[NUMPRIO];
 static int tx_packets[NUMPRIO];
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 #define SDIO_DRIVE_STRENGTH	6	/* in milliamps */
 
@@ -764,12 +764,12 @@ static int brcmf_sdbrcm_htclk(struct brcmf_sdio *bus, bool on, bool pendok)
 		bus->clkstate = CLK_AVAIL;
 		brcmf_dbg(INFO, "CLKCTL: turned ON\n");
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 		if (bus->alp_only != true) {
 			if (SBSDIO_ALPONLY(clkctl))
 				brcmf_dbg(ERROR, "HT Clock should be on\n");
 		}
-#endif				/* defined (BCMDBG) */
+#endif				/* defined (DEBUG) */
 
 		bus->activity = true;
 	} else {
@@ -814,9 +814,9 @@ static int brcmf_sdbrcm_sdclk(struct brcmf_sdio *bus, bool on)
 /* Transition SD and backplane clock readiness */
 static int brcmf_sdbrcm_clkctl(struct brcmf_sdio *bus, uint target, bool pendok)
 {
-#ifdef BCMDBG
+#ifdef DEBUG
 	uint oldstate = bus->clkstate;
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	brcmf_dbg(TRACE, "Enter\n");
 
@@ -861,9 +861,9 @@ static int brcmf_sdbrcm_clkctl(struct brcmf_sdio *bus, uint target, bool pendok)
 		brcmf_sdbrcm_wd_timer(bus, 0);
 		break;
 	}
-#ifdef BCMDBG
+#ifdef DEBUG
 	brcmf_dbg(INFO, "%d -> %d\n", oldstate, bus->clkstate);
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	return 0;
 }
@@ -1279,7 +1279,7 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			}
 			return 0;
 		}
-#ifdef BCMDBG
+#ifdef DEBUG
 		if (BRCMF_GLOM_ON()) {
 			printk(KERN_DEBUG "SUPERFRAME:\n");
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -1362,7 +1362,7 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			check = get_unaligned_le16(dptr + sizeof(u16));
 			chan = SDPCM_PACKET_CHANNEL(&dptr[SDPCM_FRAMETAG_LEN]);
 			doff = SDPCM_DOFFSET_VALUE(&dptr[SDPCM_FRAMETAG_LEN]);
-#ifdef BCMDBG
+#ifdef DEBUG
 			if (BRCMF_GLOM_ON()) {
 				printk(KERN_DEBUG "subframe:\n");
 				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -1433,7 +1433,7 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 			}
 			rxseq++;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 			if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
 				printk(KERN_DEBUG "Rx Subframe Data:\n");
 				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -1457,7 +1457,7 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 				continue;
 			}
 
-#ifdef BCMDBG
+#ifdef DEBUG
 			if (BRCMF_GLOM_ON()) {
 				brcmf_dbg(GLOM, "subframe %d to stack, %p (%p/%d) nxt/lnk %p/%p\n",
 					  bus->glom.qlen, pfirst, pfirst->data,
@@ -1467,7 +1467,7 @@ static u8 brcmf_sdbrcm_rxglom(struct brcmf_sdio *bus, u8 rxseq)
 						pfirst->data,
 						min_t(int, pfirst->len, 32));
 			}
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 		}
 		/* sent any remaining packets up */
 		if (bus->glom.qlen) {
@@ -1584,7 +1584,7 @@ brcmf_sdbrcm_read_control(struct brcmf_sdio *bus, u8 *hdr, uint len, uint doff)
 
 gotpkt:
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	if (BRCMF_BYTES_ON() && BRCMF_CTL_ON()) {
 		printk(KERN_DEBUG "RxCtrl:\n");
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, bus->rxctl, len);
@@ -1818,7 +1818,7 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 			}
 			bus->tx_max = txmax;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 			if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
 				printk(KERN_DEBUG "Rx Data:\n");
 				print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -1865,7 +1865,7 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 			brcmf_sdbrcm_rxfail(bus, true, true);
 			continue;
 		}
-#ifdef BCMDBG
+#ifdef DEBUG
 		if (BRCMF_BYTES_ON() || BRCMF_HDRS_ON()) {
 			printk(KERN_DEBUG "RxHdr:\n");
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -2024,7 +2024,7 @@ brcmf_sdbrcm_readframes(struct brcmf_sdio *bus, uint maxframes, bool *finished)
 		skb_push(pkt, BRCMF_FIRSTREAD);
 		memcpy(pkt->data, bus->rxhdr, BRCMF_FIRSTREAD);
 
-#ifdef BCMDBG
+#ifdef DEBUG
 		if (BRCMF_BYTES_ON() && BRCMF_DATA_ON()) {
 			printk(KERN_DEBUG "Rx Data:\n");
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -2038,7 +2038,7 @@ deliver:
 			if (SDPCM_GLOMDESC(&bus->rxhdr[SDPCM_FRAMETAG_LEN])) {
 				brcmf_dbg(GLOM, "glom descriptor, %d bytes:\n",
 					  len);
-#ifdef BCMDBG
+#ifdef DEBUG
 				if (BRCMF_GLOM_ON()) {
 					printk(KERN_DEBUG "Glom Data:\n");
 					print_hex_dump_bytes("",
@@ -2078,13 +2078,13 @@ deliver:
 		down(&bus->sdsem);
 	}
 	rxcount = maxframes - rxleft;
-#ifdef BCMDBG
+#ifdef DEBUG
 	/* Message if we hit the limit */
 	if (!rxleft)
 		brcmf_dbg(DATA, "hit rx limit of %d frames\n",
 			  maxframes);
 	else
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 		brcmf_dbg(DATA, "processed %d frames\n", rxcount);
 	/* Back off rxseq if awaiting rtx, update rx_seq */
 	if (bus->rxskip)
@@ -2176,7 +2176,7 @@ static int brcmf_sdbrcm_txpkt(struct brcmf_sdio *bus, struct sk_buff *pkt,
 	put_unaligned_le32(swheader, frame + SDPCM_FRAMETAG_LEN);
 	put_unaligned_le32(0, frame + SDPCM_FRAMETAG_LEN + sizeof(swheader));
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	tx_packets[pkt->priority]++;
 	if (BRCMF_BYTES_ON() &&
 	    (((BRCMF_CTL_ON() && (chan == SDPCM_CONTROL_CHANNEL)) ||
@@ -2410,7 +2410,7 @@ static bool brcmf_sdbrcm_dpc(struct brcmf_sdio *bus)
 		int err;
 		u8 clkctl, devctl = 0;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 		/* Check for inconsistent device control */
 		devctl = brcmf_sdcard_cfg_read(bus->sdiodev, SDIO_FUNC_1,
 					       SBSDIO_DEVICE_CTL, &err);
@@ -2418,7 +2418,7 @@ static bool brcmf_sdbrcm_dpc(struct brcmf_sdio *bus)
 			brcmf_dbg(ERROR, "error reading DEVCTL: %d\n", err);
 			bus->sdiodev->bus_if->state = BRCMF_BUS_DOWN;
 		}
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 		/* Read CSR, if clock on switch to AVAIL, else ignore */
 		clkctl = brcmf_sdcard_cfg_read(bus->sdiodev, SDIO_FUNC_1,
@@ -2701,7 +2701,7 @@ static int brcmf_sdbrcm_bus_txdata(struct device *dev, struct sk_buff *pkt)
 		brcmf_txflowcontrol(bus->sdiodev->dev, 0, ON);
 	}
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	if (pktq_plen(&bus->txq, prec) > qcount[prec])
 		qcount[prec] = pktq_plen(&bus->txq, prec);
 #endif
@@ -2774,7 +2774,7 @@ xfer_done:
 	return bcmerror;
 }
 
-#ifdef BCMDBG
+#ifdef DEBUG
 #define CONSOLE_LINE_MAX	192
 
 static int brcmf_sdbrcm_readconsole(struct brcmf_sdio *bus)
@@ -2852,7 +2852,7 @@ break2:
 
 	return 0;
 }
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 static int brcmf_tx_frame(struct brcmf_sdio *bus, u8 *frame, u16 len)
 {
@@ -2982,7 +2982,7 @@ brcmf_sdbrcm_bus_txctl(struct device *dev, unsigned char *msg, uint msglen)
 	}
 
 	if (ret == -1) {
-#ifdef BCMDBG
+#ifdef DEBUG
 		if (BRCMF_BYTES_ON() && BRCMF_CTL_ON()) {
 			printk(KERN_DEBUG "Tx Frame:\n");
 			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
@@ -3096,9 +3096,9 @@ static int brcmf_sdbrcm_write_vars(struct brcmf_sdio *bus)
 	u8 *vbuffer;
 	u32 varsizew;
 	__le32 varsizew_le;
-#ifdef BCMDBG
+#ifdef DEBUG
 	char *nvram_ularray;
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/* Even if there are no vars are to be written, we still
 		 need to set the ramsize. */
@@ -3115,7 +3115,7 @@ static int brcmf_sdbrcm_write_vars(struct brcmf_sdio *bus)
 		/* Write the vars list */
 		bcmerror =
 		    brcmf_sdbrcm_membytes(bus, true, varaddr, vbuffer, varsize);
-#ifdef BCMDBG
+#ifdef DEBUG
 		/* Verify NVRAM bytes */
 		brcmf_dbg(INFO, "Compare NVRAM dl & ul; varsize=%d\n", varsize);
 		nvram_ularray = kmalloc(varsize, GFP_ATOMIC);
@@ -3142,7 +3142,7 @@ static int brcmf_sdbrcm_write_vars(struct brcmf_sdio *bus)
 			brcmf_dbg(ERROR, "Download/Upload/Compare of NVRAM ok\n");
 
 		kfree(nvram_ularray);
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 		kfree(vbuffer);
 	}
@@ -3569,9 +3569,9 @@ void brcmf_sdbrcm_isr(void *arg)
 
 static bool brcmf_sdbrcm_bus_watchdog(struct brcmf_sdio *bus)
 {
-#ifdef BCMDBG
+#ifdef DEBUG
 	struct brcmf_bus *bus_if = dev_get_drvdata(bus->sdiodev->dev);
-#endif	/* BCMDBG */
+#endif	/* DEBUG */
 
 	brcmf_dbg(TIMER, "Enter\n");
 
@@ -3616,7 +3616,7 @@ static bool brcmf_sdbrcm_bus_watchdog(struct brcmf_sdio *bus)
 		/* Update interrupt tracking */
 		bus->lastintrs = bus->intrcount;
 	}
-#ifdef BCMDBG
+#ifdef DEBUG
 	/* Poll for console output periodically */
 	if (bus_if->state == BRCMF_BUS_DATA &&
 	    bus->console_interval != 0) {
@@ -3630,7 +3630,7 @@ static bool brcmf_sdbrcm_bus_watchdog(struct brcmf_sdio *bus)
 				bus->console_interval = 0;
 		}
 	}
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/* On idle timeout clear activity flag and/or turn off clock */
 	if ((bus->idletime > 0) && (bus->clkstate == CLK_AVAIL)) {
@@ -3721,11 +3721,11 @@ brcmf_sdbrcm_probe_attach(struct brcmf_sdio *bus, u32 regsva)
 	if (brcmf_sdcard_set_sbaddr_window(bus->sdiodev, SI_ENUM_BASE))
 		brcmf_dbg(ERROR, "FAILED to return to SI_ENUM_BASE\n");
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	printk(KERN_DEBUG "F1 signature read @0x18000000=0x%4x\n",
 	       brcmf_sdcard_reg_read(bus->sdiodev, SI_ENUM_BASE, 4));
 
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/*
 	 * Force PLL off until brcmf_sdio_chip_attach()
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
index a613b49..69a4872 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
@@ -42,7 +42,7 @@ do {								\
 	}							\
 } while (0)
 
-#if (defined BCMDBG)
+#if (defined DEBUG)
 #define	WL_INFO(fmt, args...)					\
 do {								\
 	if (brcmf_dbg_level & WL_DBG_INFO) {			\
@@ -83,12 +83,12 @@ do {								\
 	}							\
 } while (0)
 
-#else /* (defined BCMDBG) */
+#else /* (defined DEBUG) */
 #define	WL_INFO(fmt, args...)
 #define	WL_TRACE(fmt, args...)
 #define	WL_SCAN(fmt, args...)
 #define	WL_CONN(fmt, args...)
-#endif /* (defined BCMDBG) */
+#endif /* (defined DEBUG) */
 
 #define WL_NUM_SCAN_MAX		1
 #define WL_NUM_PMKIDS_MAX	MAXPMKID	/* will be used
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
index ab9bb11..c93ea35 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
@@ -326,11 +326,11 @@
 
 #define PCI_FORCEHT(sih) (PCIE(sih) && (ai_get_chip_id(sih) == BCM4716_CHIP_ID))
 
-#ifdef BCMDBG
+#ifdef DEBUG
 #define	SI_MSG(fmt, ...)	pr_debug(fmt, ##__VA_ARGS__)
 #else
 #define	SI_MSG(fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 #define	GOODCOREADDR(x, b) \
 	(((x) >= (b)) && ((x) < ((b) + SI_MAXCORES * SI_CORE_SIZE)) && \
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c b/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
index 90911ee..d89dcb1 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
@@ -915,7 +915,7 @@ brcms_c_ampdu_dotxstatus_complete(struct ampdu_info *ampdu, struct scb *scb,
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(p);
 	struct wiphy *wiphy = wlc->wiphy;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	u8 hole[AMPDU_MAX_MPDU];
 	memset(hole, 0, sizeof(hole));
 #endif
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index 2e90a9a..11054ae 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -177,7 +177,7 @@
 #define BCMEXTRAHDROOM 172
 
 /* debug/trace */
-#ifdef BCMDBG
+#ifdef DEBUG
 #define	DMA_ERROR(fmt, ...)					\
 do {								\
 	if (*di->msg_level & 1)					\
@@ -193,7 +193,7 @@ do {								\
 	no_printk(fmt, ##__VA_ARGS__)
 #define	DMA_TRACE(fmt, ...)			\
 	no_printk(fmt, ##__VA_ARGS__)
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 #define	DMA_NONE(fmt, ...)			\
 	no_printk(fmt, ##__VA_ARGS__)
@@ -968,7 +968,7 @@ int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 			pktcnt++;
 		}
 
-#ifdef BCMDBG
+#ifdef DEBUG
 		if (resid > 0) {
 			uint cur;
 			cur =
@@ -979,7 +979,7 @@ int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 			DMA_ERROR("rxin %d rxout %d, hw_curr %d\n",
 				   di->rxin, di->rxout, cur);
 		}
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 		if ((di->dma.dmactrlflags & DMA_CTRL_RXMULTI) == 0) {
 			DMA_ERROR("%s: bad frame length (%d)\n",
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index d106576..9c60f42 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -96,10 +96,10 @@ static struct bcma_device_id brcms_coreid_table[] = {
 };
 MODULE_DEVICE_TABLE(bcma, brcms_coreid_table);
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static int msglevel = 0xdeadbeef;
 module_param(msglevel, int, 0);
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 static struct ieee80211_channel brcms_2ghz_chantable[] = {
 	CHAN2GHZ(1, 2412, IEEE80211_CHAN_NO_HT40MINUS),
@@ -857,7 +857,7 @@ static void brcms_free(struct brcms_info *wl)
 	/* free timers */
 	for (t = wl->timers; t; t = next) {
 		next = t->next;
-#ifdef BCMDBG
+#ifdef DEBUG
 		kfree(t->name);
 #endif
 		kfree(t);
@@ -1209,10 +1209,10 @@ static int __init brcms_module_init(void)
 {
 	int error = -ENODEV;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	if (msglevel != 0xdeadbeef)
 		brcm_msg_level = msglevel;
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	error = bcma_driver_register(&brcms_bcma_driver);
 	printk(KERN_ERR "%s: register returned %d\n", __func__, error);
@@ -1399,7 +1399,7 @@ struct brcms_timer *brcms_init_timer(struct brcms_info *wl,
 	t->next = wl->timers;
 	wl->timers = t;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	t->name = kmalloc(strlen(name) + 1, GFP_ATOMIC);
 	if (t->name)
 		strcpy(t->name, name);
@@ -1418,7 +1418,7 @@ void brcms_add_timer(struct brcms_timer *t, uint ms, int periodic)
 {
 	struct ieee80211_hw *hw = t->wl->pub->ieee_hw;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	if (t->set)
 		wiphy_err(hw->wiphy, "%s: Already set. Name: %s, per %d\n",
 			  __func__, t->name, periodic);
@@ -1463,7 +1463,7 @@ void brcms_free_timer(struct brcms_timer *t)
 
 	if (wl->timers == t) {
 		wl->timers = wl->timers->next;
-#ifdef BCMDBG
+#ifdef DEBUG
 		kfree(t->name);
 #endif
 		kfree(t);
@@ -1475,7 +1475,7 @@ void brcms_free_timer(struct brcms_timer *t)
 	while (tmp) {
 		if (tmp->next == t) {
 			tmp->next = t->next;
-#ifdef BCMDBG
+#ifdef DEBUG
 			kfree(t->name);
 #endif
 			kfree(t);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
index 8f60419..9358bd5 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
@@ -40,7 +40,7 @@ struct brcms_timer {
 	bool periodic;
 	bool set;		/* indicates if timer is active */
 	struct brcms_timer *next;	/* for freeing on unload */
-#ifdef BCMDBG
+#ifdef DEBUG
 	char *name;		/* Description of the timer */
 #endif
 };
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index f7ed340..3ae07bb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -293,11 +293,11 @@ const u8 prio2fifo[NUMPRIO] = {
 
 /* debug/trace */
 uint brcm_msg_level =
-#if defined(BCMDBG)
+#if defined(DEBUG)
 	LOG_ERROR_VAL;
 #else
 	0;
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 /* TX FIFO number to WME/802.1E Access Category */
 static const u8 wme_fifo2ac[] = {
@@ -342,14 +342,14 @@ static const u16 xmtfifo_sz[][NFIFO] = {
 	{9, 58, 22, 14, 14, 5},
 };
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static const char * const fifo_names[] = {
 	"AC_BK", "AC_BE", "AC_VI", "AC_VO", "BCMC", "ATIM" };
 #else
 static const char fifo_names[6][0];
 #endif
 
-#ifdef BCMDBG
+#ifdef DEBUG
 /* pointer to most recently allocated wl/wlc */
 static struct brcms_c_info *wlc_info_dbg = (struct brcms_c_info *) (NULL);
 #endif
@@ -3075,30 +3075,30 @@ static void brcms_c_statsupd(struct brcms_c_info *wlc)
 {
 	int i;
 	struct macstat macstats;
-#ifdef BCMDBG
+#ifdef DEBUG
 	u16 delta;
 	u16 rxf0ovfl;
 	u16 txfunfl[NFIFO];
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/* if driver down, make no sense to update stats */
 	if (!wlc->pub->up)
 		return;
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	/* save last rx fifo 0 overflow count */
 	rxf0ovfl = wlc->core->macstat_snapshot->rxf0ovfl;
 
 	/* save last tx fifo  underflow count */
 	for (i = 0; i < NFIFO; i++)
 		txfunfl[i] = wlc->core->macstat_snapshot->txfunfl[i];
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/* Read mac stats from contiguous shared memory */
 	brcms_b_copyfrom_objmem(wlc->hw, M_UCODE_MACSTAT, &macstats,
 				sizeof(struct macstat), OBJADDR_SHM_SEL);
 
-#ifdef BCMDBG
+#ifdef DEBUG
 	/* check for rx fifo 0 overflow */
 	delta = (u16) (wlc->core->macstat_snapshot->rxf0ovfl - rxf0ovfl);
 	if (delta)
@@ -3114,7 +3114,7 @@ static void brcms_c_statsupd(struct brcms_c_info *wlc)
 			wiphy_err(wlc->wiphy, "wl%d: %u tx fifo %d underflows!"
 				  "\n", wlc->pub->unit, delta, i);
 	}
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 	/* merge counters from dma module */
 	for (i = 0; i < NFIFO; i++) {
@@ -5765,7 +5765,7 @@ int brcms_c_module_unregister(struct brcms_pub *pub, const char *name,
 	return -ENODATA;
 }
 
-#ifdef BCMDBG
+#ifdef DEBUG
 static const char * const supr_reason[] = {
 	"None", "PMQ Entry", "Flush request",
 	"Previous frag failure", "Channel mismatch",
@@ -5790,11 +5790,11 @@ static void brcms_c_print_txs_status(u16 s)
 	printk(KERN_DEBUG "    [1]  %d  acked\n",
 	       ((s & TX_STATUS_ACK_RCV) ? 1 : 0));
 }
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 void brcms_c_print_txstatus(struct tx_status *txs)
 {
-#if defined(BCMDBG)
+#if defined(DEBUG)
 	u16 s = txs->status;
 	u16 ackphyrxsh = txs->ackphyrxsh;
 
@@ -5814,7 +5814,7 @@ void brcms_c_print_txstatus(struct tx_status *txs)
 	printk(KERN_DEBUG "RxAckSQ: %04x",
 	       (ackphyrxsh & PRXS1_SQ_MASK) >> PRXS1_SQ_SHIFT);
 	printk(KERN_DEBUG "\n");
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
 }
 
 bool brcms_c_chipmatch(u16 vendor, u16 device)
@@ -5837,7 +5837,7 @@ bool brcms_c_chipmatch(u16 vendor, u16 device)
 	return false;
 }
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 void brcms_c_print_txdesc(struct d11txh *txh)
 {
 	u16 mtcl = le16_to_cpu(txh->MacTxControlLow);
@@ -5919,9 +5919,9 @@ void brcms_c_print_txdesc(struct d11txh *txh)
 			     (u8 *)&rts, sizeof(txh->rts_frame));
 	printk(KERN_DEBUG "\n");
 }
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 static int
 brcms_c_format_flags(const struct brcms_c_bit_desc *bd, u32 flags, char *buf,
 		     int len)
@@ -5975,9 +5975,9 @@ brcms_c_format_flags(const struct brcms_c_bit_desc *bd, u32 flags, char *buf,
 
 	return (int)(p - buf);
 }
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 void brcms_c_print_rxh(struct d11rxhdr *rxh)
 {
 	u16 len = rxh->RxFrameSize;
@@ -6016,7 +6016,7 @@ void brcms_c_print_rxh(struct d11rxhdr *rxh)
 	       (macstatus2 & RXS_AGGTYPE_MASK));
 	printk(KERN_DEBUG "RxTSFTime:       %04x\n", rxh->RxTSFTime);
 }
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
 
 u16 brcms_b_rate_shm_offset(struct brcms_hardware *wlc_hw, u8 rate)
 {
@@ -8346,7 +8346,7 @@ brcms_c_attach(struct brcms_info *wl, struct bcma_device *core, uint unit,
 	wlc->wiphy = wl->wiphy;
 	pub = wlc->pub;
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 	wlc_info_dbg = wlc;
 #endif
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.h b/drivers/net/wireless/brcm80211/brcmsmac/main.h
index adb136e..84a2a0d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.h
@@ -648,7 +648,7 @@ extern void brcms_c_print_txstatus(struct tx_status *txs);
 extern int brcms_b_xmtfifo_sz_get(struct brcms_hardware *wlc_hw, uint fifo,
 		   uint *blocks);
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 extern void brcms_c_print_txdesc(struct d11txh *txh);
 #else
 #define brcms_c_print_txdesc(a)
diff --git a/drivers/net/wireless/brcm80211/brcmutil/utils.c b/drivers/net/wireless/brcm80211/brcmutil/utils.c
index b7537f7..e25fb2d 100644
--- a/drivers/net/wireless/brcm80211/brcmutil/utils.c
+++ b/drivers/net/wireless/brcm80211/brcmutil/utils.c
@@ -240,7 +240,7 @@ struct sk_buff *brcmu_pktq_mdeq(struct pktq *pq, uint prec_bmp,
 }
 EXPORT_SYMBOL(brcmu_pktq_mdeq);
 
-#if defined(BCMDBG)
+#if defined(DEBUG)
 /* pretty hex print a pkt buffer chain */
 void brcmu_prpkt(const char *msg, struct sk_buff *p0)
 {
@@ -253,4 +253,4 @@ void brcmu_prpkt(const char *msg, struct sk_buff *p0)
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, p->data, p->len);
 }
 EXPORT_SYMBOL(brcmu_prpkt);
-#endif				/* defined(BCMDBG) */
+#endif				/* defined(DEBUG) */
diff --git a/drivers/net/wireless/brcm80211/include/brcmu_utils.h b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
index ad249a0..0cde38a 100644
--- a/drivers/net/wireless/brcm80211/include/brcmu_utils.h
+++ b/drivers/net/wireless/brcm80211/include/brcmu_utils.h
@@ -176,10 +176,10 @@ struct ipv4_addr;
 
 /* externs */
 /* format/print */
-#ifdef BCMDBG
+#ifdef DEBUG
 extern void brcmu_prpkt(const char *msg, struct sk_buff *p0);
 #else
 #define brcmu_prpkt(a, b)
-#endif				/* BCMDBG */
+#endif				/* DEBUG */
 
 #endif				/* _BRCMU_UTILS_H_ */
-- 
1.7.8.111.gad25c.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
