From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] Rename IPW2100 debugging macros to not look like config
 options.
Date: Wed, 31 Jan 2007 02:39:40 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0701310234530.29767@CPE00045a9c397f-CM001225dbafb6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yi.zhu@intel.com, linville@tuxdriver.com, netdev@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:54490 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbXAaIIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 03:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Rename some internal ipw2100 debugging macros to not look like
user-settable kernel config settings.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

 make some renames based on short conversation with yi.zhu@intel.com:

	CONFIG_IPW2100_RX_DEBUG -> IPW2100_RX_DEBUG
	CONFIG_IPW2100_DEBUG_C3 -> IPW2100_DEBUG_C3
	CONFIG_IPW2100_TX_POWER -> IPW2100_TX_POWER


diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index b85857a..d0639a4 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -175,7 +175,7 @@ that only one external action is invoked at a time.

 /* Debugging stuff */
 #ifdef CONFIG_IPW2100_DEBUG
-#define CONFIG_IPW2100_RX_DEBUG	/* Reception debugging */
+#define IPW2100_RX_DEBUG	/* Reception debugging */
 #endif

 MODULE_DESCRIPTION(DRV_DESCRIPTION);
@@ -2239,7 +2239,7 @@ static void ipw2100_snapshot_free(struct ipw2100_priv *priv)
 	priv->snapshot[0] = NULL;
 }

-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 static int ipw2100_snapshot_alloc(struct ipw2100_priv *priv)
 {
 	int i;
@@ -2314,13 +2314,13 @@ static u32 ipw2100_match_buf(struct ipw2100_priv *priv, u8 * in_buf,
  * The size of the constructed ethernet
  *
  */
-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 static u8 packet_data[IPW_RX_NIC_BUFFER_LENGTH];
 #endif

 static void ipw2100_corruption_detected(struct ipw2100_priv *priv, int i)
 {
-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 	struct ipw2100_status *status = &priv->status_queue.drv[i];
 	u32 match, reg;
 	int j;
@@ -2342,7 +2342,7 @@ static void ipw2100_corruption_detected(struct ipw2100_priv *priv, int i)
 	}
 #endif

-#ifdef CONFIG_IPW2100_DEBUG_C3
+#ifdef IPW2100_DEBUG_C3
 	/* Halt the fimrware so we can get a good image */
 	write_register(priv->net_dev, IPW_REG_RESET_REG,
 		       IPW_AUX_HOST_RESET_REG_STOP_MASTER);
@@ -2413,7 +2413,7 @@ static void isr_rx(struct ipw2100_priv *priv, int i,

 	skb_put(packet->skb, status->frame_size);

-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 	/* Make a copy of the frame so we can dump it to the logs if
 	 * ieee80211_rx fails */
 	memcpy(packet_data, packet->skb->data,
@@ -2421,7 +2421,7 @@ static void isr_rx(struct ipw2100_priv *priv, int i,
 #endif

 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
-#ifdef CONFIG_IPW2100_RX_DEBUG
+#ifdef IPW2100_RX_DEBUG
 		IPW_DEBUG_DROP("%s: Non consumed packet:\n",
 			       priv->net_dev->name);
 		printk_buf(IPW_DL_DROP, packet_data, status->frame_size);
@@ -4912,7 +4912,7 @@ static int ipw2100_set_power_mode(struct ipw2100_priv *priv, int power_level)
 	else
 		priv->power_mode = IPW_POWER_ENABLED | power_level;

-#ifdef CONFIG_IPW2100_TX_POWER
+#ifdef IPW2100_TX_POWER
 	if (priv->port_type == IBSS && priv->adhoc_power != DFTL_IBSS_TX_POWER) {
 		/* Set beacon interval */
 		cmd.host_command = TX_POWER_INDEX;

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://www.fsdev.dreamhosters.com/wiki/index.php?title=Main_Page
========================================================================
