From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,1/3] hv_netvsc: Clean up two unused variables
Date: Mon,  6 Apr 2015 15:22:52 -0700
Message-ID: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:52561
	"EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbbDFVF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 17:05:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    1 -
 drivers/net/hyperv/netvsc.c       |    1 -
 drivers/net/hyperv/rndis_filter.c |    2 --
 3 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 309adee..95a25e4 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -130,7 +130,6 @@ struct hv_netvsc_packet {
 	u32 status;
 	bool part_of_skb;
 
-	struct hv_device *device;
 	bool is_data_pkt;
 	bool xmit_more; /* from skb */
 	u16 vlan_tci;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index f699236..7e83c6a 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1011,7 +1011,6 @@ static void netvsc_receive(struct netvsc_device *net_device,
 	}
 
 	count = vmxferpage_packet->range_cnt;
-	netvsc_packet->device = device;
 	netvsc_packet->channel = channel;
 
 	/* Each range represents 1 RNDIS pkt that contains 1 ethernet frame */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index a160437..0d92efe 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -47,8 +47,6 @@ struct rndis_request {
 
 	/* Simplify allocation by having a netvsc packet inline */
 	struct hv_netvsc_packet	pkt;
-	/* Set 2 pages for rndis requests crossing page boundary */
-	struct hv_page_buffer buf[2];
 
 	struct rndis_message request_msg;
 	/*
-- 
1.7.4.1
