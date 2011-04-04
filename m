From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 01/12] sky2: support ethtool set_phys_id
Date: Mon, 04 Apr 2011 11:43:41 -0700
Message-ID: <20110404184501.356412753@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52787 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752Ab1DDSvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:06 -0400
Content-Disposition: inline; filename=sky2-phys-set.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ethtool set_phys_id to control LED. Fixes issues with RTNL being
held for extended periods.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2011-04-04 09:24:59.413162054 -0700
+++ b/drivers/net/sky2.c	2011-04-04 10:48:48.338000416 -0700
@@ -3826,23 +3826,24 @@ static void sky2_led(struct sky2_port *s
 }
 
 /* blink LED's for finding board */
-static int sky2_phys_id(struct net_device *dev, u32 data)
+static int sky2_set_phys_id(struct net_device *dev,
+			    enum ethtool_phys_id_state state)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	unsigned int i;
-
-	if (data == 0)
-		data = UINT_MAX;
 
-	for (i = 0; i < data; i++) {
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
+	case ETHTOOL_ID_INACTIVE:
+		sky2_led(sky2, MO_LED_NORM);
+		break;
+	case ETHTOOL_ID_ON:
 		sky2_led(sky2, MO_LED_ON);
-		if (msleep_interruptible(500))
-			break;
+		break;
+	case ETHTOOL_ID_OFF:
 		sky2_led(sky2, MO_LED_OFF);
-		if (msleep_interruptible(500))
-			break;
+		break;
 	}
-	sky2_led(sky2, MO_LED_NORM);
 
 	return 0;
 }
@@ -4269,7 +4270,7 @@ static const struct ethtool_ops sky2_eth
 	.set_ringparam	= sky2_set_ringparam,
 	.get_pauseparam = sky2_get_pauseparam,
 	.set_pauseparam = sky2_set_pauseparam,
-	.phys_id	= sky2_phys_id,
+	.set_phys_id	= sky2_set_phys_id,
 	.get_sset_count = sky2_get_sset_count,
 	.get_ethtool_stats = sky2_get_ethtool_stats,
 	.set_flags	= sky2_set_flags,


