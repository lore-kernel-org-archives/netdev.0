From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/26] net: add netif_is_lag_master helper
Date: Tue,  1 Dec 2015 14:48:42 +0100
Message-ID: <1448977744-17930-5-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35145 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbbLANtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:13 -0500
Received: by wmuu63 with SMTP id u63so173625210wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:12 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Some code does not mind if the master is bond or team and treats them
the same, as generic LAG.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7eca8f..b3e96d6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3900,6 +3900,11 @@ static inline bool netif_is_team_port(struct net_device *dev)
 	return dev->priv_flags & IFF_TEAM_PORT;
 }
 
+static inline bool netif_is_lag_master(struct net_device *dev)
+{
+	return netif_is_bond_master(dev) || netif_is_team_master(dev);
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
-- 
1.9.3
