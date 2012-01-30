From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 2/5] net/hyperv: Correct the assignment in netvsc_recv_callback()
Date: Mon, 30 Jan 2012 08:33:35 -0800
Message-ID: <1327941218-12547-2-git-send-email-haiyangz@microsoft.com>
References: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first assignment to variable "net" is wrong, but overridden by the
latter assignments. So the bug isn't manifested.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1a1ca6c..af25771 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -267,13 +267,10 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 int netvsc_recv_callback(struct hv_device *device_obj,
 				struct hv_netvsc_packet *packet)
 {
-	struct net_device *net = dev_get_drvdata(&device_obj->device);
+	struct net_device *net;
 	struct sk_buff *skb;
-	struct netvsc_device *net_device;
-
-	net_device = hv_get_drvdata(device_obj);
-	net = net_device->ndev;
 
+	net = ((struct netvsc_device *)hv_get_drvdata(device_obj))->ndev;
 	if (!net) {
 		netdev_err(net, "got receive callback but net device"
 			" not initialized yet\n");
-- 
1.7.7
