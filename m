From: sthemmin@exchange.microsoft.com
Subject: [PATCH 08/14] hv_netvsc: init completion during alloc
Date: Tue, 23 Aug 2016 12:17:51 -0700
Message-ID: <1471979877-17802-8-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:38664
        "EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754480AbcHWSJG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:09:06 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Move initialization to allocate where other fields are initialized.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2ece27a..27eb507 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -164,6 +164,7 @@ static struct netvsc_device *alloc_net_device(void)
 	atomic_set(&net_device->open_cnt, 0);
 	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
 	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
+	init_completion(&net_device->channel_init_wait);
 
 	return net_device;
 }
@@ -1442,9 +1443,6 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 
 	net_device->ring_size = ring_size;
 
-	/* Initialize the NetVSC channel extension */
-	init_completion(&net_device->channel_init_wait);
-
 	set_per_channel_state(device->channel, net_device->cb_buffer);
 
 	/* Open the channel */
-- 
2.9.3
