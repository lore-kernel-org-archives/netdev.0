From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/7] sfc: Reject packets from the kernel TX queue during a
	loopback self-test
Date: Wed, 04 Mar 2009 19:52:37 +0000
Message-ID: <1236196357.3140.17.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:56494 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754396AbZCDTwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:52:41 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is necessary because netif_carrier_off() doesn't stop the queue
immediately.

Ben.

 drivers/net/sfc/tx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index da3e9ff..9f97e44 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -376,6 +376,9 @@ int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
 
+	if (unlikely(efx->port_inhibited))
+		return NETDEV_TX_BUSY;
+
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_queue = &efx->tx_queue[EFX_TX_QUEUE_OFFLOAD_CSUM];
 	else
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

