From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 1/3] staging/rtl8192u: use s8 instead of char
Date: Wed, 20 Jul 2016 17:13:58 +0200
Message-ID: <20160720151818.4142386-1-arnd@arndb.de>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
incorrect code that results from 'char' being unsigned here, e.g.

staging/rtl8192u/r8192U_core.c:4150:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
staging/rtl8192u/r8192U_dm.c:646:50: error: comparison is always false due to limited range of data type [-Werror=type-limits]

This patch changes all uses of 'char' in this driver that refer to
8-bit integers to use 's8' instead, which is signed on all architectures.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Acked-by: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/staging/rtl8192u/ieee80211/ieee80211.h |  4 ++--
 drivers/staging/rtl8192u/r8192U.h              |  4 ++--
 drivers/staging/rtl8192u/r8192U_core.c         | 14 +++++++-------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211.h b/drivers/staging/rtl8192u/ieee80211/ieee80211.h
index 09e9499b7f9d..077ea13eb1e7 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211.h
@@ -746,7 +746,7 @@ struct ieee80211_rx_stats {
 	bool		  bisrxaggrsubframe;
 	bool		  bPacketBeacon;	//cosa add for rssi
 	bool		  bToSelfBA;		//cosa add for rssi
-	char	  cck_adc_pwdb[4];	//cosa add for rx path selection
+	s8		  cck_adc_pwdb[4];	//cosa add for rx path selection
 	u16		  Seq_Num;
 
 };
@@ -1814,7 +1814,7 @@ struct ieee80211_device {
 	u32 wpax_type_notify; //{added by David, 2006.9.26}
 
 	/* QoS related flag */
-	char init_wmmparam_flag;
+	s8  init_wmmparam_flag;
 	/* set on initialization */
 	u8  qos_support;
 
diff --git a/drivers/staging/rtl8192u/r8192U.h b/drivers/staging/rtl8192u/r8192U.h
index 5dba6a28dd9b..b28bc7812caa 100644
--- a/drivers/staging/rtl8192u/r8192U.h
+++ b/drivers/staging/rtl8192u/r8192U.h
@@ -533,7 +533,7 @@ typedef struct _rt_9x_tx_rate_history {
 	u32             ht_mcs[4][16];
 } rt_tx_rahis_t, *prt_tx_rahis_t;
 typedef struct _RT_SMOOTH_DATA_4RF {
-	char    elements[4][100]; /* array to store values */
+	s8    elements[4][100]; /* array to store values */
 	u32     index;            /* index to current array to store */
 	u32     TotalNum;         /* num of valid elements */
 	u32     TotalVal[4];      /* sum of valid elements */
@@ -1031,7 +1031,7 @@ typedef struct r8192_priv {
 	s8 cck_present_attentuation;
 	u8 cck_present_attentuation_20Mdefault;
 	u8 cck_present_attentuation_40Mdefault;
-	char cck_present_attentuation_difference;
+	s8 cck_present_attentuation_difference;
 	bool btxpower_tracking;
 	bool bcck_in_ch14;
 	bool btxpowerdata_readfromEEPORM;
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index dd0970facdf5..f36b2d3b1ee9 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -4209,7 +4209,7 @@ static void rtl8192_process_phyinfo(struct r8192_priv *priv, u8 *buffer,
  *
  * Return:		0-100 percentage
  *---------------------------------------------------------------------------*/
-static u8 rtl819x_query_rxpwrpercentage(char antpower)
+static u8 rtl819x_query_rxpwrpercentage(s8 antpower)
 {
 	if ((antpower <= -100) || (antpower >= 20))
 		return	0;
@@ -4220,9 +4220,9 @@ static u8 rtl819x_query_rxpwrpercentage(char antpower)
 
 }	/* QueryRxPwrPercentage */
 
-static u8 rtl819x_evm_dbtopercentage(char value)
+static u8 rtl819x_evm_dbtopercentage(s8 value)
 {
-	char ret_val;
+	s8 ret_val;
 
 	ret_val = value;
 
@@ -4297,8 +4297,8 @@ static void rtl8192_query_rxphystatus(struct r8192_priv *priv,
 	phy_ofdm_rx_status_rxsc_sgien_exintfflag *prxsc;
 	u8	*prxpkt;
 	u8	i, max_spatial_stream, tmp_rxsnr, tmp_rxevm, rxsc_sgien_exflg;
-	char	rx_pwr[4], rx_pwr_all = 0;
-	char	rx_snrX, rx_evmX;
+	s8	rx_pwr[4], rx_pwr_all = 0;
+	s8	rx_snrX, rx_evmX;
 	u8	evm, pwdb_all;
 	u32	RSSI, total_rssi = 0;
 	u8	is_cck_rate = 0;
@@ -4423,7 +4423,7 @@ static void rtl8192_query_rxphystatus(struct r8192_priv *priv,
 
 			/* Get Rx snr value in DB */
 			tmp_rxsnr =	pofdm_buf->rxsnr_X[i];
-			rx_snrX = (char)(tmp_rxsnr);
+			rx_snrX = (s8)(tmp_rxsnr);
 			rx_snrX /= 2;
 			priv->stats.rxSNRdB[i] = (long)rx_snrX;
 
@@ -4457,7 +4457,7 @@ static void rtl8192_query_rxphystatus(struct r8192_priv *priv,
 
 		for (i = 0; i < max_spatial_stream; i++) {
 			tmp_rxevm =	pofdm_buf->rxevm_X[i];
-			rx_evmX = (char)(tmp_rxevm);
+			rx_evmX = (s8)(tmp_rxevm);
 
 			/* Do not use shift operation like "rx_evmX >>= 1"
 			 * because the compiler of free build environment will
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
