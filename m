From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,2/2] hyperv: Add error handling to rndis_filter_device_add()
Date: Wed, 25 Jul 2012 11:08:42 -0700
Message-ID: <1343239722-21328-2-git-send-email-haiyangz@microsoft.com>
References: <1343239722-21328-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:37940
	"HELO p3plsmtps2ded02-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751399Ab2GYRxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 13:53:49 -0400
In-Reply-To: <1343239722-21328-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index fbf5394..e5d6146 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -804,18 +804,15 @@ int rndis_filter_device_add(struct hv_device *dev,
 	/* Send the rndis initialization message */
 	ret = rndis_filter_init_device(rndis_device);
 	if (ret != 0) {
-		/*
-		 * TODO: If rndis init failed, we will need to shut down the
-		 * channel
-		 */
+		rndis_filter_device_remove(dev);
+		return ret;
 	}
 
 	/* Get the mac address */
 	ret = rndis_filter_query_device_mac(rndis_device);
 	if (ret != 0) {
-		/*
-		 * TODO: shutdown rndis device and the channel
-		 */
+		rndis_filter_device_remove(dev);
+		return ret;
 	}
 
 	memcpy(device_info->mac_adr, rndis_device->hw_mac_adr, ETH_ALEN);
-- 
1.7.4.1
