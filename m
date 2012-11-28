From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: fix hw_features setup
Date: Wed, 28 Nov 2012 17:13:10 +0100
Message-ID: <1354119190-16100-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:62682 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab2K1QNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:13:15 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5327866eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 08:13:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do this in the same way bonding does. This fixed setup resolves performance
issues when using some cards with certain offloading.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index d44cca3..ad86660 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1794,10 +1794,12 @@ static void team_setup(struct net_device *dev)
 
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_GRO;
-	dev->hw_features = NETIF_F_HW_VLAN_TX |
+	dev->hw_features = TEAM_VLAN_FEATURES |
+			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 
+	dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
 	dev->features |= dev->hw_features;
 }
 
-- 
1.7.11.7
