From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 12:03:51 -0700
Message-ID: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:49434
	"EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965000Ab3DPScA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 14:32:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed: warning: cast from pointer to integer of different size

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f5f0f09..8c03033 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -500,7 +500,7 @@ int netvsc_send(struct hv_device *device,
 	int ret = 0;
 	struct nvsp_message sendMessage;
 	struct net_device *ndev;
-	u64 req_id;
+	ulong req_id;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -522,7 +522,7 @@ int netvsc_send(struct hv_device *device,
 	sendMessage.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
 
 	if (packet->completion.send.send_completion)
-		req_id = (u64)packet;
+		req_id = (ulong)packet;
 	else
 		req_id = 0;
 
-- 
1.7.4.1
