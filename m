From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 17/17] 8021q: Use netif_copy_real_num_queues()
 to set queue counts
Date: Mon, 27 Sep 2010 19:32:59 +0100
Message-ID: <1285612379.2263.320.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52383 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186Ab0I0SdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:33:03 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers RX if necessary, as well as TX.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/8021q/vlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2c6c2bd..25c2133 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -321,7 +321,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	if (new_dev == NULL)
 		return -ENOBUFS;
 
-	new_dev->real_num_tx_queues = real_dev->real_num_tx_queues;
+	netif_copy_real_num_queues(new_dev, real_dev);
 	dev_net_set(new_dev, net);
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

