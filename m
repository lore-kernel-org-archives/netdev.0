From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Tue, 19 Jul 2016 17:33:01 +0200
Message-ID: <20160719153403.2967812-2-arnd@arndb.de>
References: <20160719153403.2967812-1-arnd@arndb.de>
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Jes Sorensen <Jes.Sorensen@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719153403.2967812-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
incorrect code that results from 'char' being unsigned here, e.g.

staging/rtl8192e/rtl8192e/r8192E_phy.c:1072:36: error: comparison is always false due to limited range of data type [-Werror=type-limits]
staging/rtl8192e/rtl8192e/r8192E_phy.c:1104:36: error: comparison is always false due to limited range of data type [-Werror=type-limits]
staging/rtl8192e/rtl8192e/rtl_core.c:1987:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
staging/rtl8192e/rtl8192e/rtl_dm.c:782:37: error: comparison is always false due to limited range of data type [-Werror=type-limits]
staging/rtl8192e/rtl819x_TSProc.c:326:14: error: comparison is always true due to limited range of data type [-Werror=type-limits]
staging/rtl8192e/rtllib_softmac_wx.c:465:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]

This patch changes all uses of 'char' in this driver that refer to
8-bit integers to use 's8' instead, which is signed on all architectures.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c | 8 ++++----
 drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c | 2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c   | 6 +++---
 drivers/staging/rtl8192e/rtl8192e/rtl_core.h   | 8 ++++----
 drivers/staging/rtl8192e/rtl819x_TSProc.c      | 2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c b/drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c
index ba64a4f1b3a8..8d6bca61e7aa 100644
--- a/drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c
+++ b/drivers/staging/rtl8192e/rtl8192e/r8192E_dev.c
@@ -1487,8 +1487,8 @@ static void _rtl92e_query_rxphystatus(
 	struct phy_ofdm_rx_status_rxsc_sgien_exintfflag *prxsc;
 	u8 *prxpkt;
 	u8 i, max_spatial_stream, tmp_rxsnr, tmp_rxevm, rxsc_sgien_exflg;
-	char rx_pwr[4], rx_pwr_all = 0;
-	char rx_snrX, rx_evmX;
+	s8 rx_pwr[4], rx_pwr_all = 0;
+	s8 rx_snrX, rx_evmX;
 	u8 evm, pwdb_all;
 	u32 RSSI, total_rssi = 0;
 	u8 is_cck_rate = 0;
@@ -1613,7 +1613,7 @@ static void _rtl92e_query_rxphystatus(
 				     2) - 110;
 
 			tmp_rxsnr = pofdm_buf->rxsnr_X[i];
-			rx_snrX = (char)(tmp_rxsnr);
+			rx_snrX = (s8)(tmp_rxsnr);
 			rx_snrX /= 2;
 			priv->stats.rxSNRdB[i] = (long)rx_snrX;
 
@@ -1643,7 +1643,7 @@ static void _rtl92e_query_rxphystatus(
 
 		for (i = 0; i < max_spatial_stream; i++) {
 			tmp_rxevm = pofdm_buf->rxevm_X[i];
-			rx_evmX = (char)(tmp_rxevm);
+			rx_evmX = (s8)(tmp_rxevm);
 
 			rx_evmX /= 2;
 
diff --git a/drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c b/drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c
index 5e3bbe5c3ca4..0698131e4300 100644
--- a/drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c
+++ b/drivers/staging/rtl8192e/rtl8192e/r8192E_phy.c
@@ -630,7 +630,7 @@ void rtl92e_set_tx_power(struct net_device *dev, u8 channel)
 {
 	struct r8192_priv *priv = rtllib_priv(dev);
 	u8	powerlevel = 0, powerlevelOFDM24G = 0;
-	char ant_pwr_diff;
+	s8	ant_pwr_diff;
 	u32	u4RegValue;
 
 	if (priv->epromtype == EEPROM_93C46) {
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
index 13a5ddc2bea5..41e05f206300 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
@@ -1982,7 +1982,7 @@ void rtl92e_update_rx_statistics(struct r8192_priv *priv,
 					weighting) / 6;
 }
 
-u8 rtl92e_rx_db_to_percent(char antpower)
+u8 rtl92e_rx_db_to_percent(s8 antpower)
 {
 	if ((antpower <= -100) || (antpower >= 20))
 		return	0;
@@ -1993,9 +1993,9 @@ u8 rtl92e_rx_db_to_percent(char antpower)
 
 }	/* QueryRxPwrPercentage */
 
-u8 rtl92e_evm_db_to_percent(char value)
+u8 rtl92e_evm_db_to_percent(s8 value)
 {
-	char ret_val;
+	s8 ret_val;
 
 	ret_val = value;
 
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.h b/drivers/staging/rtl8192e/rtl8192e/rtl_core.h
index f627fdc15a58..6921125c9d35 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.h
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.h
@@ -503,8 +503,8 @@ struct r8192_priv {
 	u32 Pwr_Track;
 	u8 CCKPresentAttentuation_20Mdefault;
 	u8 CCKPresentAttentuation_40Mdefault;
-	char CCKPresentAttentuation_difference;
-	char CCKPresentAttentuation;
+	s8 CCKPresentAttentuation_difference;
+	s8 CCKPresentAttentuation;
 	long undecorated_smoothed_pwdb;
 
 	u32 MCSTxPowerLevelOriginalOffset[6];
@@ -604,8 +604,8 @@ void rtl92e_update_rx_pkt_timestamp(struct net_device *dev,
 long rtl92e_translate_to_dbm(struct r8192_priv *priv, u8 signal_strength_index);
 void rtl92e_update_rx_statistics(struct r8192_priv *priv,
 				 struct rtllib_rx_stats *pprevious_stats);
-u8 rtl92e_evm_db_to_percent(char value);
-u8 rtl92e_rx_db_to_percent(char antpower);
+u8 rtl92e_evm_db_to_percent(s8 value);
+u8 rtl92e_rx_db_to_percent(s8 antpower);
 void rtl92e_copy_mpdu_stats(struct rtllib_rx_stats *psrc_stats,
 			    struct rtllib_rx_stats *ptarget_stats);
 bool rtl92e_enable_nic(struct net_device *dev);
diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
index 2c8a526773ed..e0a2fe5e6148 100644
--- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
+++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
@@ -323,7 +323,7 @@ bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
 	if (ieee->current_network.qos_data.supported == 0) {
 		UP = 0;
 	} else {
-		if (!IsACValid(TID)) {
+		if (!IsACValid((s8)TID)) {
 			netdev_warn(ieee->dev, "%s(): TID(%d) is not valid\n",
 				    __func__, TID);
 			return false;
-- 
2.9.0
