From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,4/6] hyperv: Remove extra allocated space for recv_pkt_list elements
Date: Tue,  2 Oct 2012 08:30:22 -0700
Message-ID: <1349191824-14001-4-git-send-email-haiyangz@microsoft.com>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:46415
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068Ab2JBPLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 11:11:22 -0400
In-Reply-To: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The receive code path doesn't use the page buffer, so remove the
extra allocated space here.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/hyperv_net.h |    2 --
 drivers/net/hyperv/netvsc.c     |    4 +---
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 95ceb35..d58f28c 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -465,8 +465,6 @@ struct nvsp_message {
 
 #define NETVSC_RECEIVE_BUFFER_ID		0xcafe
 
-#define NETVSC_RECEIVE_SG_COUNT			1
-
 /* Preallocated receive packets */
 #define NETVSC_RECEIVE_PACKETLIST_COUNT		256
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4a1a5f5..d9c4c03 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -904,9 +904,7 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	INIT_LIST_HEAD(&net_device->recv_pkt_list);
 
 	for (i = 0; i < NETVSC_RECEIVE_PACKETLIST_COUNT; i++) {
-		packet = kzalloc(sizeof(struct hv_netvsc_packet) +
-				 (NETVSC_RECEIVE_SG_COUNT *
-				  sizeof(struct hv_page_buffer)), GFP_KERNEL);
+		packet = kzalloc(sizeof(struct hv_netvsc_packet), GFP_KERNEL);
 		if (!packet)
 			break;
 
-- 
1.7.4.1
