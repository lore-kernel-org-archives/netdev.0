From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: 3com: typhoon: fix typhoon_get_link_ksettings
Date: Sun,  6 Nov 2016 15:02:32 +0100
Message-ID: <1478440952-24973-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: dave@thedillows.org, sergei.shtylyov@cogentembedded.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32876 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbcKFOCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2016 09:02:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When moving from typhoon_get_settings to typhoon_getlink_ksettings
in the commit f7a5537cd2a5 ("net: 3com: typhoon: use new api
ethtool_{get|set}_link_ksettings"), we use a local variable supported
but we forgot to update the struct ethtool_link_ksettings with
this value.

We also initialize advertising to zero, because otherwise it may
be uninitialized if no case of the switch (tp->xcvr_select) is used.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- remove a duplicate "commit" in the commit log

 drivers/net/ethernet/3com/typhoon.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index dbdf06f..a0cacbe 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1000,7 +1000,7 @@ enum state_values {
 			   struct ethtool_link_ksettings *cmd)
 {
 	struct typhoon *tp = netdev_priv(dev);
-	u32 supported, advertising;
+	u32 supported, advertising = 0;
 
 	supported = SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 				SUPPORTED_Autoneg;
@@ -1049,6 +1049,11 @@ enum state_values {
 	else
 		cmd->base.autoneg = AUTONEG_DISABLE;
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-- 
1.7.4.4
