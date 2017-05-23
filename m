From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH V3 net 3/3] virtio-net: enable TSO/checksum offloads for Q-in-Q vlans
Date: Tue, 23 May 2017 13:38:43 -0400
Message-ID: <1495561123-1819-4-git-send-email-vyasevic@redhat.com>
References: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Cc: alexander.duyck@gmail.com, makita.toshiaki@lab.ntt.co.jp,
        Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35998 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934436AbdEWRiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 13:38:55 -0400
Received: by mail-qt0-f195.google.com with SMTP id j13so23134487qta.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 10:38:55 -0700 (PDT)
In-Reply-To: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since virtio does not provide it's own ndo_features_check handler,
TSO, and now checksum offload, are disabled for stacked vlans.
Re-enable the support and let the host take care of it.  This
restores/improves Guest-to-Guest performance over Q-in-Q vlans.

Acked-by: Jason Wang <jasowang@redhat.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 665627c..ead7a58 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2020,6 +2020,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
 	.ndo_xdp		= virtnet_xdp,
+	.ndo_features_check	= passthru_features_check,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
-- 
2.7.4
