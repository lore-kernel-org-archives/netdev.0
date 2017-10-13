From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,3/3] hv_netvsc: Add initialization of tx_table in netvsc_device_add()
Date: Fri, 13 Oct 2017 12:28:05 -0700
Message-ID: <20171013192805.18183-4-haiyangz@exchange.microsoft.com>
References: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

tx_table is part of the private data of kernel net_device. It is only
zero-ed out when allocating net_device.

We may recreate netvsc_device w/o recreating net_device, so the private
netdev data, including tx_table, are not zeroed. It may contain channel
numbers for the older netvsc_device.

This patch adds initialization of tx_table each time we recreate
netvsc_device.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d34cf37e949d..5bb6a20072dd 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1255,6 +1255,9 @@ struct netvsc_device *netvsc_device_add(struct hv_device *device,
 	if (!net_device)
 		return ERR_PTR(-ENOMEM);
 
+	for (i = 0; i < VRSS_SEND_TAB_SIZE; i++)
+		net_device_ctx->tx_table[i] = 0;
+
 	net_device->ring_size = ring_size;
 
 	/* Because the device uses NAPI, all the interrupt batching and
-- 
2.14.1
