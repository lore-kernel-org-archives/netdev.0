From: sthemmin@exchange.microsoft.com
Subject: [PATCH 06/14] hv_netvsc: use ARRAY_SIZE() for NDIS versions
Date: Tue, 23 Aug 2016 12:29:38 -0700
Message-ID: <1471980586-18263-7-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:41168
        "EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753729AbcHWRy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:54:29 -0400
In-Reply-To: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Don't hard code size of array of NDIS versions.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 4ef2af6..110bbb8 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -577,9 +577,10 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	int ndis_version;
-	u32 ver_list[] = { NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
+	const u32 ver_list[] = {
+		NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5 };
-	int i, num_ver = 4; /* number of different NVSP versions */
+	int i;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -588,7 +589,7 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	init_packet = &net_device->channel_init_pkt;
 
 	/* Negotiate the latest NVSP protocol supported */
-	for (i = num_ver - 1; i >= 0; i--)
+	for (i = ARRAY_SIZE(ver_list) - 1; i >= 0; i--)
 		if (negotiate_nvsp_ver(device, net_device, init_packet,
 				       ver_list[i])  == 0) {
 			net_device->nvsp_version = ver_list[i];
-- 
1.7.4.1
