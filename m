From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v6 09/19] net: ipvlan: use __ethtool_get_ksettings
Date: Tue, 19 Jan 2016 16:43:54 -0800
Message-ID: <1453250644-14796-10-git-send-email-ddecotig@gmail.com>
References: <1453250644-14796-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org, linux-mips@linux-mips.org,
	fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36656 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933378AbcATAoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 19:44:19 -0500
In-Reply-To: <1453250644-14796-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f94392d..3ea9983 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -346,12 +346,12 @@ static const struct header_ops ipvlan_header_ops = {
 	.cache_update	= eth_header_cache_update,
 };
 
-static int ipvlan_ethtool_get_settings(struct net_device *dev,
-				       struct ethtool_cmd *cmd)
+static int ipvlan_ethtool_get_ksettings(struct net_device *dev,
+					struct ethtool_ksettings *cmd)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
 
-	return __ethtool_get_settings(ipvlan->phy_dev, cmd);
+	return __ethtool_get_ksettings(ipvlan->phy_dev, cmd);
 }
 
 static void ipvlan_ethtool_get_drvinfo(struct net_device *dev,
@@ -377,7 +377,7 @@ static void ipvlan_ethtool_set_msglevel(struct net_device *dev, u32 value)
 
 static const struct ethtool_ops ipvlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
-	.get_settings	= ipvlan_ethtool_get_settings,
+	.get_ksettings	= ipvlan_ethtool_get_ksettings,
 	.get_drvinfo	= ipvlan_ethtool_get_drvinfo,
 	.get_msglevel	= ipvlan_ethtool_get_msglevel,
 	.set_msglevel	= ipvlan_ethtool_set_msglevel,
-- 
2.7.0.rc3.207.g0ac5344
