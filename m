From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: remove vmbus_are_subchannels_present() in rndis_filter_device_add()
Date: Thu, 26 Mar 2015 16:20:58 -0700
Message-ID: <1427412058-23712-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vmbus_are_subchannels_present() also involves opening the channels, which
may be too early at this point. Checking for subchannels is not necessary here.
So this patch removes it. Subchannels will be opened when offer messages arrive.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index a2b185a..fdfab1f 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1141,8 +1141,6 @@ int rndis_filter_device_add(struct hv_device *dev,
 	net_device->num_chn = 1 +
 		init_packet->msg.v5_msg.subchn_comp.num_subchannels;
 
-	vmbus_are_subchannels_present(dev->channel);
-
 	ret = rndis_filter_set_rss_param(rndis_device, net_device->num_chn);
 
 out:
-- 
1.7.4.1
