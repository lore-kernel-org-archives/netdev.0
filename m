From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/3] net: RPS: Make hardware-accelerated RFS
 conditional on NETIF_F_NTUPLE
Date: Fri, 18 Feb 2011 16:03:30 +0000
Message-ID: <1298045010.2570.8.camel@bwh-desktop>
References: <1298044839.2570.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39082 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831Ab1BRQDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:03:33 -0500
In-Reply-To: <1298044839.2570.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For testing and debugging purposes it is useful to be able to disable
hardware acceleration of RFS without disabling RFS altogether.  Since
this is a similar feature to 'n-tuple' flow steering through the
ethtool API, test the same feature flag that controls that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30c71f9..54aaca6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2607,7 +2607,8 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		int rc;
 
 		/* Should we steer this flow to a different hardware queue? */
-		if (!skb_rx_queue_recorded(skb) || !dev->rx_cpu_rmap)
+		if (!skb_rx_queue_recorded(skb) || !dev->rx_cpu_rmap ||
+		    !(dev->features & NETIF_F_NTUPLE))
 			goto out;
 		rxq_index = cpu_rmap_lookup_index(dev->rx_cpu_rmap, next_cpu);
 		if (rxq_index == skb_get_rx_queue(skb))
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

