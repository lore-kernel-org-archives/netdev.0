From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next] hv_netvsc: remove excessive logging on MTU change
Date: Mon, 28 Nov 2016 18:25:44 +0100
Message-ID: <20161128172544.2491-1-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53238 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbcK1RZr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 12:25:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we change MTU or the number of channels on a netvsc device we get the
following logged:

 hv_netvsc bf5edba8...: net device safe to remove
 hv_netvsc: hv_netvsc channel opened successfully
 hv_netvsc bf5edba8...: Send section size: 6144, Section count:2560
 hv_netvsc bf5edba8...: Device MAC 00:15:5d:1e:91:12 link state up

This information is useful as debug at most.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc.c       | 8 ++++----
 drivers/net/hyperv/rndis_filter.c | 6 +++---
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 720b5fa..d85da0d 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -410,8 +410,8 @@ static int netvsc_init_buf(struct hv_device *device)
 	net_device->send_section_cnt =
 		net_device->send_buf_size / net_device->send_section_size;
 
-	dev_info(&device->device, "Send section size: %d, Section count:%d\n",
-		 net_device->send_section_size, net_device->send_section_cnt);
+	netdev_dbg(ndev, "Send section size: %d, Section count:%d\n",
+		   net_device->send_section_size, net_device->send_section_cnt);
 
 	/* Setup state for managing the send buffer. */
 	net_device->map_words = DIV_ROUND_UP(net_device->send_section_cnt,
@@ -578,7 +578,7 @@ void netvsc_device_remove(struct hv_device *device)
 	 * At this point, no one should be accessing net_device
 	 * except in here
 	 */
-	dev_notice(&device->device, "net device safe to remove\n");
+	netdev_dbg(ndev, "net device safe to remove\n");
 
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
@@ -1380,7 +1380,7 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	}
 
 	/* Channel is opened */
-	pr_info("hv_netvsc channel opened successfully\n");
+	netdev_dbg(ndev, "hv_netvsc channel opened successfully\n");
 
 	/* If we're reopening the device we may have multiple queues, fill the
 	 * chn_table with the default channel to use it before subchannels are
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9195d5d..8d90904 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1059,9 +1059,9 @@ int rndis_filter_device_add(struct hv_device *dev,
 
 	device_info->link_state = rndis_device->link_state;
 
-	dev_info(&dev->device, "Device MAC %pM link state %s\n",
-		 rndis_device->hw_mac_adr,
-		 device_info->link_state ? "down" : "up");
+	netdev_dbg(net, "Device MAC %pM link state %s\n",
+		   rndis_device->hw_mac_adr,
+		   device_info->link_state ? "down" : "up");
 
 	if (net_device->nvsp_version < NVSP_PROTOCOL_VERSION_5)
 		return 0;
-- 
2.9.3
