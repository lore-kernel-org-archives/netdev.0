From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Subject: [PATCH 2/3] netdev: ARRAY_SIZE() cleanups
Date: Thu, 18 Oct 2007 11:50:22 +0200
Message-ID: <20071018095022.GC23058@inspiron>
References: <20071018094706.GA23058@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:17438 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845AbXJRJrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:47:09 -0400
Received: by ug-out-1314.google.com with SMTP id z38so396868ugc
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 02:47:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071018094706.GA23058@inspiron>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Date: Thu, 18 Oct 2007 10:16:33 +0200
Subject: [PATCH] netdev: ARRAY_SIZE() cleanups

Convert array size calculations to use ARRAY_SIZE().

Signed-off-by: Alejandro Martinez Ruiz <alex@flawedcode.org>
---
 drivers/net/e1000e/ethtool.c         |    3 +--
 drivers/net/e1000e/phy.c             |    3 +--
 drivers/net/ixgbe/ixgbe_ethtool.c    |    3 +--
 drivers/net/tehuti.c                 |    2 +-
 drivers/net/tulip/de4x5.c            |    2 +-
 drivers/net/wireless/ipw2100.c       |    3 +--
 drivers/net/wireless/libertas/11d.c  |   24 +++++++-----------------
 drivers/net/wireless/libertas/wext.c |   11 +++--------
 drivers/net/wireless/wavelan.c       |    2 +-
 drivers/net/wireless/wavelan_cs.c    |    4 ++--
 10 files changed, 19 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 61c84c0..85297cd 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -95,8 +95,7 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "tx_dma_failed", E1000_STAT(tx_dma_failed) },
 };
 
-#define E1000_GLOBAL_STATS_LEN	\
-	sizeof(e1000_gstrings_stats) / sizeof(struct e1000_stats)
+#define E1000_GLOBAL_STATS_LEN	ARRAY_SIZE(e1000_gstrings_stats)
 #define E1000_STATS_LEN (E1000_GLOBAL_STATS_LEN)
 static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register test  (offline)", "Eeprom test    (offline)",
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 7932318..fc6fee1 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -49,8 +49,7 @@ static const u16 e1000_igp_2_cable_length_table[] =
 	  100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
 	  124};
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
-		(sizeof(e1000_igp_2_cable_length_table) / \
-		 sizeof(e1000_igp_2_cable_length_table[0]))
+		ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
 /**
  *  e1000e_check_reset_block_generic - Check if PHY reset is blocked
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a4e576a..3635344 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -96,8 +96,7 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 		((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
 		 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
 		 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
-#define IXGBE_GLOBAL_STATS_LEN \
-	sizeof(ixgbe_gstrings_stats) / sizeof(struct ixgbe_stats)
+#define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 
 static int ixgbe_get_settings(struct net_device *netdev,
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 7334d09..db59c48 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -621,7 +621,7 @@ err:
 static void __init bdx_firmware_endianess(void)
 {
 	int i;
-	for (i = 0; i < sizeof(s_firmLoad) / sizeof(u32); i++)
+	for (i = 0; i < ARRAY_SIZE(s_firmLoad); i++)
 		s_firmLoad[i] = CPU_CHIP_SWAP32(s_firmLoad[i]);
 }
 
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 41f34bb..c5ebf00 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -4175,7 +4175,7 @@ de4x5_bad_srom(struct de4x5_private *lp)
 {
     int i, status = 0;
 
-    for (i=0; i<sizeof(enet_det)/ETH_ALEN; i++) {
+    for (i=0; i < ARRAY_SIZE(enet_det); i++) {
 	if (!de4x5_strncmp((char *)&lp->srom, (char *)&enet_det[i], 3) &&
 	    !de4x5_strncmp((char *)&lp->srom+0x10, (char *)&enet_det[i], 3)) {
 	    if (i == 0) {
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 2d46a16..8f5497b 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6582,8 +6582,7 @@ static const long ipw2100_frequencies[] = {
 	2472, 2484
 };
 
-#define FREQ_COUNT (sizeof(ipw2100_frequencies) / \
-                    sizeof(ipw2100_frequencies[0]))
+#define FREQ_COUNT	ARRAY_SIZE(ipw2100_frequencies)
 
 static const long ipw2100_rates_11b[] = {
 	1000000,
diff --git a/drivers/net/wireless/libertas/11d.c b/drivers/net/wireless/libertas/11d.c
index 9cf0211..8bbd322 100644
--- a/drivers/net/wireless/libertas/11d.c
+++ b/drivers/net/wireless/libertas/11d.c
@@ -46,13 +46,11 @@ static struct chan_freq_power channel_freq_power_UN_BG[] = {
 static u8 wlan_region_2_code(u8 * region)
 {
 	u8 i;
-	u8 size = sizeof(region_code_mapping)/
-		  sizeof(struct region_code_mapping);
 
 	for (i = 0; region[i] && i < COUNTRY_CODE_LEN; i++)
 		region[i] = toupper(region[i]);
 
-	for (i = 0; i < size; i++) {
+	for (i = 0; i < ARRAY_SIZE(region_code_mapping); i++) {
 		if (!memcmp(region, region_code_mapping[i].region,
 			    COUNTRY_CODE_LEN))
 			return (region_code_mapping[i].code);
@@ -65,9 +63,8 @@ static u8 wlan_region_2_code(u8 * region)
 static u8 *wlan_code_2_region(u8 code)
 {
 	u8 i;
-	u8 size = sizeof(region_code_mapping)
-		  / sizeof(struct region_code_mapping);
-	for (i = 0; i < size; i++) {
+
+	for (i = 0; i < ARRAY_SIZE(region_code_mapping); i++) {
 		if (region_code_mapping[i].code == code)
 			return (region_code_mapping[i].region);
 	}
@@ -90,8 +87,7 @@ static u8 wlan_get_chan_11d(u8 band, u8 firstchan, u8 nrchan, u8 * chan)
 	u8 cfp_no;
 
 	cfp = channel_freq_power_UN_BG;
-	cfp_no = sizeof(channel_freq_power_UN_BG) /
-	    sizeof(struct chan_freq_power);
+	cfp_no = ARRAY_SIZE(channel_freq_power_UN_BG);
 
 	for (i = 0; i < cfp_no; i++) {
 		if ((cfp + i)->channel == firstchan) {
@@ -141,16 +137,12 @@ static u8 wlan_channel_known_11d(u8 chan,
 u32 libertas_chan_2_freq(u8 chan, u8 band)
 {
 	struct chan_freq_power *cf;
-	u16 cnt;
 	u16 i;
 	u32 freq = 0;
 
 	cf = channel_freq_power_UN_BG;
-	cnt =
-	    sizeof(channel_freq_power_UN_BG) /
-	    sizeof(struct chan_freq_power);
 
-	for (i = 0; i < cnt; i++) {
+	for (i = 0; i < ARRAY_SIZE(channel_freq_power_UN_BG); i++) {
 		if (chan == cf[i].channel)
 			freq = cf[i].freq;
 	}
@@ -664,8 +656,7 @@ int libertas_create_dnld_countryinfo_11d(wlan_private * priv)
 	if (priv->adapter->enable11d) {
 		/* update parsed_region_chan_11; dnld domaininf to FW */
 
-		for (j = 0; j < sizeof(adapter->region_channel) /
-		     sizeof(adapter->region_channel[0]); j++) {
+		for (j = 0; j < ARRAY_SIZE(adapter->region_channel); j++) {
 			region_chan = &adapter->region_channel[j];
 
 			lbs_deb_11d("%d region_chan->band %d\n", j,
@@ -679,8 +670,7 @@ int libertas_create_dnld_countryinfo_11d(wlan_private * priv)
 			break;
 		}
 
-		if (j >= sizeof(adapter->region_channel) /
-		    sizeof(adapter->region_channel[0])) {
+		if (j >= ARRAY_SIZE(adapter->region_channel)) {
 			lbs_deb_11d("region_chan not found, band %d\n",
 			       adapter->curbssparams.band);
 			ret = -1;
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6f5aa3..37b1777 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -34,11 +34,9 @@ struct chan_freq_power *libertas_find_cfp_by_band_and_channel(wlan_adapter * ada
 {
 	struct chan_freq_power *cfp = NULL;
 	struct region_channel *rc;
-	int count = sizeof(adapter->region_channel) /
-	    sizeof(adapter->region_channel[0]);
 	int i, j;
 
-	for (j = 0; !cfp && (j < count); j++) {
+	for (j = 0; !cfp && (j < ARRAY_SIZE(adapter->region_channel)); j++) {
 		rc = &adapter->region_channel[j];
 
 		if (adapter->enable11d)
@@ -75,11 +73,9 @@ static struct chan_freq_power *find_cfp_by_band_and_freq(wlan_adapter * adapter,
 {
 	struct chan_freq_power *cfp = NULL;
 	struct region_channel *rc;
-	int count = sizeof(adapter->region_channel) /
-	    sizeof(adapter->region_channel[0]);
 	int i, j;
 
-	for (j = 0; !cfp && (j < count); j++) {
+	for (j = 0; !cfp && (j < ARRAY_SIZE(adapter->region_channel)); j++) {
 		rc = &adapter->region_channel[j];
 
 		if (adapter->enable11d)
@@ -606,8 +602,7 @@ static int wlan_get_range(struct net_device *dev, struct iw_request_info *info,
 	}
 	if (!flag) {
 		for (j = 0; (range->num_frequency < IW_MAX_FREQUENCIES)
-		     && (j < sizeof(adapter->region_channel)
-			 / sizeof(adapter->region_channel[0])); j++) {
+		     && (j < ARRAY_SIZE(adapter->region_channel)); j++) {
 			cfp = adapter->region_channel[j].CFP;
 			for (i = 0; (range->num_frequency < IW_MAX_FREQUENCIES)
 			     && adapter->region_channel[j].valid
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index a1f8a16..b343ce2 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -3740,7 +3740,7 @@ static int wv_check_ioaddr(unsigned long ioaddr, u8 * mac)
 	 * non-NCR/AT&T/Lucent ISA card.  See wavelan.p.h for detail on
 	 * how to configure your card.
 	 */
-	for (i = 0; i < (sizeof(MAC_ADDRESSES) / sizeof(char) / 3); i++)
+	for (i = 0; i < ARRAY_SIZE(MAC_ADDRESSES); i++)
 		if ((mac[0] == MAC_ADDRESSES[i][0]) &&
 		    (mac[1] == MAC_ADDRESSES[i][1]) &&
 		    (mac[2] == MAC_ADDRESSES[i][2]))
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 577c647..f5b38de 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -3223,14 +3223,14 @@ wv_mmc_init(struct net_device *	dev)
    * non-NCR/AT&T/Lucent PCMCIA cards, see wavelan_cs.h for detail on
    * how to configure your card...
    */
-  for(i = 0; i < (sizeof(MAC_ADDRESSES) / sizeof(char) / 3); i++)
+  for(i = 0; i < ARRAY_SIZE(MAC_ADDRESSES); i++)
     if((psa.psa_univ_mac_addr[0] == MAC_ADDRESSES[i][0]) &&
        (psa.psa_univ_mac_addr[1] == MAC_ADDRESSES[i][1]) &&
        (psa.psa_univ_mac_addr[2] == MAC_ADDRESSES[i][2]))
       break;
 
   /* If we have not found it... */
-  if(i == (sizeof(MAC_ADDRESSES) / sizeof(char) / 3))
+  if(i == ARRAY_SIZE(MAC_ADDRESSES))
     {
 #ifdef DEBUG_CONFIG_ERRORS
       printk(KERN_WARNING "%s: wv_mmc_init(): Invalid MAC address: %02X:%02X:%02X:...\n",
-- 
1.5.3.4


