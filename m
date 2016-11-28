From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH ethtool 1/2] ethtool-copy.h:sync with net
Date: Mon, 28 Nov 2016 14:25:11 +0100
Message-ID: <1480339512-5882-2-git-send-email-allan.nielsen@microsemi.com>
References: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linville@tuxdriver.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0047.outbound.protection.outlook.com ([104.47.41.47]:8416
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932503AbcK1NZp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:45 -0500
In-Reply-To: <1480339512-5882-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

This covers kernel changes upto:

commit ef05e4c22648c141298f51aab00eb22066838b47
Author: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Date:   Wed Nov 23 15:20:28 2016 +0530

    ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to PHYtunables

    3 types of PHY loopback are supported.
    i.e. Near-End Loopback, Far-End Loopback and External Loopback.

    Near-End Loopback:
    Transmitted data (TXD) is looped back in the PCS block onto the receive
    data signal (RXD). When Near-End loopback enable, no data is transmitted
    over the network. no data receive from the network.

    Far-End Loopback:
    This loopback is a special test mode to allow testing the PHY from link
    partner side. In this mode data that is received from the link partner pass
    through the PHY's receiver, looped back on the MII and transmitted back to
    the link partner.
    Data present on the transmit data pins of the MAC interface is ignored when
    using this test.

    External Loopback:
    An RJ45 loopback cable can be used to route the transmit signals an the
    output of the trnsformer back to the receiver inputs and this loopback will
    work at either 10 or 100 or 1000 Mbps speed.
    RJ45 Loopback cable created by conncting pin 1 to pin 3 and connecting pin
    2 to pin 6.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 ethtool-copy.h | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 70748f5..1ebdc72 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -247,6 +247,24 @@ struct ethtool_tunable {
 	void	*data[0];
 };
 
+enum phy_tunable_id {
+	ETHTOOL_PHY_ID_UNSPEC,
+	ETHTOOL_PHY_DOWNSHIFT,
+	ETHTOOL_PHY_LOOPBACK,
+	/*
+	 * Add your fresh new phy tunable attribute above and remember to update
+	 * phy_tunable_strings[] in net/core/ethtool.c
+	 */
+	__ETHTOOL_PHY_TUNABLE_COUNT,
+};
+
+enum phy_loopback_type {
+	ETHTOOL_PHY_LOOPBACK_DISABLE,
+	ETHTOOL_PHY_LOOPBACK_NEAR,
+	ETHTOOL_PHY_LOOPBACK_FAR,
+	ETHTOOL_PHY_LOOPBACK_EXTN
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -547,6 +565,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
+ * @ETH_SS_PHY_TUNABLES: PHY tunable names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -557,6 +576,7 @@ enum ethtool_stringset {
 	ETH_SS_RSS_HASH_FUNCS,
 	ETH_SS_TUNABLES,
 	ETH_SS_PHY_STATS,
+	ETH_SS_PHY_TUNABLES,
 };
 
 /**
@@ -1312,7 +1332,8 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
-
+#define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
+#define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.7.3
