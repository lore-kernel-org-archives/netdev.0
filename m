From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 07/28] net: add netif_is_lag_port helper
Date: Wed,  2 Dec 2015 21:07:30 +0100
Message-ID: <1449086871-19911-8-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38910 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446AbbLBUID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:03 -0500
Received: by wmec201 with SMTP id c201so73924581wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:02 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Some code does not mind if a device is bond slave or team port and treats
them the same, as generic LAG ports.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b3e96d6..85bcd9b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3905,6 +3905,11 @@ static inline bool netif_is_lag_master(struct net_device *dev)
 	return netif_is_bond_master(dev) || netif_is_team_master(dev);
 }
 
+static inline bool netif_is_lag_port(struct net_device *dev)
+{
+	return netif_is_bond_slave(dev) || netif_is_team_port(dev);
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
-- 
1.9.3
