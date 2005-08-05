From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (2/8)
Date: Fri, 05 Aug 2005 04:57:48 +0200
Message-ID: <42F2D5AC.1020406@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020203090400020609060706"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020203090400020609060706
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------020203090400020609060706
Content-Type: text/x-patch;
 name="atheros5212-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-2.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros.h	2005-08-05 03:48:35.000000000 +0200
@@ -0,0 +1,180 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+#ifndef _ATHEROS_H
+#define _ATHEROS_H
+
+#include "atheros_dev.h"
+
+typedef enum {
+	PMODE_UNDEFINED        = 0,
+	PMODE_AUTO             = 1,
+	PMODE_AWAKE            = 2,
+	PMODE_FULL_SLEEP       = 3,
+	PMODE_NETWORK_SLEEP    = 4
+} POWER_MODE;
+
+#define IEEE80211_CHAN_2GHZ     0x0080  /* 2 GHz spectrum channel. */
+#define IEEE80211_CHAN_5GHZ     0x0100  /* 5 GHz spectrum channel */
+
+typedef enum {
+	CAP_REG_DMN         = 0,    /* current regulatory domain */
+	CAP_CIPHER          = 1,    /* hardware supports cipher */
+	CAP_TKIP_MIC        = 2,    /* handle TKIP MIC in hardware */
+	CAP_TKIP_SPLIT      = 3,    /* hardware TKIP uses split keys */
+	CAP_PHYCOUNTERS     = 4,    /* hardware PHY error counters */
+	CAP_DIVERSITY       = 5,    /* hardware supports fast diversity */
+	CAP_KEYCACHE_SIZE   = 6,    /* number of entries in key cache */
+	CAP_NUM_TXQUEUES    = 7,    /* number of hardware xmit queues */
+	CAP_VEOL            = 9,    /* hardware supports virtual EOL */
+	CAP_PSPOLL          = 10,   /* hardware has working PS-Poll support */
+	CAP_DIAG            = 11,   /* hardware diagnostic support */
+	CAP_COMPRESSION     = 12,   /* hardware supports compression */
+	CAP_BURST           = 13,   /* hardware supports packet bursting */
+	CAP_FASTFRAME       = 14,   /* hardware supoprts fast frames */
+	CAP_TXPOW           = 15,   /* global tx power limit  */
+	CAP_TPC             = 16    /* per-packet tx power control  */
+} CAPABILITY_TYPE;
+
+typedef enum {
+	CIPHER_WEP 		= 0,
+	CIPHER_AES_OCB 		= 1,
+	CIPHER_AES_CCM		= 2,
+	CIPHER_CKIP		= 3,
+	CIPHER_TKIP		= 4,
+	CIPHER_CLR		= 5,
+	CIPHER_MIC		= 127
+} CIPHER;
+
+typedef enum {
+	CHIP_5GHZ = IEEE80211_CHAN_5GHZ,
+	CHIP_2GHZ = IEEE80211_CHAN_2GHZ,
+} CHIP;
+
+enum version {
+	AR5210  = 0,
+	AR5211  = 1,
+	AR5212  = 2,
+};
+
+enum radio {
+	AR5110  = 0,
+	AR5111  = 1,
+	AR5112  = 2,
+};
+
+/* from madwifi source */
+enum opmode {
+	IEEE80211_M_STA         = 1,    /* infrastructure station */
+	IEEE80211_M_IBSS        = 0,    /* IBSS (adhoc) station */
+	IEEE80211_M_AHDEMO      = 3,    /* Old lucent compatible adhoc demo */
+	IEEE80211_M_HOSTAP      = 6,    /* Software Access Point */
+	IEEE80211_M_MONITOR     = 8     /* Monitor mode */
+};
+
+typedef enum {
+	INT_RX      = 0x00000001,   /* Non-common mapping */
+	INT_RXDESC  = 0x00000002,
+	INT_RXNOFRM = 0x00000008,
+	INT_RXEOL   = 0x00000010,
+	INT_RXORN   = 0x00000020,
+	INT_TX      = 0x00000040,   /* Non-common mapping */
+	INT_TXDESC  = 0x00000080,
+	INT_TXURN   = 0x00000800,
+	INT_MIB     = 0x00001000,
+	INT_RXPHY   = 0x00004000,
+	INT_RXKCM   = 0x00008000,
+	INT_SWBA    = 0x00010000,
+	INT_BMISS   = 0x00040000,
+	INT_BNR     = 0x00100000,   /* Non-common mapping */
+	INT_GPIO    = 0x01000000,
+	INT_FATAL   = 0x40000000,   /* Non-common mapping */
+	INT_GLOBAL  = 0x80000000,   /* Set/clear IER */
+	
+	/* Interrupt bits that map directly to ISR/IMR bits */
+	INT_COMMON  = 	  INT_RXNOFRM
+			| INT_RXDESC
+			| INT_RXEOL
+			| INT_RXORN
+			| INT_TXURN
+			| INT_TXDESC
+			| INT_MIB
+			| INT_RXPHY
+			| INT_RXKCM
+			| INT_SWBA
+			| INT_BMISS
+			| INT_GPIO,
+	
+	INT_NOCARD  = 0xffffffff    /* To signal the card was removed */
+} INT;
+
+
+
+/* declarations and prototypes */
+extern struct iw_handler_def ath_iw_handler_def;
+extern const struct iw_priv_args ieee80211_priv_args[];
+
+/* reg read and write */
+unsigned int ath_reg_read(struct net_device *, unsigned int);
+void ath_reg_write(struct net_device *, unsigned int, unsigned int);
+void ath_reg_disable(struct net_device *, unsigned int, unsigned int);
+void ath_reg_enable(struct net_device *, unsigned int, unsigned int);
+
+/* caps */
+unsigned int ath_get_cap(struct net_device *, CAPABILITY_TYPE,
+		unsigned int, unsigned int *);
+
+/* key */
+unsigned int ath_get_keycache_size(struct net_device *);
+unsigned int ath_reset_keycache(struct net_device *, unsigned short);
+
+/* chans */
+unsigned int ath_get_channels(struct net_device *,
+		unsigned int, unsigned int, unsigned int);
+
+/* beacons */
+unsigned int ath_beacon_queue_setup(struct net_device *);
+
+/* TX/RX */
+struct tx_queue *ath_txq_setup(struct net_device *, int, int);
+unsigned int ath_setup_tx_queue(struct net_device *, unsigned int, 
+		struct tx_queue_info *);
+int ath_startrecv(struct net_device *);
+void ath_draintxq(struct net_device *);
+void ath_stoprecv(struct net_device *);
+
+
+/* init */
+int ath_stop_locked(struct net_device *);
+
+/* interrupts */
+unsigned int ath_set_interruptmask(struct net_device *, unsigned int);
+
+
+#endif
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_defs.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_defs.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_defs.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_defs.h	2005-08-05 03:48:35.000000000 +0200
@@ -0,0 +1,82 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+#define ATHEROS_TXBUF		200
+
+#define TXQ_FLAG_TXOKINT_ENABLE		0x0001
+#define TXQ_FLAG_TXERRINT_ENABLE	0x0001
+#define TXQ_FLAG_TXDESCINT_ENABLE	0x0002
+#define TXQ_FLAG_TXEOLINT_ENABLE	0x0004
+#define TXQ_FLAG_TXURNINT_ENABLE	0x0008
+#define TXQ_FLAG_BACKOFF_DISABLE	0x0010
+#define TXQ_FLAG_COMPRESSION_ENABLE	0x0020
+#define TXQ_FLAG_RDYTIME_EXP_POLICY_ENABLE	0x0040
+#define TXQ_FLAG_FRAG_BURST_BACKOFF_ENABLE	0x0080
+
+#define	TX_QUEUE_INACTIVE	0            /* queue is inactive/unused */
+#define TX_QUEUE_DATA		1            /* data xmit q's */
+#define TX_QUEUE_BEACON		2            /* beacon xmit q */
+#define TX_QUEUE_CAB		3            /* "crap after beacon" xmit q */
+#define TX_QUEUE_PSPOLL		4            /* power-save poll xmit q */
+
+#define WME_AC_BK		0            /* background access category */
+#define WME_AC_BE		1            /* best effort access category*/
+#define WME_AC_VI		2            /* video access category */
+#define WME_AC_VO		3            /* voice access category */
+#define WME_UPSD		4            /* uplink power save */
+
+
+#define	IEEE80211_RATE_MAXSIZE	8
+
+
+#define RX_FILTER_PHYERR	0x100
+#define RX_FILTER_PHYRADAR	0x200
+
+#define       RXERR_CRC           0x01    /* CRC error on frame */
+#define       RXERR_PHY           0x02    /* PHY error, rs_phyerr is valid */
+#define       RXERR_FIFO          0x04    /* fifo overrun */
+#define       RXERR_DECRYPT       0x08    /* non-Michael decrypt error */
+#define       RXERR_MIC           0x10    /* Michael MIC decrypt error */
+
+#define ATH_MIN_MTU     32
+#define ATH_MAX_MTU     2290
+
+
+#define IEEE80211_IOCTL_SETPARAM        (SIOCIWFIRSTPRIV+0)
+#define IEEE80211_IOCTL_GETPARAM        (SIOCIWFIRSTPRIV+1)
+#define IEEE80211_IOCTL_SETKEY          (SIOCIWFIRSTPRIV+2)
+#define IEEE80211_IOCTL_DELKEY          (SIOCIWFIRSTPRIV+4)
+#define IEEE80211_IOCTL_SETMLME         (SIOCIWFIRSTPRIV+6)
+#define IEEE80211_IOCTL_SETOPTIE        (SIOCIWFIRSTPRIV+8)
+#define IEEE80211_IOCTL_GETOPTIE        (SIOCIWFIRSTPRIV+9)
+#define IEEE80211_IOCTL_ADDMAC          (SIOCIWFIRSTPRIV+10)
+#define IEEE80211_IOCTL_DELMAC          (SIOCIWFIRSTPRIV+12)
+#define IEEE80211_IOCTL_CHANLIST        (SIOCIWFIRSTPRIV+14)
+
+#define IEEE80211_MAX_OPT_IE    256
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_dev.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_dev.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_dev.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_dev.h	2005-08-05 03:48:35.000000000 +0200
@@ -0,0 +1,305 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+#ifndef _ATHEROS_DEV_H
+#define _ATHEROS_DEV_H
+
+#include <linux/kernel.h>
+#include <linux/interrupt.h>
+#include <asm/semaphore.h>
+#include <linux/netdevice.h>
+
+#include "eeprom.h"
+#include "mode_tables.h"
+/*
+ * just a short memo: 
+ *
+ * offsets inside binary hal
+ *
+ * 0x1b0        -  current operating mode (STATION/IBSS/ADHOC etc.)
+ *
+ */
+
+
+struct mib_stats {
+	unsigned int       ackrcv_bad;
+	unsigned int       rts_bad;
+	unsigned int       rts_good;
+	unsigned int       fcs_bad;
+	unsigned int       beacons;
+};
+
+struct beacon_state {
+	unsigned int       bs_nexttbtt;            /* next beacon in TU */
+	unsigned int       bs_nextdtim;            /* next DTIM in TU */
+	unsigned int       bs_intval;              /* beacon interval+flags */
+#define BEACON_PERIOD       0x0000ffff      /* beacon interval period */
+#define BEACON_ENA          0x00800000      /* beacon xmit enable */
+#define BEACON_RESET_TSF    0x01000000      /* clear TSF */
+	unsigned int       bs_dtimperiod;
+	unsigned short     bs_cfpperiod;           /* CFP period in TU */
+	unsigned short     bs_cfpmaxduration;      /* max CFP duration in TU */
+	unsigned int       bs_cfpnext;             /* next CFP in TU */
+	unsigned short     bs_timoffset;           /* byte offset to TIM bitmap */
+	unsigned short     bs_bmissthreshold;      /* beacon miss threshold */
+	unsigned int       bs_sleepduration;       /* max sleep duration */
+};
+
+struct gain_delta {
+	unsigned short values[7];
+	unsigned int gain;
+	char buf[16];
+};
+
+struct gain_desc {
+	unsigned int number;
+	unsigned int gain;
+	unsigned int t;
+	unsigned int low;
+	unsigned int high;
+	unsigned int correction;
+	unsigned int active;
+	struct gain_delta *delta;
+};
+
+struct chip_gain_desc {
+	unsigned int entrycnt;
+	unsigned int defentry;
+	struct gain_delta deltas[10];
+};
+
+struct keyval {
+	unsigned char	kv_type;                /* one of CIPHER */
+	unsigned char	kv_pad;
+	unsigned short	kv_len;                 /* length in bits */
+	unsigned char	kv_val[16];             /* enough for 128-bit keys */
+	unsigned char	kv_mic[8];              /* TKIP MIC key */
+};
+
+struct tx_queue_info {
+        unsigned int	tqi_ver;                /* hal TXQ version */
+	unsigned int	tqi_type;
+        unsigned int	tqi_subtype;       /* subtype if applicable */
+        unsigned int 	tqi_qflags;          /* flags (see above) */
+        unsigned int    tqi_priority;           /* (not used) */
+        unsigned int       tqi_aifs;               /* aifs */
+        unsigned int       tqi_cwmin;              /* cwMin */
+        unsigned int       tqi_cwmax;              /* cwMax */
+        unsigned short       tqi_shretry;            /* rts retry limit */
+        unsigned short       tqi_lgretry;            /* long retry limit (not used)*/
+        unsigned int       tqi_cbrPeriod;
+        unsigned int       tqi_cbrOverflowLimit;
+        unsigned int       tqi_burstTime;
+        unsigned int       tqi_readyTime;
+	unsigned int	tqi_flags;
+};
+
+/*      
+ * Data transmit queue state.  One of these exists for each
+ * hardware transmit queue.  Packets sent to us from above
+ * are assigned to queues based on their priority.  Not all
+ * devices support a complete set of hardware transmit queues.
+ * For those devices the array sc_ac2q will map multiple
+ * priorities to fewer hardware queues (typically all to one
+ * hardware queue).             
+ */     
+struct tx_queue {
+	u_int                   axq_qnum;       /* hardware q number */
+	u_int                   axq_depth;      /* queue depth (stat only) */
+	u_int                   axq_intrcnt;    /* interrupt count */
+	u_int32_t               *axq_link;      /* link ptr in last TX desc */
+	//STAILQ_HEAD(, ath_buf)  axq_q;          /* transmit queue */
+	spinlock_t              axq_lock;       /* lock on q and link */
+	/*      
+	 * State for patching up CTS when bursting.
+	 */
+	struct  ath_buf         *axq_linkbuf;   /* va of last buffer */
+	struct  ath_desc        *axq_lastdsWithCTS;
+	/* first desc of last descriptor
+	 * that contains CTS */
+	struct  ath_desc        *axq_gatingds;  /* final desc of the gating desc
+						 * that determines whether
+						 * lastdsWithCTS has been DMA'ed
+						 * or not */
+};
+
+
+struct atheros_priv {
+	struct tasklet_struct	txtq;
+	struct tasklet_struct	bmisstq;
+	struct tasklet_struct	fataltq;
+	struct tasklet_struct	rxtq;
+	struct tasklet_struct	rxorntq;
+	
+	void 			*busdev;
+	unsigned int		pmode;		/* current power mode */
+
+	unsigned char		mac[6];
+	unsigned int		chan;
+	
+	unsigned int		mac_version;
+	unsigned int		mac_revision;
+	unsigned int 		phy_revision;
+	unsigned int		rev_2ghz;
+	unsigned int		rev_5ghz;
+	
+	unsigned int		version;
+	unsigned int		radio;
+	unsigned int		domain;
+	struct gain_desc	gaindesc;
+
+	unsigned int		atim_win; /* thats quite possible ;p */
+	unsigned int		aifs;
+	unsigned int		enableqos;
+
+	/* BEACON QUEUE */
+	unsigned int		beacon_q;	/*number of a beacon queue */
+	
+	/* TX QUEUE SECTION */
+	spinlock_t		tx_buflock;
+	int			tx_timer;
+	unsigned int		tx_setup;
+	unsigned int		tx_intr_period;
+	struct tx_queue_info	txq_info[16];
+	struct tx_queue		tx_queues[16];
+
+	/* CAB QUEUE */
+	struct tx_queue_info	*cabq;
+
+	/* rx/tx links */
+	unsigned int		rxlink;
+
+	/* DEVICE STATISTICS */
+	struct iw_statistics	stats;
+	struct net_device_stats devstats;
+
+	/* RATES */
+	struct rate_table 	*rates[8];
+	struct rate_table	*currate;
+	
+	unsigned int		swretry;
+	unsigned int		hwtxtrycount;
+	unsigned int		txlimit;
+	
+	unsigned int		turbo; /* turbo mode supported ? */
+	
+	unsigned int		pwr_limit;
+	unsigned int		pwroverride;
+	
+	unsigned int		slot_time;
+	unsigned int		ack_timeout;
+	unsigned int		cts_timeout;
+
+	unsigned int		enable32clk;
+	
+	unsigned int		beacon_interval;
+	
+	unsigned int 		mretry;
+	unsigned int		disable_hw_counters;
+	unsigned int		common;
+
+	unsigned char 		keymap[8];
+	
+	unsigned char		tpc;
+	unsigned char		cts;
+	unsigned int		divctrl;
+	unsigned int		iqcal;
+	int			scaletpfactor;
+	unsigned char		bssid[6];
+	
+	unsigned int		max_queue;
+	
+	unsigned int		max_keycache;
+	unsigned int		keycache_size;
+	unsigned int		ext_keycache;
+
+	unsigned int		intr_ready;
+	unsigned int 		invalid;
+	unsigned int		intr_mask;
+
+	unsigned int		mib_enabled;
+	struct mib_stats	mib_stats;
+	struct eeprom_info	eeinfo;
+};
+
+struct ath_rx_status {
+	unsigned short rs_datalen;     /* rx frame length */
+	unsigned short rs_tstamp;      /* h/w assigned timestamp */
+	unsigned char rs_status;      /* rx status, 0 => recv ok */
+	unsigned char rs_phyerr;      /* phy error code */
+	signed char rs_rssi;        /* rx frame RSSI */
+	unsigned char rs_keyix;       /* key cache index */
+	unsigned char rs_rate;        /* h/w receive rate index */
+	unsigned char rs_antenna;     /* antenna information */
+	unsigned char rs_more;        /* more descriptors follow */
+};
+
+struct ath_tx_status {
+	unsigned short ts_seqnum;      /* h/w assigned sequence number */
+	unsigned short ts_tstamp;      /* h/w assigned timestamp */
+	unsigned char ts_status;      /* frame status, 0 => xmit ok */
+	unsigned char ts_rate;        /* h/w transmit rate index */
+//#define HAL_TXSTAT_ALTRATE      0x80    /* alternate xmit rate used */
+	signed char ts_rssi;        /* tx ack RSSI */
+	unsigned char ts_shortretry;  /* # short retries */
+	unsigned char ts_longretry;   /* # long retries */
+	unsigned char ts_virtcol;     /* virtual collision count */
+	unsigned char ts_antenna;     /* antenna information */
+};
+
+struct ath_desc {
+	unsigned int link;
+	unsigned int data;
+	unsigned int ctl0;
+	unsigned int ctl1;
+	
+	union {
+		struct {
+			unsigned int ctl2;
+			unsigned int ctl3;
+			unsigned int status0;
+			unsigned int status1;
+		} tx;
+		struct {
+			unsigned int status0;
+			unsigned int status1;
+		} rx;
+	} u;
+
+	union {
+		struct ath_tx_status	txstat;
+		struct ath_rx_status	rxstat;
+	} s;
+} __attribute__((__packed__));
+
+#include "mode_tables.h"
+
+#endif
+
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_id.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_id.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_id.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_id.h	2005-08-05 03:48:35.000000000 +0200
@@ -0,0 +1,59 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+#define		PCI_VENDOR_ID_ATHEROS	0x168c
+#define		ATHEROS_5212		0x13
+
+
+#define MAX_GPIO        10
+
+/*
+ * Common silicon revision/version values
+ */
+#define SREV_REV_FPGA   1
+#define SREV_REV_PROTO  2
+#define SREV_REV_PROTOA 3
+#define SREV_REV_AR5210 4
+#define SREV_REV_AR5210M        5
+#define SREV_REV_AR5210M23      7
+#define SREV_REV_AR521023       8
+
+#define SREV_VER_AR5210 0
+#define SREV_VER_AR5311 1
+#define SREV_VER_AR5311A        2
+#define SREV_VER_AR5311B        3
+#define SREV_VER_AR5211 4
+#define SREV_VER_AR5212 5
+
+#define SREV_RAD_5111   0x10
+#define SREV_RAD_5111A  0x15
+#define SREV_RAD_2111   0x20
+#define SREV_RAD_5112   0x30
+#define SREV_RAD_5112A  0x35
+#define SREV_RAD_2112A  0x45
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_registers.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_registers.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/atheros_registers.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/atheros_registers.h	2005-08-05 03:48:35.000000000 +0200
@@ -0,0 +1,1341 @@
+/* this might be a problem, right ? :) */
+
+/*	$OpenBSD: ar5212reg.h,v 1.1 2005/02/19 16:58:00 reyk Exp $	*/
+
+/*
+ * Copyright (c) 2004, 2005 Reyk Floeter <reyk@vantronix.net>
+ *
+ * Permission to use, copy, modify, and distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*
+ * Known registers of the Atheros AR5001 Wireless LAN chipsets
+ * (AR5212/AR5311).
+ */
+
+#ifndef _AR5212_REG_H
+#define _AR5212_REG_H
+
+/*
+ * Command register
+ */
+#define AR5212_CR		0x0008
+#define AR5212_CR_RXE	0x00000004
+#define AR5212_CR_RXD	0x00000020
+#define AR5212_CR_SWI	0x00000040
+
+/*
+ * Receive queue descriptor pointer register
+ */
+#define AR5212_RXDP	0x000c
+
+/*
+ * Configuration and status register
+ */
+#define AR5212_CFG			0x0014
+#define AR5212_CFG_SWTD		0x00000001
+#define AR5212_CFG_SWTB		0x00000002
+#define AR5212_CFG_SWRD		0x00000004
+#define AR5212_CFG_SWRB		0x00000008
+#define AR5212_CFG_SWRG		0x00000010
+#define AR5212_CFG_ADHOC		0x00000020
+#define AR5212_CFG_PHY_OK		0x00000100
+#define AR5212_CFG_EEBS		0x00000200
+#define	AR5212_CFG_CLKGD		0x00000400
+#define	AR5212_CFG_PCI_THRES	0x00060000
+#define	AR5212_CFG_PCI_THRES_S	17
+
+/*
+ * Interrupt enable register
+ */
+#define AR5212_IER		0x0024
+#define AR5212_IER_DISABLE	0x00000000
+#define AR5212_IER_ENABLE	0x00000001
+
+/*
+ * Transmit configuration register
+ */
+#define AR5212_TXCFG		0x0030
+#define AR5212_TXCFG_SDMAMR	0x00000007
+#define AR5212_TXCFG_B_MODE	0x00000008
+#define AR5212_TXCFG_TXFULL	0x000003f0
+#define AR5212_TXCFG_TXFULL_S	4
+#define AR5212_TXCFG_TXFULL_0B	0x00000000
+#define AR5212_TXCFG_TXFULL_64B	0x00000010
+#define AR5212_TXCFG_TXFULL_128B	0x00000020
+#define AR5212_TXCFG_TXFULL_192B	0x00000030
+#define AR5212_TXCFG_TXFULL_256B	0x00000040
+#define AR5212_TXCFG_TXCONT_ENABLE	0x00000080
+#define AR5212_TXCFG_JUMBO_TXE	0x00000400
+#define AR5212_TXCFG_RTSRND	0x00001000
+#define AR5212_TXCFG_FRMPAD_DIS	0x00002000
+#define AR5212_TXCFG_RDY_DIS	0x00004000
+
+/*
+ * Receive configuration register
+ */
+#define AR5212_RXCFG			0x0034
+#define AR5212_RXCFG_SDMAMW		0x00000007
+#define	AR5311_RXCFG_DEFAULT_ANTENNA	0x00000008
+#define AR5212_RXCFG_ZLFDMA		0x00000010
+#define AR5212_RXCFG_JUMBO_RXE		0x00000020
+#define AR5212_RXCFG_JUMBO_WRAP		0x00000040
+
+/*
+ * MIB control register
+ */
+#define AR5212_MIBC		0x0040
+#define AR5212_MIBC_COW		0x00000001
+#define AR5212_MIBC_FMC		0x00000002
+#define AR5212_MIBC_CMC		0x00000004
+#define AR5212_MIBC_MCS		0x00000008
+
+/*
+ * Timeout prescale register
+ */
+#define AR5212_TOPS		0x0044
+#define	AR5212_TOPS_M		0x0000ffff
+
+/*
+ * Receive timeout register (no frame received)
+ */
+#define AR5212_RXNOFRM		0x0048
+#define	AR5212_RXNOFRM_M		0x000003ff
+
+/*
+ * Transmit timeout register (no frame sent)
+ */
+#define AR5212_TXNOFRM		0x004c
+#define	AR5212_TXNOFRM_M		0x000003ff
+#define	AR5212_TXNOFRM_QCU		0x000ffc00
+
+/*
+ * Receive frame gap timeout register
+ */
+#define AR5212_RPGTO		0x0050
+#define AR5212_RPGTO_M		0x000003ff
+
+/*
+ * Receive frame count limit register
+ */
+#define AR5212_RFCNT		0x0054
+#define AR5212_RFCNT_M		0x0000001f
+
+/*
+ * Misc settings register
+ */
+#define AR5212_MISC		0x0058
+#define	AR5212_MISC_DMA_OBS_M	0x000001e0
+#define	AR5212_MISC_DMA_OBS_S	5
+#define	AR5212_MISC_MISC_OBS_M	0x00000e00
+#define	AR5212_MISC_MISC_OBS_S	9
+#define	AR5212_MISC_MAC_OBS_LSB_M	0x00007000
+#define	AR5212_MISC_MAC_OBS_LSB_S	12
+#define	AR5212_MISC_MAC_OBS_MSB_M	0x00038000
+#define	AR5212_MISC_MAC_OBS_MSB_S	15
+
+/*
+ * Primary interrupt status register
+ */
+#define AR5212_PISR		0x0080
+#define AR5212_PISR_RXOK		0x00000001
+#define AR5212_PISR_RXDESC		0x00000002
+#define AR5212_PISR_RXERR		0x00000004
+#define AR5212_PISR_RXNOFRM	0x00000008
+#define AR5212_PISR_RXEOL		0x00000010
+#define AR5212_PISR_RXORN		0x00000020
+#define AR5212_PISR_TXOK		0x00000040
+#define AR5212_PISR_TXDESC		0x00000080
+#define AR5212_PISR_TXERR		0x00000100
+#define AR5212_PISR_TXNOFRM	0x00000200
+#define AR5212_PISR_TXEOL		0x00000400
+#define AR5212_PISR_TXURN		0x00000800
+#define AR5212_PISR_MIB		0x00001000
+#define AR5212_PISR_SWI		0x00002000
+#define AR5212_PISR_RXPHY		0x00004000
+#define AR5212_PISR_RXKCM		0x00008000
+#define AR5212_PISR_SWBA		0x00010000
+#define AR5212_PISR_BRSSI		0x00020000
+#define AR5212_PISR_BMISS		0x00040000
+#define AR5212_PISR_HIUERR		0x00080000
+#define AR5212_PISR_BNR		0x00100000
+#define AR5212_PISR_RXCHIRP	0x00200000
+#define AR5212_PISR_TIM		0x00800000
+#define AR5212_PISR_BCNMISC	0x00800000
+#define AR5212_PISR_GPIO		0x01000000
+#define AR5212_PISR_QCBRORN	0x02000000
+#define AR5212_PISR_QCBRURN	0x04000000
+#define AR5212_PISR_QTRIG		0x08000000
+
+/*
+ * Secondary interrupt status registers (0 - 4)
+ */
+#define AR5212_SISR0		0x0084
+#define AR5212_SISR0_QCU_TXOK	0x000003ff
+#define AR5212_SISR0_QCU_TXDESC	0x03ff0000
+
+#define AR5212_SISR1		0x0088
+#define AR5212_SISR1_QCU_TXERR	0x000003ff
+#define AR5212_SISR1_QCU_TXEOL	0x03ff0000
+
+#define AR5212_SISR2		0x008c
+#define AR5212_SISR2_QCU_TXURN	0x000003ff
+#define	AR5212_SISR2_MCABT		0x00100000
+#define	AR5212_SISR2_SSERR		0x00200000
+#define	AR5212_SISR2_DPERR		0x00400000
+#define	AR5212_SISR2_TIM		0x01000000
+#define	AR5212_SISR2_CAB_END	0x02000000
+#define	AR5212_SISR2_DTIM_SYNC	0x04000000
+#define	AR5212_SISR2_BCN_TIMEOUT	0x08000000
+#define	AR5212_SISR2_CAB_TIMEOUT	0x10000000
+#define	AR5212_SISR2_DTIM		0x20000000
+
+#define AR5212_SISR3		0x0090
+#define AR5212_SISR3_QCBRORN	0x000003ff
+#define AR5212_SISR3_QCBRURN	0x03ff0000
+
+#define AR5212_SISR4		0x0094
+#define AR5212_SISR4_QTRIG		0x000003ff
+
+/*
+ * Shadow read-and-clear interrupt status registers
+ */
+#define AR5212_RAC_PISR	0x00c0
+#define AR5212_RAC_SISR0	0x00c4
+#define AR5212_RAC_SISR1	0x00c8
+#define AR5212_RAC_SISR2	0x00cc
+#define AR5212_RAC_SISR3	0c00d0
+#define AR5212_RAC_SISR4	0c00d4
+
+/*
+ * Primary interrupt mask register
+ */
+#define AR5212_PIMR		0x00a0
+#define AR5212_PIMR_RXOK		0x00000001
+#define AR5212_PIMR_RXDESC		0x00000002
+#define AR5212_PIMR_RXERR		0x00000004
+#define AR5212_PIMR_RXNOFRM	0x00000008
+#define AR5212_PIMR_RXEOL		0x00000010
+#define AR5212_PIMR_RXORN		0x00000020
+#define AR5212_PIMR_TXOK		0x00000040
+#define AR5212_PIMR_TXDESC		0x00000080
+#define AR5212_PIMR_TXERR		0x00000100
+#define AR5212_PIMR_TXNOFRM	0x00000200
+#define AR5212_PIMR_TXEOL		0x00000400
+#define AR5212_PIMR_TXURN		0x00000800
+#define AR5212_PIMR_MIB		0x00001000
+#define AR5212_PIMR_SWI		0x00002000
+#define AR5212_PIMR_RXPHY		0x00004000
+#define AR5212_PIMR_RXKCM		0x00008000
+#define AR5212_PIMR_SWBA		0x00010000
+#define AR5212_PIMR_BRSSI		0x00020000
+#define AR5212_PIMR_BMISS		0x00040000
+#define AR5212_PIMR_HIUERR		0x00080000
+#define AR5212_PIMR_BNR		0x00100000
+#define AR5212_PIMR_RXCHIRP	0x00200000
+#define AR5212_PIMR_TIM		0x00800000
+#define AR5212_PIMR_BCNMISC	0x00800000
+#define AR5212_PIMR_GPIO		0x01000000
+#define AR5212_PIMR_QCBRORN	0x02000000
+#define AR5212_PIMR_QCBRURN	0x04000000
+#define AR5212_PIMR_QTRIG		0x08000000
+
+/*
+ * Secondary interrupt mask registers (0 - 4)
+ */
+#define AR5212_SIMR0		0x00a4
+#define AR5212_SIMR0_QCU_TXOK	0x000003ff
+#define AR5212_SIMR0_QCU_TXOK_S	0
+#define AR5212_SIMR0_QCU_TXDESC	0x03ff0000
+#define AR5212_SIMR0_QCU_TXDESC_S	16
+
+#define AR5212_SIMR1		0x00a8
+#define AR5212_SIMR1_QCU_TXERR	0x000003ff
+#define AR5212_SIMR1_QCU_TXERR_S	0
+#define AR5212_SIMR1_QCU_TXEOL	0x03ff0000
+#define AR5212_SIMR1_QCU_TXEOL_S	16
+
+#define AR5212_SIMR2		0x00ac
+#define AR5212_SIMR2_QCU_TXURN	0x000003ff
+#define AR5212_SIMR2_QCU_TXURN_S	0
+#define	AR5212_SIMR2_MCABT		0x00100000
+#define	AR5212_SIMR2_SSERR		0x00200000
+#define	AR5212_SIMR2_DPERR		0x00400000
+#define	AR5212_SIMR2_TIM		0x01000000
+#define	AR5212_SIMR2_CAB_END	0x02000000
+#define	AR5212_SIMR2_DTIM_SYNC	0x04000000
+#define	AR5212_SIMR2_BCN_TIMEOUT	0x08000000
+#define	AR5212_SIMR2_CAB_TIMEOUT	0x10000000
+#define	AR5212_SIMR2_DTIM		0x20000000
+
+#define AR5212_SIMR3		0x00b0
+#define AR5212_SIMR3_QCBRORN	0x000003ff
+#define AR5212_SIMR3_QCBRORN_S	0
+#define AR5212_SIMR3_QCBRURN	0x03ff0000
+#define AR5212_SIMR3_QCBRURN_S	16
+
+#define AR5212_SIMR4		0x00b4
+#define AR5212_SIMR4_QTRIG		0x000003ff
+#define AR5212_SIMR4_QTRIG_S	0
+
+/*
+ * Decompression mask registers
+ */
+#define AR5212_DCM_ADDR	0x0400
+#define AR5212_DCM_DATA	0x0404
+
+/*
+ * Decompression configuration registers
+ */
+#define AR5212_DCCFG	0x0420
+
+/*
+ * Compression configuration registers
+ */
+#define AR5212_CCFG	0x0600
+#define AR5212_CCFG_CUP	0x0604
+
+/*
+ * Compression performance counter registers
+ */
+#define AR5212_CPC0	0x0610
+#define AR5212_CPC1	0x0614
+#define AR5212_CPC2	0x0618
+#define AR5212_CPC3	0x061c
+#define AR5212_CPCORN	0x0620
+
+/*
+ * Queue control unit (QCU) registers (0 - 9)
+ */
+#define	AR5212_QCU(_n, _a)		(((_n) << 2) + _a)
+
+/*
+ * QCU Transmit descriptor pointer registers
+ */
+#define AR5212_QCU_TXDP(_n)	AR5212_QCU(_n, 0x0800)
+
+/*
+ * QCU Transmit enable register
+ */
+#define AR5212_QCU_TXE		0x0840
+
+/*
+ * QCU Transmit disable register
+ */
+#define AR5212_QCU_TXD		0x0880
+
+/*
+ * QCU CBR configuration registers
+ */
+#define	AR5212_QCU_CBRCFG(_n)		AR5212_QCU(_n, 0x08c0)
+#define	AR5212_QCU_CBRCFG_INTVAL		0x00ffffff
+#define AR5212_QCU_CBRCFG_INTVAL_S		0
+#define	AR5212_QCU_CBRCFG_ORN_THRES	0xff000000
+#define AR5212_QCU_CBRCFG_ORN_THRES_S	24
+
+/*
+ * QCU Ready time configuration registers
+ */
+#define	AR5212_QCU_RDYTIMECFG(_n)		AR5212_QCU(_n, 0x0900)
+#define	AR5212_QCU_RDYTIMECFG_INTVAL	0x00ffffff
+#define AR5212_QCU_RDYTIMECFG_INTVAL_S	0
+#define	AR5212_QCU_RDYTIMECFG_DURATION	0x00ffffff
+#define	AR5212_QCU_RDYTIMECFG_ENABLE	0x01000000
+
+/*
+ * QCU one shot arm set registers
+ */
+#define	AR5212_QCU_ONESHOTARMS(_n)	AR5212_QCU(_n, 0x0940)
+#define	AR5212_QCU_ONESHOTARMS_M	0x0000ffff
+
+/*
+ * QCU one shot arm clear registers
+ */
+#define	AR5212_QCU_ONESHOTARMC(_n)	AR5212_QCU(_n, 0x0980)
+#define	AR5212_QCU_ONESHOTARMC_M	0x0000ffff
+
+/*
+ * QCU misc registers
+ */
+#define AR5212_QCU_MISC(_n)		AR5212_QCU(_n, 0x09c0)
+#define	AR5212_QCU_MISC_FRSHED_M		0x0000000f
+#define	AR5212_QCU_MISC_FRSHED_ASAP	0
+#define	AR5212_QCU_MISC_FRSHED_CBR		1
+#define	AR5212_QCU_MISC_FRSHED_DBA_GT	2
+#define	AR5212_QCU_MISC_FRSHED_TIM_GT	3
+#define	AR5212_QCU_MISC_FRSHED_BCN_SENT_GT	4
+#define	AR5212_QCU_MISC_ONESHOT_ENABLE	0x00000010
+#define	AR5212_QCU_MISC_CBREXP		0x00000020
+#define	AR5212_QCU_MISC_CBREXP_BCN		0x00000040
+#define	AR5212_QCU_MISC_BCN_ENABLE		0x00000080
+#define	AR5212_QCU_MISC_CBR_THRES_ENABLE	0x00000100
+#define	AR5212_QCU_MISC_TXE		0x00000200
+#define	AR5212_QCU_MISC_CBR		0x00000400
+#define	AR5212_QCU_MISC_DCU_EARLY		0x00000800
+
+/*
+ * QCU status registers
+ */
+#define AR5212_QCU_STS(_n)		AR5212_QCU(_n, 0x0a00)
+#define	AR5212_QCU_STS_FRMPENDCNT	0x00000003
+#define	AR5212_QCU_STS_CBREXPCNT	0x0000ff00
+
+/*
+ * QCU ready time shutdown register
+ */
+#define AR5212_QCU_RDYTIMESHDN	0x0a40
+#define AR5212_QCU_RDYTIMESHDN_M	0x000003ff
+
+/*
+ * QCU compression buffer base registers
+ */
+#define AR5212_QCU_CBB_SELECT	0x0b00
+#define AR5212_QCU_CBB_ADDR	0x0b04
+
+/*
+ * QCU compression buffer configuration register
+ */
+#define AR5212_QCU_CBCFG	0x0b08
+
+/*
+ * DCF control unit (DCU) registers (0 - 9)
+ */
+#define	AR5212_DCU(_n, _a)		AR5212_QCU(_n, _a)
+
+/*
+ * DCU QCU mask registers
+ */
+#define AR5212_DCU_QCUMASK(_n)	AR5212_DCU(_n, 0x1000)
+#define AR5212_DCU_QCUMASK_M	0x000003ff
+
+/*
+ * DCU local IFS settings register
+ */
+#define AR5212_DCU_LCL_IFS(_n)		AR5212_DCU(_n, 0x1040)
+#define	AR5212_DCU_LCL_IFS_CW_MIN	        0x000003ff
+#define	AR5212_DCU_LCL_IFS_CW_MIN_S	0
+#define	AR5212_DCU_LCL_IFS_CW_MAX	        0x000ffc00
+#define	AR5212_DCU_LCL_IFS_CW_MAX_S	10
+#define	AR5212_DCU_LCL_IFS_AIFS		0x0ff00000
+#define	AR5212_DCU_LCL_IFS_AIFS_S		20
+
+/*
+ * DCU retry limit registers
+ */
+#define AR5212_DCU_RETRY_LMT(_n)		AR5212_DCU(_n, 0x1080)
+#define AR5212_DCU_RETRY_LMT_SH_RETRY	0x0000000f
+#define AR5212_DCU_RETRY_LMT_SH_RETRY_S	0
+#define AR5212_DCU_RETRY_LMT_LG_RETRY	0x000000f0
+#define AR5212_DCU_RETRY_LMT_LG_RETRY_S	4
+#define AR5212_DCU_RETRY_LMT_SSH_RETRY	0x00003f00
+#define AR5212_DCU_RETRY_LMT_SSH_RETRY_S	8
+#define AR5212_DCU_RETRY_LMT_SLG_RETRY	0x000fc000
+#define AR5212_DCU_RETRY_LMT_SLG_RETRY_S	14
+
+/*
+ * DCU channel time registers
+ */
+#define AR5212_DCU_CHAN_TIME(_n)		AR5212_DCU(_n, 0x10c0)
+#define	AR5212_DCU_CHAN_TIME_DUR		0x000fffff
+#define	AR5212_DCU_CHAN_TIME_DUR_S		0
+#define	AR5212_DCU_CHAN_TIME_ENABLE	0x00100000
+
+/*
+ * DCU misc registers
+ */
+#define AR5212_DCU_MISC(_n)		AR5212_DCU(_n, 0x1100)
+#define	AR5212_DCU_MISC_BACKOFF		0x000007ff
+#define AR5212_DCU_MISC_BACKOFF_FRAG	0x00000200
+#define	AR5212_DCU_MISC_HCFPOLL_ENABLE	0x00000800
+#define	AR5212_DCU_MISC_BACKOFF_PERSIST	0x00001000
+#define	AR5212_DCU_MISC_FRMPRFTCH_ENABLE	0x00002000
+#define	AR5212_DCU_MISC_VIRTCOL		0x0000c000
+#define	AR5212_DCU_MISC_VIRTCOL_NORMAL	0
+#define	AR5212_DCU_MISC_VIRTCOL_MODIFIED	1
+#define	AR5212_DCU_MISC_VIRTCOL_IGNORE	2
+#define	AR5212_DCU_MISC_BCN_ENABLE		0x00010000
+#define	AR5212_DCU_MISC_ARBLOCK_CTL	0x00060000
+#define	AR5212_DCU_MISC_ARBLOCK_CTL_S	17
+#define	AR5212_DCU_MISC_ARBLOCK_CTL_NONE	0
+#define	AR5212_DCU_MISC_ARBLOCK_CTL_INTFRM	1
+#define	AR5212_DCU_MISC_ARBLOCK_CTL_GLOBAL	2
+#define	AR5212_DCU_MISC_ARBLOCK_IGNORE	0x00080000
+#define	AR5212_DCU_MISC_SEQ_NUM_INCR_DIS	0x00100000
+#define	AR5212_DCU_MISC_POST_FR_BKOFF_DIS	0x00200000
+#define	AR5212_DCU_MISC_VIRT_COLL_POLICY	0x00400000
+#define	AR5212_DCU_MISC_BLOWN_IFS_POLICY	0x00800000
+#define	AR5212_DCU_MISC_SEQNUM_CTL		0x01000000
+
+/*
+ * DCU frame sequence number registers
+ */
+#define AR5212_DCU_SEQNUM(_n)	AR5212_DCU(_n, 0x1140)
+#define	AR5212_DCU_SEQNUM_M	0x00000fff
+/*
+ * DCU global IFS SIFS registers
+ */
+#define AR5212_DCU_GBL_IFS_SIFS	0x1030
+#define AR5212_DCU_GBL_IFS_SIFS_M	0x0000ffff
+
+/*
+ * DCU global IFS slot interval registers
+ */
+#define AR5212_DCU_GBL_IFS_SLOT	0x1070
+#define AR5212_DCU_GBL_IFS_SLOT_M	0x0000ffff
+
+/*
+ * DCU global IFS EIFS registers
+ */
+#define AR5212_DCU_GBL_IFS_EIFS	0x10b0
+#define AR5212_DCU_GBL_IFS_EIFS_M	0x0000ffff
+
+/*
+ * DCU global IFS misc registers
+ */
+#define AR5212_DCU_GBL_IFS_MISC			0x10f0
+#define	AR5212_DCU_GBL_IFS_MISC_LFSR_SLICE		0x00000007
+#define	AR5212_DCU_GBL_IFS_MISC_TURBO_MODE		0x00000008
+#define	AR5212_DCU_GBL_IFS_MISC_SIFS_DUR_USEC	0x000003f0
+#define	AR5212_DCU_GBL_IFS_MISC_USEC_DUR		0x000ffc00
+#define	AR5212_DCU_GBL_IFS_MISC_DCU_ARB_DELAY	0x00300000
+
+/*
+ * DCU frame prefetch control register
+ */
+#define AR5212_DCU_FP		0x1230
+
+/*
+ * DCU transmit pause control/status register
+ */
+#define AR5212_DCU_TXP		0x1270
+#define	AR5212_DCU_TXP_M		0x000003ff
+#define	AR5212_DCU_TXP_STATUS	0x00010000
+
+/*
+ * DCU transmit filter register
+ */
+#define AR5212_DCU_TX_FILTER	0x1038
+
+/*
+ * DCU clear transmit filter register
+ */
+#define AR5212_DCU_TX_FILTER_CLR	0x143c
+
+/*
+ * DCU set transmit filter register
+ */
+#define AR5212_DCU_TX_FILTER_SET	0x147c
+
+/*
+ * DMA size definitions
+ */
+typedef enum {
+	AR5212_DMASIZE_4B = 0,
+	AR5212_DMASIZE_8B,
+	AR5212_DMASIZE_16B,
+	AR5212_DMASIZE_32B,
+	AR5212_DMASIZE_64B,
+	AR5212_DMASIZE_128B,
+	AR5212_DMASIZE_256B,
+	AR5212_DMASIZE_512B
+} ar5212_dmasize_t;
+
+/*
+ * Reset control register
+ */
+#define AR5212_RC			0x4000
+#define AR5212_RC_PCU		0x00000001
+#define AR5212_RC_BB		0x00000002
+#define AR5212_RC_PCI		0x00000010
+#define AR5212_RC_CHIP		(				\
+	AR5212_RC_PCU | AR5212_RC_BB | AR5212_RC_PCI	\
+)
+
+/*
+ * Sleep control register
+ */
+#define AR5212_SCR			0x4004
+#define AR5212_SCR_SLDUR		0x0000ffff
+#define AR5212_SCR_SLE		0x00030000
+#define AR5212_SCR_SLE_S		16
+#define AR5212_SCR_SLE_WAKE	0x00000000
+#define AR5212_SCR_SLE_SLP		0x00010000
+#define AR5212_SCR_SLE_ALLOW	0x00020000
+#define AR5212_SCR_SLE_UNITS	0x00000008
+
+/*
+ * Interrupt pending register
+ */
+#define AR5212_INTPEND	0x4008
+#define AR5212_INTPEND_M	0x00000001
+
+/*
+ * Sleep force register
+ */
+#define AR5212_SFR		0x400c
+#define AR5212_SFR_M	0x00000001
+
+/*
+ * PCI configuration register
+ */
+#define AR5212_PCICFG		0x4010
+#define AR5212_PCICFG_CLKRUNEN	0x00000004
+#define AR5212_PCICFG_EESIZE	0x00000018
+#define AR5212_PCICFG_EESIZE_S	3
+#define AR5212_PCICFG_EESIZE_4K	0
+#define AR5212_PCICFG_EESIZE_8K	1
+#define AR5212_PCICFG_EESIZE_16K	2
+#define AR5212_PCICFG_EESIZE_FAIL	3
+#define AR5212_PCICFG_LED		0x00000060
+#define AR5212_PCICFG_LED_NONE	0x00000000
+#define AR5212_PCICFG_LED_PEND	0x00000020
+#define AR5212_PCICFG_LED_ASSOC	0x00000040
+#define	AR5212_PCICFG_BUS_SEL	0x00000380
+#define	AR5212_PCICFG_CBEFIX_DIS	0x00000400
+#define AR5212_PCICFG_SL_INTEN	0x00000800
+#define AR5212_PCICFG_SL_INPEN	0x00002800
+#define AR5212_PCICFG_SPWR_DN	0x00010000
+#define AR5212_PCICFG_LEDMODE	0x000e0000
+#define AR5212_PCICFG_LEDMODE_PROP	0x00000000
+#define AR5212_PCICFG_LEDMODE_PROM	0x00020000
+#define AR5212_PCICFG_LEDMODE_PWR	0x00040000
+#define AR5212_PCICFG_LEDMODE_RAND	0x00060000
+#define AR5212_PCICFG_LEDBLINK	0x00700000
+#define AR5212_PCICFG_LEDBLINK_S	20
+#define AR5212_PCICFG_LEDSLOW	0x00800000
+
+/*
+ * "General Purpose Input/Output" (GPIO) control register
+ */
+#define AR5212_GPIOCR		0x4014
+#define AR5212_GPIOCR_INT_ENA	0x00008000
+#define AR5212_GPIOCR_INT_SELL	0x00000000
+#define AR5212_GPIOCR_INT_SELH	0x00010000
+#define AR5212_GPIOCR_NONE(n)	(0 << ((n) * 2))
+#define AR5212_GPIOCR_OUT0(n)	(1 << ((n) * 2))
+#define AR5212_GPIOCR_OUT1(n)	(2 << ((n) * 2))
+#define AR5212_GPIOCR_ALL(n)	(3 << ((n) * 2))
+#define AR5212_GPIOCR_INT_SEL(n)	((n) << 12)
+
+#define AR5212_NUM_GPIO	6
+
+/*
+ * "General Purpose Input/Output" (GPIO) data output register
+ */
+#define AR5212_GPIODO	0x4018
+
+/*
+ * "General Purpose Input/Output" (GPIO) data input register
+ */
+#define AR5212_GPIODI	0x401c
+#define AR5212_GPIODI_M	0x0000002f
+
+/*
+ * Silicon revision register
+ */
+#define AR5212_SREV		0x4020
+#define AR5212_SREV_M		0x000000ff
+#define AR5212_SREV_REVISION	0x0000000f
+#define AR5212_SREV_VERSION	0x000000f0
+
+/*
+ * EEPROM access registers
+ */
+#define AR5212_EEPROM_BASE		0x6000
+#define AR5212_EEPROM_DATA		0x6004
+#define AR5212_EEPROM_CMD		0x6008
+#define AR5212_EEPROM_CMD_READ	0x00000001
+#define AR5212_EEPROM_CMD_WRITE	0x00000002
+#define AR5212_EEPROM_CMD_RESET	0x00000004
+#define AR5212_EEPROM_STATUS	0x600c
+#define AR5212_EEPROM_STAT_RDERR	0x00000001
+#define AR5212_EEPROM_STAT_RDDONE	0x00000002
+#define AR5212_EEPROM_STAT_WRERR	0x00000004
+#define AR5212_EEPROM_STAT_WRDONE	0x00000008
+#define AR5212_EEPROM_CFG		0x6010
+
+/*
+ * PCU registers
+ */
+
+#define AR5212_PCU_MIN	0x8000
+#define AR5212_PCU_MAX	0x8fff
+
+/*
+ * First station id register (MAC address in lower 32 bits)
+ */
+#define AR5212_STA_ID0	0x8000
+
+/*
+ * Second station id register (MAC address in upper 16 bits)
+ */
+#define AR5212_STA_ID1			0x8004
+#define AR5212_STA_ID1_AP			0x00010000
+#define AR5212_STA_ID1_ADHOC		0x00020000
+#define AR5212_STA_ID1_PWR_SV		0x00040000
+#define AR5212_STA_ID1_NO_KEYSRCH		0x00080000
+#define AR5212_STA_ID1_PCF			0x00100000
+#define AR5212_STA_ID1_DEFAULT_ANTENNA	0x00200000
+#define AR5212_STA_ID1_DESC_ANTENNA	0x00400000
+#define AR5212_STA_ID1_RTS_DEFAULT_ANTENNA	0x00800000
+#define AR5212_STA_ID1_ACKCTS_6MB		0x01000000
+#define AR5212_STA_ID1_BASE_RATE_11B	0x02000000
+
+/*
+ * First BSSID register (MAC address, lower 32bits)
+ */
+#define AR5212_BSS_ID0	0x8008
+
+/*
+ * Second BSSID register (MAC address in upper 16 bits)
+ *
+ * AID: Association ID
+ */
+#define AR5212_BSS_ID1		0x800c
+#define AR5212_BSS_ID1_AID		0xffff0000
+#define AR5212_BSS_ID1_AID_S	16
+
+/*
+ * Backoff slot time register
+ */
+#define AR5212_SLOT_TIME	0x8010
+
+/*
+ * ACK/CTS timeout register
+ */
+#define AR5212_TIME_OUT		0x8014
+#define AR5212_TIME_OUT_ACK	0x00001fff
+#define AR5212_TIME_OUT_ACK_S	0
+#define AR5212_TIME_OUT_CTS	0x1fff0000
+#define AR5212_TIME_OUT_CTS_S	16
+
+/*
+ * RSSI threshold register
+ */
+#define AR5212_RSSI_THR		0x8018
+#define AR5212_RSSI_THR_M		0x000000ff
+#define AR5212_RSSI_THR_BMISS	0x0000ff00
+#define AR5212_RSSI_THR_BMISS_S	8
+
+/*
+ * Transmit latency register
+ */
+#define AR5212_USEC		0x801c
+#define AR5212_USEC_1		0x0000007f
+#define AR5212_USEC_1_S		0
+#define AR5212_USEC_32		0x00003f80
+#define AR5212_USEC_32_S		7
+#define AR5212_USEC_TX_LATENCY	0x007fc000
+#define AR5212_USEC_TX_LATENCY_S	14
+#define AR5212_USEC_RX_LATENCY	0x1f800000
+#define AR5212_USEC_RX_LATENCY_S	23
+#define AR5311_USEC_TX_LATENCY	0x000fc000
+#define AR5311_USEC_TX_LATENCY_S	14
+#define AR5311_USEC_RX_LATENCY	0x03f00000
+#define AR5311_USEC_RX_LATENCY_S	20
+
+/*
+ * PCU beacon control register
+ */
+#define AR5212_BEACON		0x8020
+#define AR5212_BEACON_PERIOD	0x0000ffff
+#define AR5212_BEACON_PERIOD_S	0
+#define AR5212_BEACON_TIM		0x007f0000
+#define AR5212_BEACON_TIM_S	16
+#define AR5212_BEACON_ENABLE	0x00800000
+#define AR5212_BEACON_RESET_TSF	0x01000000
+
+/*
+ * CFP period register
+ */
+#define AR5212_CFP_PERIOD		0x8024
+
+/*
+ * Next beacon time register
+ */
+#define AR5212_TIMER0		0x8028
+
+/*
+ * Next DMA beacon alert register
+ */
+#define AR5212_TIMER1		0x802c
+
+/*
+ * Next software beacon alert register
+ */
+#define AR5212_TIMER2		0x8030
+
+/*
+ * Next ATIM window time register
+ */
+#define AR5212_TIMER3		0x8034
+
+/*
+ * CFP duration register
+ */
+#define AR5212_CFP_DUR		0x8038
+
+/*
+ * Receive filter register
+ */
+#define AR5212_RX_FILTER		0x803c
+#define AR5212_RX_FILTER_UNICAST	0x00000001
+#define AR5212_RX_FILTER_MULTICAST	0x00000002
+#define AR5212_RX_FILTER_BROADCAST	0x00000004
+#define AR5212_RX_FILTER_CONTROL	0x00000008
+#define AR5212_RX_FILTER_BEACON	0x00000010
+#define AR5212_RX_FILTER_PROMISC	0x00000020
+#define AR5212_RX_FILTER_XR_POLL	0x00000040
+#define AR5212_RX_FILTER_PROBE_REQ	0x00000080
+
+/*
+ * Multicast filter register (lower 32 bits)
+ */
+#define AR5212_MCAST_FIL0	0x8040
+
+/*
+ * Multicast filter register (higher 16 bits)
+ */
+#define AR5212_MCAST_FIL1	0x8044
+
+/*
+ * PCU control register
+ */
+#define AR5212_DIAG_SW			0x8048
+#define AR5212_DIAG_SW_DIS_WEP_ACK		0x00000001
+#define AR5212_DIAG_SW_DIS_ACK		0x00000002
+#define AR5212_DIAG_SW_DIS_CTS		0x00000004
+#define AR5212_DIAG_SW_DIS_ENC		0x00000008
+#define AR5212_DIAG_SW_DIS_DEC		0x00000010
+#define AR5212_DIAG_SW_DIS_RX		0x00000020
+#define AR5212_DIAG_SW_LOOP_BACK		0x00000040
+#define AR5212_DIAG_SW_CORR_FCS		0x00000080
+#define AR5212_DIAG_SW_CHAN_INFO		0x00000100
+#define AR5212_DIAG_SW_EN_SCRAM_SEED	0x00000200
+#define AR5212_DIAG_SW_ECO_ENABLE		0x00000400
+#define AR5212_DIAG_SW_SCRAM_SEED_M	0x0001fc00
+#define AR5212_DIAG_SW_SCRAM_SEED_S	10
+#define AR5212_DIAG_SW_FRAME_NV0		0x00020000
+#define AR5212_DIAG_SW_OBSPT_M		0x000c0000
+#define AR5212_DIAG_SW_OBSPT_S		18
+
+/*
+ * TSF (clock) register (lower 32 bits)
+ */
+#define AR5212_TSF_L32	0x804c
+
+/*
+ * TSF (clock) register (higher 32 bits)
+ */
+#define AR5212_TSF_U32	0x8050
+
+/*
+ * ADDAC test register
+ */
+#define AR5212_ADDAC_TEST	0x8054
+
+/*
+ * Default antenna register
+ */
+#define AR5212_DEFAULT_ANTENNA	0x8058
+
+/*
+ * Last beacon timestamp register
+ */
+#define AR5212_LAST_TSTP	0x8080
+
+/*
+ * NAV register (current)
+ */
+#define AR5212_NAV		0x8084
+
+/*
+ * RTS success register
+ */
+#define AR5212_RTS_OK	0x8088
+
+/*
+ * RTS failure register
+ */
+#define AR5212_RTS_FAIL	0x808c
+
+/*
+ * ACK failure register
+ */
+#define AR5212_ACK_FAIL	0x8090
+
+/*
+ * FCS failure register
+ */
+#define AR5212_FCS_FAIL	0x8094
+
+/*
+ * Beacon count register
+ */
+#define AR5212_BEACON_CNT	0x8098
+
+/*
+ * XR (eXtended Range) mode register
+ */
+#define AR5212_XRMODE			0x80c0
+#define	AR5212_XRMODE_POLL_TYPE_M		0x0000003f
+#define	AR5212_XRMODE_POLL_TYPE_S		0
+#define	AR5212_XRMODE_POLL_SUBTYPE_M	0x0000003c
+#define	AR5212_XRMODE_POLL_SUBTYPE_S	2
+#define	AR5212_XRMODE_POLL_WAIT_ALL	0x00000080
+#define	AR5212_XRMODE_SIFS_DELAY		0x000fff00
+#define	AR5212_XRMODE_FRAME_HOLD_M		0xfff00000
+#define	AR5212_XRMODE_FRAME_HOLD_S		20
+
+/*
+ * XR delay register
+ */
+#define AR5212_XRDELAY			0x80c4
+#define AR5212_XRDELAY_SLOT_DELAY_M	0x0000ffff
+#define AR5212_XRDELAY_SLOT_DELAY_S	0
+#define AR5212_XRDELAY_CHIRP_DELAY_M	0xffff0000
+#define AR5212_XRDELAY_CHIRP_DELAY_S	16
+
+/*
+ * XR timeout register
+ */
+#define AR5212_XRTIMEOUT		0x80c8
+#define AR5212_XRTIMEOUT_CHIRP_M	0x0000ffff
+#define AR5212_XRTIMEOUT_CHIRP_S	0
+#define AR5212_XRTIMEOUT_POLL_M	0xffff0000
+#define AR5212_XRTIMEOUT_POLL_S	16
+
+/*
+ * XR chirp register
+ */
+#define AR5212_XRCHIRP		0x80cc
+#define AR5212_XRCHIRP_SEND	0x00000001
+#define AR5212_XRCHIRP_GAP		0xffff0000
+
+/*
+ * XR stomp register
+ */
+#define AR5212_XRSTOMP		0x80d0
+#define AR5212_XRSTOMP_TX		0x00000001
+#define AR5212_XRSTOMP_RX_ABORT	0x00000002
+#define AR5212_XRSTOMP_RSSI_THRES	0x0000ff00
+
+/*
+ * First enhanced sleep register
+ */
+#define AR5212_SLEEP0		0x80d4
+#define AR5212_SLEEP0_NEXT_DTIM_M	0x0007ffff
+#define AR5212_SLEEP0_NEXT_DTIM_S	0
+#define AR5212_SLEEP0_ASSUME_DTIM	0x00080000
+#define AR5212_SLEEP0_ENH_SLEEP_EN	0x00100000
+#define AR5212_SLEEP0_CAPTO_M	0xff000000
+#define AR5212_SLEEP0_CAPTO_S	24
+
+/*
+ * Second enhanced sleep register
+ */
+#define AR5212_SLEEP1		0x80d8
+#define AR5212_SLEEP1_NEXT_TIM_M	0x0007ffff
+#define AR5212_SLEEP1_NEXT_TIM_S	0
+#define AR5212_SLEEP1_BEACON_TO_M	0xff000000
+#define AR5212_SLEEP1_BEACON_TO_S	24
+
+/*
+ * Third enhanced sleep register
+ */
+#define AR5212_SLEEP2		0x80dc
+#define AR5212_SLEEP2_TIM_PER_M	0x0000ffff
+#define AR5212_SLEEP2_TIM_PER_S	0
+#define AR5212_SLEEP2_DTIM_PER_M	0xffff0000
+#define AR5212_SLEEP2_DTIM_PER_S	16
+
+/*
+ * BSSID mask registers
+ */
+#define AR5212_BSS_IDM0	0x80e0
+#define AR5212_BSS_IDM1	0x80e4
+
+/*
+ * TX power control (TPC) register
+ */
+#define AR5212_TXPC		0x80e8
+#define AR5212_TXPC_ACK_M		0x0000003f
+#define AR5212_TXPC_ACK_S		0
+#define AR5212_TXPC_CTS_M		0x00003f00
+#define AR5212_TXPC_CTS_S		8
+#define AR5212_TXPC_CHIRP_M	0x003f0000
+#define AR5212_TXPC_CHIRP_S	22
+
+/*
+ * Profile count registers
+ */
+#define AR5212_PROFCNT_TX		0x80ec
+#define AR5212_PROFCNT_RX		0x80f0
+#define AR5212_PROFCNT_RXCLR	0x80f4
+#define AR5212_PROFCNT_CYCLE	0x80f8
+
+/*
+ * TSF parameter register
+ */
+#define AR5212_TSF_PARM		0x8104
+#define AR5212_TSF_PARM_INC_M	0x000000ff
+#define AR5212_TSF_PARM_INC_S	0
+
+/*
+ * PHY error filter register
+ */
+#define AR5212_PHY_ERR_FIL		0x810c
+#define AR5212_PHY_ERR_FIL_RADAR	0x00000020
+#define AR5212_PHY_ERR_FIL_OFDM	0x00020000
+#define AR5212_PHY_ERR_FIL_CCK	0x02000000
+
+/*
+ * Rate duration register
+ */
+#define AR5212_RATE_DUR_0		0x8700
+#define AR5212_RATE_DUR(_n)	(AR5212_RATE_DUR_0 + ((_n) << 2))
+
+/*
+ * Key table (WEP) register
+ */
+#define AR5212_KEYTABLE_0		0x8800
+#define AR5212_KEYTABLE(n)		(AR5212_KEYTABLE_0 + ((n) * 32))
+#define AR5212_KEYTABLE_TYPE_40	0x00000000
+#define AR5212_KEYTABLE_TYPE_104	0x00000001
+#define AR5212_KEYTABLE_TYPE_128	0x00000003
+#define AR5212_KEYTABLE_TYPE_TKIP	0x00000004
+#define AR5212_KEYTABLE_TYPE_AES	0x00000005
+#define AR5212_KEYTABLE_TYPE_CCM	0x00000006
+#define AR5212_KEYTABLE_TYPE_NULL	0x00000007
+#define AR5212_KEYTABLE_ANTENNA	0x00000008
+#define AR5212_KEYTABLE_VALID	0x00008000
+
+#define AR5212_KEYTABLE_SIZE	64
+#define AR5212_KEYCACHE_SIZE	8
+
+/*
+ * PHY register
+ */
+#define	AR5212_PHY(_n)		(0x9800 + ((_n) << 2))
+#define AR5212_PHY_SHIFT_2GHZ	0x00004007
+#define AR5212_PHY_SHIFT_5GHZ	0x00000007
+
+/*
+ * PHY turbo mode register
+ */
+#define	AR5212_PHY_TURBO		0x9804
+#define	AR5212_PHY_TURBO_MODE	0x00000001
+#define	AR5212_PHY_TURBO_SHORT	0x00000002
+
+/*
+ * PHY agility command register
+ */
+#define	AR5212_PHY_AGC		0x9808
+#define	AR5212_PHY_AGC_DISABLE	0x08000000
+
+/*
+ * PHY timing register
+ */
+#define	AR5212_PHY_TIMING_3		0x9814
+#define	AR5212_PHY_TIMING_3_DSC_MAN	0xfffe0000
+#define	AR5212_PHY_TIMING_3_DSC_MAN_S	17
+#define	AR5212_PHY_TIMING_3_DSC_EXP	0x0001e000
+#define	AR5212_PHY_TIMING_3_DSC_EXP_S	13
+
+/*
+ * PHY chip revision register
+ */
+#define	AR5212_PHY_CHIP_ID		0x9818
+
+/*
+ * PHY activation register
+ */
+#define	AR5212_PHY_ACTIVE		0x981c
+#define	AR5212_PHY_ENABLE		0x00000001
+#define	AR5212_PHY_DISABLE		0x00000002
+
+/*
+ * PHY agility control register
+ */
+#define	AR5212_PHY_AGCCTL		0x9860
+#define	AR5212_PHY_AGCCTL_CAL	0x00000001
+#define	AR5212_PHY_AGCCTL_NF	0x00000002
+
+/*
+ * PHY noise floor status register
+ */
+#define AR5212_PHY_NF		0x9864
+#define AR5212_PHY_NF_M		0x000001ff
+#define AR5212_PHY_NF_ACTIVE	0x00000100
+#define AR5212_PHY_NF_RVAL(_n)	(((_n) >> 19) & AR5212_PHY_NF_M)
+#define AR5212_PHY_NF_AVAL(_n)	(-((_n) ^ AR5212_PHY_NF_M) + 1)
+#define AR5212_PHY_NF_SVAL(_n)	(((_n) & AR5212_PHY_NF_M) | (1 << 9))
+
+/*
+ * PHY sleep registers
+ */
+#define AR5212_PHY_SCR		0x9870
+#define AR5212_PHY_SCR_32MHZ	0x0000001f
+#define AR5212_PHY_SLMT		0x9874
+#define AR5212_PHY_SLMT_32MHZ	0x0000007f
+#define AR5212_PHY_SCAL		0x9878
+#define AR5212_PHY_SCAL_32MHZ	0x0000000e
+
+/*
+ * PHY PLL control register
+ */
+#define	AR5212_PHY_PLL		0x987c
+#define	AR5212_PHY_PLL_40MHZ	0x000000aa
+#define	AR5212_PHY_PLL_44MHZ	0x000000ab
+#define AR5212_PHY_PLL_AR5111	0x00000000
+#define AR5212_PHY_PLL_AR5112	0x00000040
+
+/*
+ * PHY receiver delay register
+ */
+#define	AR5212_PHY_RX_DELAY	0x9914
+#define	AR5212_PHY_RX_DELAY_M	0x00003fff
+
+/*
+ * PHY timing IQ control register
+ */
+#define	AR5212_PHY_IQ			0x9920
+#define	AR5212_PHY_IQ_CORR_Q_Q_COFF	0x0000001f
+#define	AR5212_PHY_IQ_CORR_Q_I_COFF	0x000007e0
+#define	AR5212_PHY_IQ_CORR_Q_I_COFF_S	5
+#define	AR5212_PHY_IQ_CORR_ENABLE		0x00000800
+#define	AR5212_PHY_IQ_CAL_NUM_LOG_MAX	0x0000f000
+#define	AR5212_PHY_IQ_CAL_NUM_LOG_MAX_S	12
+#define	AR5212_PHY_IQ_RUN			0x00010000
+
+/*
+ * PHY PAPD probe register
+ */
+#define	AR5212_PHY_PAPD_PROBE		0x9930
+#define	AR5212_PHY_PAPD_PROBE_TXPOWER	0x00007e00
+#define	AR5212_PHY_PAPD_PROBE_TXPOWER_S	9
+#define	AR5212_PHY_PAPD_PROBE_TX_NEXT	0x00008000
+#define	AR5212_PHY_PAPD_PROBE_GAINF	0xfe000000
+#define	AR5212_PHY_PAPD_PROBE_GAINF_S	25
+
+/*
+ * PHY TX power registers
+ */
+#define	AR5212_PHY_TXPOWER_RATE1			0x9934
+#define	AR5212_PHY_TXPOWER_RATE2			0x9938
+#define	AR5212_PHY_TXPOWER_RATE_MAX		0x993c
+#define	AR5212_PHY_TXPOWER_RATE_MAX_TPC_ENABLE	0x00000040
+#define	AR5212_PHY_TXPOWER_RATE3			0xa234
+#define	AR5212_PHY_TXPOWER_RATE4			0xa238
+
+/*
+ * PHY frame control register
+ */
+#define	AR5212_PHY_FC		0x9944
+#define	AR5212_PHY_FC_TX_CLIP	0x00000038
+#define	AR5212_PHY_FC_TX_CLIP_S	3
+
+/*
+ * PHY radar detection enable register
+ */
+#define	AR5212_PHY_RADAR		0x9954
+#define	AR5212_PHY_RADAR_DISABLE	0x00000000
+#define	AR5212_PHY_RADAR_ENABLE	0x00000001
+
+/*
+ * PHY antenna switch table registers
+ */
+#define AR5212_PHY_ANT_SWITCH_TABLE_0	0x9960
+#define AR5212_PHY_ANT_SWITCH_TABLE_1	0x9964
+
+/*
+ * PHY clock sleep registers
+ */
+#define AR5212_PHY_SCLOCK		0x99f0
+#define AR5212_PHY_SCLOCK_32MHZ	0x0000000c
+#define AR5212_PHY_SDELAY		0x99f4
+#define AR5212_PHY_SDELAY_32MHZ	0x000000ff
+#define AR5212_PHY_SPENDING	0x99f8
+#define AR5212_PHY_SPENDING_AR5111	0x00000018
+#define AR5212_PHY_SPENDING_AR5112	0x00000014
+
+/*
+ * PHY timing IQ calibration result register
+ */
+#define	AR5212_PHY_IQRES_CAL_PWR_I	0x9c10
+#define	AR5212_PHY_IQRES_CAL_PWR_Q	0x9c14
+#define	AR5212_PHY_IQRES_CAL_CORR	0x9c18
+
+/*
+ * PHY current RSSI register
+ */
+#define	AR5212_PHY_CURRENT_RSSI	0x9c1c
+
+/*
+ * PHY PCDAC TX power register
+ */
+#define	AR5212_PHY_PCDAC_TXPOWER(_n)	(0xa180 + ((_n) << 2))
+
+/*
+ * PHY mode register
+ */
+#define	AR5212_PHY_MODE		0x0a200
+#define	AR5212_PHY_MODE_MOD	0x00000001
+#define AR5212_PHY_MODE_MOD_OFDM	0
+#define AR5212_PHY_MODE_MOD_CCK	1
+#define AR5212_PHY_MODE_FREQ	0x00000002
+#define	AR5212_PHY_MODE_FREQ_5GHZ	0
+#define	AR5212_PHY_MODE_FREQ_2GHZ	2
+#define AR5212_PHY_MODE_MOD_DYN	0x00000004
+#define AR5212_PHY_MODE_RAD	0x00000008
+#define AR5212_PHY_MODE_RAD_AR5111	0
+#define AR5212_PHY_MODE_RAD_AR5112	8
+#define AR5212_PHY_MODE_XR		0x00000010
+
+/*
+ * PHY 2GHz gain register
+ */
+#define	AR5212_PHY_GAIN_2GHZ		0xa20c
+#define	AR5212_PHY_GAIN_2GHZ_MARGIN_TXRX	0x00fc0000
+#define	AR5212_PHY_GAIN_2GHZ_MARGIN_TXRX_S	18
+
+#endif
+
+/*
+ * Common ar5xxx EEPROM data registers
+ */
+
+#define EEPROM_MAGIC            0x003d
+#define EEPROM_MAGIC_VALUE              0x5aa5
+#define EEPROM_PROTECT          0x003f
+#define EEPROM_PROTECT_RD_0_31  0x0001
+#define EEPROM_PROTECT_WR_0_31  0x0002
+#define EEPROM_PROTECT_RD_32_63 0x0004
+#define EEPROM_PROTECT_WR_32_63 0x0008
+#define EEPROM_PROTECT_RD_64_127        0x0010
+#define EEPROM_PROTECT_WR_64_127        0x0020
+#define EEPROM_PROTECT_RD_128_191       0x0040
+#define EEPROM_PROTECT_WR_128_191       0x0080
+#define EEPROM_PROTECT_RD_192_207       0x0100
+#define EEPROM_PROTECT_WR_192_207       0x0200
+#define EEPROM_PROTECT_RD_208_223       0x0400
+#define EEPROM_PROTECT_WR_208_223       0x0800
+#define EEPROM_PROTECT_RD_224_239       0x1000
+#define EEPROM_PROTECT_WR_224_239       0x2000
+#define EEPROM_PROTECT_RD_240_255       0x4000
+#define EEPROM_PROTECT_WR_240_255       0x8000
+#define EEPROM_REG_DOMAIN               0x00bf
+#define EEPROM_INFO_BASE                0x00c0
+#define EEPROM_INFO_MAX                                         \
+	        (0x400 - EEPROM_INFO_BASE)
+#define EEPROM_INFO(_n)         (EEPROM_INFO_BASE + (_n))
+
+#define EEPROM_VERSION          EEPROM_INFO(1)
+#define EEPROM_VERSION_3_0              0x3000
+#define EEPROM_VERSION_3_1              0x3001
+#define EEPROM_VERSION_3_2              0x3002
+#define EEPROM_VERSION_3_3              0x3003
+#define EEPROM_VERSION_3_4              0x3004
+#define EEPROM_VERSION_4_0              0x4000
+#define EEPROM_VERSION_4_1              0x4001
+#define EEPROM_VERSION_4_2              0x4002
+#define EEPROM_VERSION_4_3              0x4003
+#define EEPROM_VERSION_4_6              0x4006
+#define EEPROM_VERSION_4_7              0x3007
+
+#define EEPROM_MODE_11A 0
+#define EEPROM_MODE_11B 1
+#define EEPROM_MODE_11G 2
+
+#define EEPROM_HDR                      EEPROM_INFO(2)
+#define EEPROM_HDR_11A(_v)              (((_v) >> EEPROM_MODE_11A) & 0x1)
+#define EEPROM_HDR_11B(_v)              (((_v) >> EEPROM_MODE_11B) & 0x1)
+#define EEPROM_HDR_11G(_v)              (((_v) >> EEPROM_MODE_11G) & 0x1)
+#define EEPROM_HDR_T_2GHZ_DIS(_v)       (((_v) >> 3) & 0x1)
+#define EEPROM_HDR_T_5GHZ_DBM(_v)       (((_v) >> 4) & 0x7f)
+#define EEPROM_HDR_DEVICE(_v)   (((_v) >> 11) & 0x7)
+#define EEPROM_HDR_T_5GHZ_DIS(_v)       (((_v) >> 15) & 0x1)
+#define EEPROM_HDR_RFKILL(_v)   (((_v) >> 14) & 0x1)
+
+#define EEPROM_RFKILL_GPIO_SEL  0x0000001c
+#define EEPROM_RFKILL_GPIO_SEL_S        2
+#define EEPROM_RFKILL_POLARITY  0x00000002
+#define EEPROM_RFKILL_POLARITY_S        1
+
+/* Newer EEPROMs are using a different offset */
+#define EEPROM_OFF(_v, _v3_0, _v3_3)                                    \
+	        (((_v) >= EEPROM_VERSION_3_3) ? _v3_3 : _v3_0)
+
+#define EEPROM_ANT_GAIN(_v)     EEPROM_OFF(_v, 0x00c4, 0x00c3)
+#define EEPROM_ANT_GAIN_5GHZ(_v)        ((int8_t)(((_v) >> 8) & 0xff))
+#define EEPROM_ANT_GAIN_2GHZ(_v)        ((int8_t)((_v) & 0xff))
+
+#define EEPROM_MODES_11A(_v)    EEPROM_OFF(_v, 0x00c5, 0x00d4)
+#define EEPROM_MODES_11B(_v)    EEPROM_OFF(_v, 0x00d0, 0x00f2)
+#define EEPROM_MODES_11G(_v)    EEPROM_OFF(_v, 0x00da, 0x010d)
+#define EEPROM_CTL(_v)          EEPROM_OFF(_v, 0x00e4, 0x0128)
+
+/* Since 3.1 */
+#define EEPROM_OBDB0_2GHZ       0x00ec
+#define EEPROM_OBDB1_2GHZ       0x00ed
+
+/* Misc values available since EEPROM 4.0 */
+#define EEPROM_MISC0            0x00c4
+#define EEPROM_EARSTART(_v)     ((_v) & 0xfff)
+#define EEPROM_EEMAP(_v)                (((_v) >> 14) & 0x3)
+#define EEPROM_MISC1            0x00c5
+#define EEPROM_TARGET_PWRSTART(_v)      ((_v) & 0xfff)
+#define EEPROM_HAS32KHZCRYSTAL(_v)      (((_v) >> 14) & 0x1)
+
+/* Some EEPROM defines */
+#define EEPROM_EEP_SCALE                100
+#define EEPROM_EEP_DELTA                10
+#define EEPROM_MODES            3
+#define EEPROM_5GHZ_CHAN                10
+#define EEPROM_2GHZ_CHAN                3
+#define EEPROM_MAX_CHAN         10
+#define EEPROM_PCDAC            11
+#define EEPROM_TEST_FREQ                8
+#define EEPROM_EDGES            8
+#define EEPROM_INTERCEPTS       11
+#define EEPROM_FREQ_M(_v)               EEPROM_OFF(_v, 0x7f, 0xff)
+#define EEPROM_PCDAC_M          0x3f
+#define EEPROM_PCDAC_START              1
+#define EEPROM_PCDAC_STOP               63
+#define EEPROM_PCDAC_STEP               1
+#define EEPROM_NON_EDGE_M               0x40
+#define EEPROM_CHANNEL_POWER    8
+#define EEPROM_OBDB             4
+#define EEPROM_OBDB_DIS         0xffff
+#define EEPROM_CHANNEL_DIS              0xff
+#define EEPROM_SCALE_OC_DELTA(_x)       (((_x) * 2) / 10)
+#define EEPROM_CTLS(_v)         _EEPROM_OFF(_v, 16, 32)
+#define EEPROM_MAX_CTLS         32
+#define EEPROM_XPD_PER_CHANNEL  4
+#define EEPROM_XPD0_POINTS      4
+#define EEPROM_XPD3_POINTS      3
+#define EEPROM_INTERCEPT_10_2GHZ        35
+#define EEPROM_INTERCEPT_10_5GHZ        55
+#define EEPROM_POWER_M          0x3f
+#define EEPROM_POWER_MIN                0
+#define EEPROM_POWER_MAX                3150
+#define EEPROM_POWER_STEP               50
+#define EEPROM_POWER_TABLE_SIZE 64
+#define EEPROM_POWER_LOC_11B    4
+#define EEPROM_POWER_LOC_11G    6
+#define EEPROM_I_GAIN           10
+#define EEPROM_CCK_OFDM_DELTA   15
+#define EEPROM_IQ_CAL           2
+
+
+#define TXDESC_VEOL	0x20


--------------020203090400020609060706
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------020203090400020609060706--
