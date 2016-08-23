From: sthemmin@exchange.microsoft.com
Subject: [PATCH 07/14] hv_netvsc: make device_remove void
Date: Tue, 23 Aug 2016 12:29:39 -0700
Message-ID: <1471980586-18263-8-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:36788
        "EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753548AbcHWRy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:54:28 -0400
In-Reply-To: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Always returns 0 and no callers check.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 +-
 drivers/net/hyperv/netvsc.c     |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index b58e559..8031dee 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -173,7 +173,7 @@ struct rndis_device {
 struct rndis_message;
 struct netvsc_device;
 int netvsc_device_add(struct hv_device *device, void *additional_info);
-int netvsc_device_remove(struct hv_device *device);
+void netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 110bbb8..2ece27a 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -648,7 +648,7 @@ static void netvsc_disconnect_vsp(struct hv_device *device)
 /*
  * netvsc_device_remove - Callback when the root bus device is removed
  */
-int netvsc_device_remove(struct hv_device *device)
+void netvsc_device_remove(struct hv_device *device)
 {
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
@@ -670,7 +670,6 @@ int netvsc_device_remove(struct hv_device *device)
 	/* Release all resources */
 	vfree(net_device->sub_cb_buf);
 	free_netvsc_device(net_device);
-	return 0;
 }
 
 #define RING_AVAIL_PERCENT_HIWATER 20
-- 
1.7.4.1
