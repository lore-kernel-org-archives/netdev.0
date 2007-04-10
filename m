From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : loopback driver can use loopback_dev integrated
 net_device_stats
Date: Tue, 10 Apr 2007 19:29:12 +0200
Message-ID: <20070410192912.b60e86bf.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rusty Russel <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:36118 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031211AbXDJR3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 13:29:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Please find this patch against net-2.6.22

Thank you

[PATCH] NET : loopback driver can use loopback_dev integrated net_device_stats

Rusty added a new 'stats' field to struct net_device.

loopback driver can use it instead of declaring another struct net_device_stats
This saves some memory.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 6df673a..6ba6ed2 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -164,11 +164,9 @@ #endif
 	return 0;
 }
 
-static struct net_device_stats loopback_stats;
-
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	struct net_device_stats *stats = &loopback_stats;
+	struct net_device_stats *stats = &dev->stats;
 	unsigned long bytes = 0;
 	unsigned long packets = 0;
 	int i;
@@ -208,7 +206,6 @@ static const struct ethtool_ops loopback
 struct net_device loopback_dev = {
 	.name	 		= "lo",
 	.get_stats		= &get_stats,
-	.priv			= &loopback_stats,
 	.mtu			= (16 * 1024) + 20 + 20 + 12,
 	.hard_start_xmit	= loopback_xmit,
 	.hard_header		= eth_header,
