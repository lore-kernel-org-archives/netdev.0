From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 2/3] net/hyperv: Correct the assignment in netvsc_recv_callback()
Date: Sun,  5 Feb 2012 14:13:09 -0800
Message-ID: <1328479990-1436-2-git-send-email-haiyangz@microsoft.com>
References: <1328479990-1436-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:58211
	"HELO p3plsmtps2ded01-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752002Ab2BEWI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Feb 2012 17:08:58 -0500
In-Reply-To: <1328479990-1436-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first assignment to variable "net" is wrong, but overridden by the
latter assignments. So the bug isn't manifested.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 466c58a..0ae7a1a 100644
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
