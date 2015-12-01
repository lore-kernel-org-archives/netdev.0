From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/26] net: add info struct for LAG changeupper
Date: Tue,  1 Dec 2015 14:48:46 +0100
Message-ID: <1448977744-17930-9-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33258 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbbLANtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:20 -0500
Received: by wmec201 with SMTP id c201so206175240wme.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:17 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
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
index a55be5b..7ea3e83 100644
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
