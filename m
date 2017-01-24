From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 09/18] netvsc: remove unused variables
Date: Tue, 24 Jan 2017 13:06:06 -0800
Message-ID: <20170124210615.18628-10-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33502 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so52570302pfb.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:26 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes set but never used warnings

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   | 4 ----
 drivers/net/hyperv/rndis_filter.c | 3 ---
 2 files changed, 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 86feab3f5443..f96b44eee270 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1390,7 +1390,6 @@ static int netvsc_vf_down(struct net_device *vf_netdev)
 static int netvsc_unregister_vf(struct net_device *vf_netdev)
 {
 	struct net_device *ndev;
-	struct netvsc_device *netvsc_dev;
 	struct net_device_context *net_device_ctx;
 
 	ndev = get_netvsc_byref(vf_netdev);
@@ -1398,7 +1397,6 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 		return NOTIFY_DONE;
 
 	net_device_ctx = netdev_priv(ndev);
-	netvsc_dev = net_device_ctx->nvdev;
 
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 
@@ -1507,7 +1505,6 @@ static int netvsc_remove(struct hv_device *dev)
 {
 	struct net_device *net;
 	struct net_device_context *ndev_ctx;
-	struct netvsc_device *net_device;
 
 	net = hv_get_drvdata(dev);
 
@@ -1517,7 +1514,6 @@ static int netvsc_remove(struct hv_device *dev)
 	}
 
 	ndev_ctx = netdev_priv(net);
-	net_device = ndev_ctx->nvdev;
 
 	/* Avoid racing with netvsc_change_mtu()/netvsc_set_channels()
 	 * removing the device.
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 8d2b078403de..fc98d2a16ddd 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -845,7 +845,6 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	struct rndis_request *request;
 	struct rndis_set_request *set;
 	struct rndis_set_complete *set_complete;
-	u32 status;
 	int ret;
 
 	request = get_rndis_request(dev, RNDIS_MSG_SET,
@@ -872,8 +871,6 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	wait_for_completion(&request->wait_event);
 
 	set_complete = &request->response_msg.msg.set_complete;
-	status = set_complete->status;
-
 cleanup:
 	if (request)
 		put_rndis_request(dev, request);
-- 
2.11.0
