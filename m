From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 10/28] net: add info struct for LAG changeupper
Date: Thu,  3 Dec 2015 12:12:12 +0100
Message-ID: <1449141150-8172-11-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37457 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759035AbbLCLMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:50 -0500
Received: by wmww144 with SMTP id w144so17301938wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:49 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This struct will be shared by bonding and team to pass internal
information to notifier listeners.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 42b2279..0461f86 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2108,6 +2108,19 @@ struct pcpu_sw_netstats {
 #define netdev_alloc_pcpu_stats(type)					\
 	__netdev_alloc_pcpu_stats(type, GFP_KERNEL);
 
+enum netdev_lag_tx_type {
+	NETDEV_LAG_TX_TYPE_UNKNOWN,
+	NETDEV_LAG_TX_TYPE_RANDOM,
+	NETDEV_LAG_TX_TYPE_BROADCAST,
+	NETDEV_LAG_TX_TYPE_ROUNDROBIN,
+	NETDEV_LAG_TX_TYPE_ACTIVEBACKUP,
+	NETDEV_LAG_TX_TYPE_HASH,
+};
+
+struct netdev_lag_upper_info {
+	enum netdev_lag_tx_type tx_type;
+};
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
-- 
1.9.3
