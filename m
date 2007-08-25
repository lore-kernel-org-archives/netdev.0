From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] Net: ath5k, comment some EEPROM registers
Date: Sat, 25 Aug 2007 03:57:26 -0400
Message-ID: <149438602455517207@pripojeni.net>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ath5k, comment some EEPROM registers

make some registers meaning clear

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

---
commit 06615d9cdf1ae777821dfcd7845c72c38ff14ffa
tree d0c4b9ded4aa541e003b6855e9bde072e01b631d
parent 069bfbe93facb3468f579568434d18f1268a487c
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:18:19 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Sat, 25 Aug 2007 09:18:19 +0200

 drivers/net/wireless/ath5k_hw.c  |    4 +
 drivers/net/wireless/ath5k_reg.h |  114 +++++++++++++++++++++-----------------
 2 files changed, 65 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/ath5k_hw.c b/drivers/net/wireless/ath5k_hw.c
index f273c42..4375129 100644
--- a/drivers/net/wireless/ath5k_hw.c
+++ b/drivers/net/wireless/ath5k_hw.c
@@ -344,7 +344,7 @@ struct ath_hw *ath5k_hw_attach(u16 device, u8 mac_version, void *sc,
 	/*
 	 * Set the mac revision based on the pci id
 	 */
-	hal->ah_version	= mac_version;
+	hal->ah_version = mac_version;
 
 	/*Fill the hal struct with the needed functions*/
 	if (hal->ah_version == AR5K_AR5212)
@@ -4636,6 +4636,8 @@ static int ath5k_hw_channel(struct ath_hw *hal,
 
 /*
  * Perform a PHY calibration on RF5110
+ * -Fix BPSK/QAM Constellation (I/Q correction)
+ * -Calculate Noise Floor
  */
 static int ath5k_hw_rf5110_calibrate(struct ath_hw *hal,
 		struct ieee80211_channel *channel)
diff --git a/drivers/net/wireless/ath5k_reg.h b/drivers/net/wireless/ath5k_reg.h
index 59547d1..c6142d2 100644
--- a/drivers/net/wireless/ath5k_reg.h
+++ b/drivers/net/wireless/ath5k_reg.h
@@ -920,63 +920,65 @@
 #define AR5K_EEPROM_BASE	0x6000
 
 /*
- * Common ar5xxx EEPROM data offset (set these on AR5K_EEPROM_BASE)
+ * Common ar5xxx EEPROM data offsets (set these on AR5K_EEPROM_BASE)
  */
-#define AR5K_EEPROM_MAGIC		0x003d
-#define AR5K_EEPROM_MAGIC_VALUE		0x5aa5
+#define AR5K_EEPROM_MAGIC		0x003d	/* EEPROM Magic number */
+#define AR5K_EEPROM_MAGIC_VALUE		0x5aa5	/* Default - found on EEPROM */
 #define AR5K_EEPROM_MAGIC_5212		0x0000145c /* 5212 */
 #define AR5K_EEPROM_MAGIC_5211		0x0000145b /* 5211 */
 #define AR5K_EEPROM_MAGIC_5210		0x0000145a /* 5210 */
 
-#define AR5K_EEPROM_PROTECT		0x003f
-#define AR5K_EEPROM_PROTECT_RD_0_31	0x0001
-#define AR5K_EEPROM_PROTECT_WR_0_31	0x0002
-#define AR5K_EEPROM_PROTECT_RD_32_63	0x0004
+#define AR5K_EEPROM_PROTECT		0x003f	/* EEPROM protect status */
+#define AR5K_EEPROM_PROTECT_RD_0_31	0x0001	/* Read protection bit for offsets 0x0 - 0x1f */
+#define AR5K_EEPROM_PROTECT_WR_0_31	0x0002	/* Write protection bit for offsets 0x0 - 0x1f */
+#define AR5K_EEPROM_PROTECT_RD_32_63	0x0004	/* 0x20 - 0x3f */
 #define AR5K_EEPROM_PROTECT_WR_32_63	0x0008
-#define AR5K_EEPROM_PROTECT_RD_64_127	0x0010
+#define AR5K_EEPROM_PROTECT_RD_64_127	0x0010	/* 0x40 - 0x7f */
 #define AR5K_EEPROM_PROTECT_WR_64_127	0x0020
-#define AR5K_EEPROM_PROTECT_RD_128_191	0x0040
+#define AR5K_EEPROM_PROTECT_RD_128_191	0x0040	/* 0x80 - 0xbf (regdom) */
 #define AR5K_EEPROM_PROTECT_WR_128_191	0x0080
-#define AR5K_EEPROM_PROTECT_RD_192_207	0x0100
+#define AR5K_EEPROM_PROTECT_RD_192_207	0x0100	/* 0xc0 - 0xcf */
 #define AR5K_EEPROM_PROTECT_WR_192_207	0x0200
-#define AR5K_EEPROM_PROTECT_RD_208_223	0x0400
+#define AR5K_EEPROM_PROTECT_RD_208_223	0x0400	/* 0xd0 - 0xdf */
 #define AR5K_EEPROM_PROTECT_WR_208_223	0x0800
-#define AR5K_EEPROM_PROTECT_RD_224_239	0x1000
+#define AR5K_EEPROM_PROTECT_RD_224_239	0x1000	/* 0xe0 - 0xef */
 #define AR5K_EEPROM_PROTECT_WR_224_239	0x2000
-#define AR5K_EEPROM_PROTECT_RD_240_255	0x4000
+#define AR5K_EEPROM_PROTECT_RD_240_255	0x4000	/* 0xf0 - 0xff */
 #define AR5K_EEPROM_PROTECT_WR_240_255	0x8000
-#define AR5K_EEPROM_REG_DOMAIN		0x00bf
-#define AR5K_EEPROM_INFO_BASE		0x00c0
+#define AR5K_EEPROM_REG_DOMAIN		0x00bf	/* EEPROM regdom */
+#define AR5K_EEPROM_INFO_BASE		0x00c0	/* EEPROM header */
 #define AR5K_EEPROM_INFO_MAX		(0x400 - AR5K_EEPROM_INFO_BASE)
 #define AR5K_EEPROM_INFO_CKSUM		0xffff
 #define AR5K_EEPROM_INFO(_n)		(AR5K_EEPROM_INFO_BASE + (_n))
 
-#define AR5K_EEPROM_VERSION		AR5K_EEPROM_INFO(1)
-#define AR5K_EEPROM_VERSION_3_0		0x3000
-#define AR5K_EEPROM_VERSION_3_1		0x3001
-#define AR5K_EEPROM_VERSION_3_2		0x3002
-#define AR5K_EEPROM_VERSION_3_3		0x3003
-#define AR5K_EEPROM_VERSION_3_4		0x3004
-#define AR5K_EEPROM_VERSION_4_0		0x4000
-#define AR5K_EEPROM_VERSION_4_1		0x4001
-#define AR5K_EEPROM_VERSION_4_2		0x4002
+#define AR5K_EEPROM_VERSION		AR5K_EEPROM_INFO(1)	/* EEPROM Version */
+#define AR5K_EEPROM_VERSION_3_0		0x3000	/* No idea what's going on before this version */
+#define AR5K_EEPROM_VERSION_3_1		0x3001	/* ob/db values for 2Ghz (ar5211_rfregs) */
+#define AR5K_EEPROM_VERSION_3_2		0x3002	/* different frequency representation (eeprom_bin2freq) */
+#define AR5K_EEPROM_VERSION_3_3		0x3003	/* offsets changed, has 32 CTLs (see below) and ee_false_detect (eeprom_read_modes) */
+#define AR5K_EEPROM_VERSION_3_4		0x3004	/* has ee_i_gain ee_cck_ofdm_power_delta (eeprom_read_modes) */
+#define AR5K_EEPROM_VERSION_4_0		0x4000	/* has ee_misc*, ee_cal_pier, ee_turbo_max_power and ee_xr_power (eeprom_init) */
+#define AR5K_EEPROM_VERSION_4_1		0x4001	/* has ee_margin_tx_rx (eeprom_init) */
+#define AR5K_EEPROM_VERSION_4_2		0x4002	/* has ee_cck_ofdm_gain_delta (eeprom_init) */
 #define AR5K_EEPROM_VERSION_4_3		0x4003
-#define AR5K_EEPROM_VERSION_4_6		0x4006
+#define AR5K_EEPROM_VERSION_4_4		0x4004
+#define AR5K_EEPROM_VERSION_4_5		0x4005
+#define AR5K_EEPROM_VERSION_4_6		0x4006	/* has ee_scaled_cck_delta */
 #define AR5K_EEPROM_VERSION_4_7		0x3007
 
 #define AR5K_EEPROM_MODE_11A		0
 #define AR5K_EEPROM_MODE_11B		1
 #define AR5K_EEPROM_MODE_11G		2
 
-#define AR5K_EEPROM_HDR			AR5K_EEPROM_INFO(2)
+#define AR5K_EEPROM_HDR			AR5K_EEPROM_INFO(2)	/* Header that contains the device caps */
 #define AR5K_EEPROM_HDR_11A(_v)		(((_v) >> AR5K_EEPROM_MODE_11A) & 0x1)
 #define AR5K_EEPROM_HDR_11B(_v)		(((_v) >> AR5K_EEPROM_MODE_11B) & 0x1)
 #define AR5K_EEPROM_HDR_11G(_v)		(((_v) >> AR5K_EEPROM_MODE_11G) & 0x1)
-#define AR5K_EEPROM_HDR_T_2GHZ_DIS(_v)	(((_v) >> 3) & 0x1)
-#define AR5K_EEPROM_HDR_T_5GHZ_DBM(_v)	(((_v) >> 4) & 0x7f)
+#define AR5K_EEPROM_HDR_T_2GHZ_DIS(_v)	(((_v) >> 3) & 0x1)	/* Disable turbo for 2Ghz (?) */
+#define AR5K_EEPROM_HDR_T_5GHZ_DBM(_v)	(((_v) >> 4) & 0x7f)	/* Max turbo power for a/XR mode (eeprom_init) */
 #define AR5K_EEPROM_HDR_DEVICE(_v)	(((_v) >> 11) & 0x7)
-#define AR5K_EEPROM_HDR_T_5GHZ_DIS(_v)	(((_v) >> 15) & 0x1)
-#define AR5K_EEPROM_HDR_RFKILL(_v)	(((_v) >> 14) & 0x1)
+#define AR5K_EEPROM_HDR_T_5GHZ_DIS(_v)	(((_v) >> 15) & 0x1)	/* Disable turbo for 5Ghz (?) */
+#define AR5K_EEPROM_HDR_RFKILL(_v)	(((_v) >> 14) & 0x1)	/* Device has RFKill support */
 
 #define AR5K_EEPROM_RFKILL_GPIO_SEL	0x0000001c
 #define AR5K_EEPROM_RFKILL_GPIO_SEL_S	2
@@ -991,12 +993,13 @@
 #define AR5K_EEPROM_ANT_GAIN_5GHZ(_v)	((int8_t)(((_v) >> 8) & 0xff))
 #define AR5K_EEPROM_ANT_GAIN_2GHZ(_v)	((int8_t)((_v) & 0xff))
 
+/* calibration settings */
 #define AR5K_EEPROM_MODES_11A(_v)	AR5K_EEPROM_OFF(_v, 0x00c5, 0x00d4)
 #define AR5K_EEPROM_MODES_11B(_v)	AR5K_EEPROM_OFF(_v, 0x00d0, 0x00f2)
 #define AR5K_EEPROM_MODES_11G(_v)	AR5K_EEPROM_OFF(_v, 0x00da, 0x010d)
-#define AR5K_EEPROM_CTL(_v)		AR5K_EEPROM_OFF(_v, 0x00e4, 0x0128)
+#define AR5K_EEPROM_CTL(_v)		AR5K_EEPROM_OFF(_v, 0x00e4, 0x0128)	/* Conformance test limits */
 
-/* Since 3.1 */
+/* [3.1 - 3.3] */
 #define AR5K_EEPROM_OBDB0_2GHZ		0x00ec
 #define AR5K_EEPROM_OBDB1_2GHZ		0x00ed
 
@@ -1718,12 +1721,12 @@
  * PHY PLL (Phase Locked Loop) control register
  */
 #define	AR5K_PHY_PLL			0x987c
-#define	AR5K_PHY_PLL_20MHZ		0x13		/* [5111] */
-#define	AR5K_PHY_PLL_40MHZ_5211		0x18
+#define	AR5K_PHY_PLL_20MHZ		0x13	/* For half rate (?) [5111+] */
+#define	AR5K_PHY_PLL_40MHZ_5211		0x18	/* For 802.11a */
 #define	AR5K_PHY_PLL_40MHZ_5212		0x000000aa
 #define	AR5K_PHY_PLL_40MHZ		(hal->ah_version == AR5K_AR5211 ? \
 					AR5K_PHY_PLL_40MHZ_5211 : AR5K_PHY_PLL_40MHZ_5212)
-#define	AR5K_PHY_PLL_44MHZ_5211		0x19
+#define	AR5K_PHY_PLL_44MHZ_5211		0x19	/* For 802.11b/g */
 #define	AR5K_PHY_PLL_44MHZ_5212		0x000000ab
 #define	AR5K_PHY_PLL_44MHZ		(hal->ah_version == AR5K_AR5211 ? \
 					AR5K_PHY_PLL_44MHZ_5211 : AR5K_PHY_PLL_44MHZ_5212)
@@ -1770,7 +1773,8 @@
 						/* Channel set on 5111 */
 						/* Used to read radio revision*/
 
-#define AR5K_RF_BUFFER_CONTROL_4	0x98d4  /* Bank 0,1,2,6 on 5111 */
+#define AR5K_RF_BUFFER_CONTROL_4	0x98d4  /* RF Stage register on 5110 */
+						/* Bank 0,1,2,6 on 5111 */
 						/* Bank 1 on 5112 */
 						/* Used during activation on 5111 */
 
@@ -1796,14 +1800,14 @@
 /*
  * PHY timing I(nphase) Q(adrature) control register [5111+]
  */
-#define	AR5K_PHY_IQ			0x9920
-#define	AR5K_PHY_IQ_CORR_Q_Q_COFF	0x0000001f
-#define	AR5K_PHY_IQ_CORR_Q_I_COFF	0x000007e0
+#define	AR5K_PHY_IQ			0x9920		/* Register address */
+#define	AR5K_PHY_IQ_CORR_Q_Q_COFF	0x0000001f	/* Mask for q correction info */
+#define	AR5K_PHY_IQ_CORR_Q_I_COFF	0x000007e0	/* Mask for i correction info */
 #define	AR5K_PHY_IQ_CORR_Q_I_COFF_S	5
-#define	AR5K_PHY_IQ_CORR_ENABLE		0x00000800
+#define	AR5K_PHY_IQ_CORR_ENABLE		0x00000800	/* Enable i/q correction */
 #define	AR5K_PHY_IQ_CAL_NUM_LOG_MAX	0x0000f000
 #define	AR5K_PHY_IQ_CAL_NUM_LOG_MAX_S	12
-#define	AR5K_PHY_IQ_RUN			0x00010000
+#define	AR5K_PHY_IQ_RUN			0x00010000	/* Run i/q calibration */
 
 
 /*
@@ -1846,13 +1850,19 @@
 /*---[5111+]---*/
 #define	AR5K_PHY_FRAME_CTL_TX_CLIP	0x00000038
 #define	AR5K_PHY_FRAME_CTL_TX_CLIP_S	3
-/*---[5110]---*/
+/*---[5110/5111]---*/
 #define	AR5K_PHY_FRAME_CTL_TIMING_ERR	0x01000000
 #define	AR5K_PHY_FRAME_CTL_PARITY_ERR	0x02000000
-#define	AR5K_PHY_FRAME_CTL_ILLRATE_ERR	0x04000000
-#define	AR5K_PHY_FRAME_CTL_ILLLEN_ERR	0x08000000
+#define	AR5K_PHY_FRAME_CTL_ILLRATE_ERR	0x04000000	/* illegal rate */
+#define	AR5K_PHY_FRAME_CTL_ILLLEN_ERR	0x08000000	/* illegal length */
 #define	AR5K_PHY_FRAME_CTL_SERVICE_ERR	0x20000000
-#define	AR5K_PHY_FRAME_CTL_TXURN_ERR	0x40000000
+#define	AR5K_PHY_FRAME_CTL_TXURN_ERR	0x40000000	/* tx underrun */
+#define AR5K_PHY_FRAME_CTL_INI		AR5K_PHY_FRAME_CTL_SERVICE_ERR | \
+			AR5K_PHY_FRAME_CTL_TXURN_ERR | \
+			AR5K_PHY_FRAME_CTL_ILLLEN_ERR | \
+			AR5K_PHY_FRAME_CTL_ILLRATE_ERR | \
+			AR5K_PHY_FRAME_CTL_PARITY_ERR | \
+			AR5K_PHY_FRAME_CTL_TIMING_ERR
 
 /*
  * PHY radar detection register [5111+]
@@ -1928,7 +1938,7 @@ after DFS is enabled */
  */
 #define	AR5K_PHY_IQRES_CAL_PWR_I	0x9c10 /* I (Inphase) power value */
 #define	AR5K_PHY_IQRES_CAL_PWR_Q	0x9c14 /* Q (Quadrature) power value */
-#define	AR5K_PHY_IQRES_CAL_CORR		0x9c18
+#define	AR5K_PHY_IQRES_CAL_CORR		0x9c18	/* I/Q Correlation */
 
 /*
  * PHY current RSSI register [5111+]
@@ -1936,7 +1946,7 @@ after DFS is enabled */
 #define	AR5K_PHY_CURRENT_RSSI		0x9c1c
 
 /*
- * PHY PCDAC TX power register [511+ (?)]
+ * PHY PCDAC TX power table
  */
 #define	AR5K_PHY_PCDAC_TXPOWER_BASE	0xa180
 #define	AR5K_PHY_PCDAC_TXPOWER(_n)	(AR5K_PHY_PCDAC_TXPOWER_BASE + ((_n) << 2))
@@ -1944,15 +1954,15 @@ after DFS is enabled */
 /*
  * PHY mode register [5111+]
  */
-#define	AR5K_PHY_MODE			0x0a200
-#define	AR5K_PHY_MODE_MOD		0x00000001
+#define	AR5K_PHY_MODE			0x0a200		/* Register address */
+#define	AR5K_PHY_MODE_MOD		0x00000001	/* PHY Modulation mask*/
 #define AR5K_PHY_MODE_MOD_OFDM		0
 #define AR5K_PHY_MODE_MOD_CCK		1
-#define AR5K_PHY_MODE_FREQ		0x00000002
+#define AR5K_PHY_MODE_FREQ		0x00000002	/* Freq mode mask */
 #define	AR5K_PHY_MODE_FREQ_5GHZ		0
 #define	AR5K_PHY_MODE_FREQ_2GHZ		2
-#define AR5K_PHY_MODE_MOD_DYN		0x00000004	/* [5112+] */
-#define AR5K_PHY_MODE_RAD		0x00000008	/* [5112+] */
+#define AR5K_PHY_MODE_MOD_DYN		0x00000004	/* Dynamic OFDM/CCK mode mask [5112+] */
+#define AR5K_PHY_MODE_RAD		0x00000008	/* [5212+] */
 #define AR5K_PHY_MODE_RAD_RF5111	0
 #define AR5K_PHY_MODE_RAD_RF5112	8
 #define AR5K_PHY_MODE_XR		0x00000010	/* [5112+] */
