From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/25) sk98: skethtool elimnateCamelCaps
Date: Mon, 15 Nov 2004 15:28:05 -0800
Message-ID: <20041115152805.6ff7a05f@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Take Cristoph's suggestion and make the new skethtool support use
linux naming convention (at least for the function names). Don't bother
with useless block comments.

These patches are based on what is in current net driver tree (ie after
1 - 9 of the earlier patches).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skethtool.c b/drivers/net/sk98lin/skethtool.c
--- a/drivers/net/sk98lin/skethtool.c	2004-11-15 11:21:23 -08:00
+++ b/drivers/net/sk98lin/skethtool.c	2004-11-15 11:21:23 -08:00
@@ -72,19 +72,7 @@
  *
  *****************************************************************************/
 
-/*****************************************************************************
- *
- * 	getSettings - retrieves the current settings of the selected adapter
- *
- * Description:
- *	The current configuration of the selected adapter is returned.
- *	This configuration involves a)speed, b)duplex and c)autoneg plus
- *	a number of other variables.
- *
- * Returns:    always 0
- *
- */
-static int getSettings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int sk98_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	const DEV_NET *pNet = netdev_priv(dev);
 	int port = pNet->PortNr;
@@ -172,19 +160,7 @@
 	return 1 + (pNet->pAC->RlmtNets == 2) + pNet->PortNr;
 }
 
-/*****************************************************************************
- *
- *	setSettings - configures the settings of a selected adapter
- *
- * Description:
- *	Possible settings that may be altered are a)speed, b)duplex or 
- *	c)autonegotiation.
- *
- * Returns:
- *	0:	everything fine, no error
- *	<0:	the return value is the error code of the failure 
- */
-static int setSettings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int sk98_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	DEV_NET *pNet = netdev_priv(dev);
 	SK_AC *pAC = pNet->pAC;
@@ -232,20 +208,8 @@
 	return 0;
 }
 
-/*****************************************************************************
- *
- * 	getDriverInfo - returns generic driver and adapter information
- *
- * Description:
- *	Generic driver information is returned via this function, such as
- *	the name of the driver, its version and and firmware version.
- *	In addition to this, the location of the selected adapter is 
- *	returned as a bus info string (e.g. '01:05.0').
- *	
- * Returns:	N/A
- *
- */
-static void getDriverInfo(struct net_device *dev, struct ethtool_drvinfo *info)
+static void sk98_get_driver_info(struct net_device *dev, 
+				 struct ethtool_drvinfo *info)
 {
 	const DEV_NET	*pNet = netdev_priv(dev);
 	const SK_AC *pAC = pNet->pAC;
@@ -263,7 +227,7 @@
 /*
  * Ethtool statistics support.
  */
-static const char StringsStats[][ETH_GSTRING_LEN] = {
+static const char sk98_stats_gstrings[][ETH_GSTRING_LEN] = {
 	"rx_packets",	"tx_packets",
 	"rx_bytes",	"tx_bytes",
 	"rx_errors",	"tx_errors",	
@@ -280,21 +244,21 @@
 	"tx_window_errors",
 };
 
-static int getStatsCount(struct net_device *dev)
+static int sk98_stats_count(struct net_device *dev)
 {
-	return ARRAY_SIZE(StringsStats);
+	return ARRAY_SIZE(sk98_stats_gstrings);
 }
 
-static void getStrings(struct net_device *dev, u32 stringset, u8 *data)
+static void sk98_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	switch(stringset) {
 	case ETH_SS_STATS:
-		memcpy(data, *StringsStats, sizeof(StringsStats));
+		memcpy(data, *sk98_stats_gstrings, sizeof(sk98_stats_gstrings));
 		break;
 	}
 }
 
-static void getEthtoolStats(struct net_device *dev,
+static void sk98_get_ethstats(struct net_device *dev,
 			    struct ethtool_stats *stats, u64 *data)
 {
 	const DEV_NET	*pNet = netdev_priv(dev);
@@ -331,16 +295,9 @@
 }
 
 
-/*****************************************************************************
- *
- * 	toggleLeds - Changes the LED state of an adapter
- *
- * Description:
- *	This function changes the current state of all LEDs of an adapter so
+/*
+ *	change the current state of all LEDs of an adapter so
  *	that it can be located by a user. 
- *
- * Returns:	N/A
- *
  */
 static void toggleLeds(DEV_NET *pNet, int on)
 {
@@ -411,21 +368,12 @@
 	mod_timer(&pAC->BlinkTimer, jiffies + HZ/4);
 }
 
-/*****************************************************************************
- *
- * 	locateDevice - start the locate NIC feature of the elected adapter 
- *
- * Description:
- *	This function is used if the user want to locate a particular NIC.
+/*
+ *	Ethtool phys_id used to locate a particular NIC.
  *	All LEDs are regularly switched on and off, so the NIC can easily
  *	be identified.
- *
- * Returns:	
- *	==0:	everything fine, no error, locateNIC test was started
- *	!=0:	one locateNIC test runs already
- *
  */
-static int locateDevice(struct net_device *dev, u32 data)
+static int sk98_flash_leds(struct net_device *dev, u32 data)
 {
 	DEV_NET *pNet = netdev_priv(dev);
 	SK_AC *pAC = pNet->pAC;
@@ -446,18 +394,7 @@
 	return 0;
 }
 
-/*****************************************************************************
- *
- * 	getPauseParams - retrieves the pause parameters
- *
- * Description:
- *	All current pause parameters of a selected adapter are placed 
- *	in the passed ethtool_pauseparam structure and are returned.
- *
- * Returns:	N/A
- *
- */
-static void getPauseParams(struct net_device *dev, struct ethtool_pauseparam *epause) 
+static void sk98_get_pause_param(struct net_device *dev, struct ethtool_pauseparam *epause) 
 {
 	DEV_NET	*pNet = netdev_priv(dev);
 	SK_AC *pAC = pNet->pAC;
@@ -470,18 +407,7 @@
 	epause->autoneg = epause->rx_pause || epause->tx_pause;
 }
 
-/*****************************************************************************
- *
- *	setPauseParams - configures the pause parameters of an adapter
- *
- * Description:
- *	This function sets the Rx or Tx pause parameters 
- *
- * Returns:
- *	==0:	everything fine, no error
- *	!=0:	the return value is the error code of the failure 
- */
-static int setPauseParams(struct net_device *dev , struct ethtool_pauseparam *epause)
+static int sk98_set_pause_param(struct net_device *dev , struct ethtool_pauseparam *epause)
 {
 	DEV_NET	*pNet = netdev_priv(dev);
 	SK_AC *pAC = pNet->pAC;
@@ -498,7 +424,7 @@
 	** the operator requested any modification of the flow 
 	** control parameters...
 	*/
-	getPauseParams(dev, &old);
+	sk98_get_pause_param(dev, &old);
 
 	/*
 	** perform modifications regarding the changes 
@@ -543,13 +469,13 @@
 }
 
 struct ethtool_ops SkGeEthtoolOps = {
-	.get_settings		= getSettings,
-	.set_settings		= setSettings,
-	.get_drvinfo		= getDriverInfo,
-	.get_strings		= getStrings,
-	.get_stats_count	= getStatsCount,
-	.get_ethtool_stats	= getEthtoolStats,
-	.phys_id		= locateDevice,
-	.get_pauseparam		= getPauseParams,
-	.set_pauseparam		= setPauseParams,
+	.get_settings		= sk98_get_settings,
+	.set_settings		= sk98_set_settings,
+	.get_drvinfo		= sk98_get_driver_info,
+	.get_strings		= sk98_get_strings,
+	.get_stats_count	= sk98_stats_count,
+	.get_ethtool_stats	= sk98_get_ethstats,
+	.phys_id		= sk98_flash_leds,
+	.get_pauseparam		= sk98_get_pause_param,
+	.set_pauseparam		= sk98_set_pause_param,
 };
