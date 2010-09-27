From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 02/17] net: Add netif_copy_real_num_queues()
 for use by virtual net drivers
Date: Mon, 27 Sep 2010 19:24:49 +0100
Message-ID: <1285611889.2263.292.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51050 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933177Ab0I0SYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:24:53 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sets the active numbers of queues on a net device to match another.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cf3d5a3..7fd39b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1698,6 +1698,18 @@ static inline int netif_set_real_num_rx_queues(struct net_device *dev,
 }
 #endif
 
+static inline int netif_copy_real_num_queues(struct net_device *to_dev,
+					     const struct net_device *from_dev)
+{
+	netif_set_real_num_tx_queues(to_dev, from_dev->real_num_tx_queues);
+#ifdef CONFIG_RPS
+	return netif_set_real_num_rx_queues(to_dev,
+					    from_dev->real_num_rx_queues);
+#else
+	return 0;
+#endif
+}
+
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts
  * disabled.
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

