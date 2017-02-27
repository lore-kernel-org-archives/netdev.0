From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/5] netvsc: don't overload variable in same function
Date: Mon, 27 Feb 2017 10:26:47 -0800
Message-ID: <20170227182651.3956-2-sthemmin@microsoft.com>
References: <20170227182651.3956-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33188 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdB0S7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:59:05 -0500
Received: by mail-pf0-f177.google.com with SMTP id o64so8286168pfb.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:59:05 -0800 (PST)
In-Reply-To: <20170227182651.3956-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two variables named packet in the same function. One is the
metadata descriptor from host (vmpacket_descriptor) and the other is
the control block in the skb used to hold metadata from send.
Change name to avoid possible confusion and bugs.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d35ebd993b38..5dedbc36c326 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -600,9 +600,9 @@ static inline void netvsc_free_send_slot(struct netvsc_device *net_device,
 static void netvsc_send_tx_complete(struct netvsc_device *net_device,
 				    struct vmbus_channel *incoming_channel,
 				    struct hv_device *device,
-				    struct vmpacket_descriptor *packet)
+				    const struct vmpacket_descriptor *desc)
 {
-	struct sk_buff *skb = (struct sk_buff *)(unsigned long)packet->trans_id;
+	struct sk_buff *skb = (struct sk_buff *)(unsigned long)desc->trans_id;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct vmbus_channel *channel = device->channel;
-- 
2.11.0
