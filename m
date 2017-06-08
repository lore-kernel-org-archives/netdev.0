From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/6] netvsc: mark error cases as unlikely
Date: Thu,  8 Jun 2017 16:21:21 -0700
Message-ID: <20170608232123.28366-5-sthemmin@microsoft.com>
References: <20170608232123.28366-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36246 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbdFHXVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 19:21:38 -0400
Received: by mail-pg0-f43.google.com with SMTP id a70so20575863pge.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 16:21:38 -0700 (PDT)
In-Reply-To: <20170608232123.28366-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark if() statements used for error handling only as unlikely()

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 652453d9fb08..caf89a245ba6 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -855,14 +855,14 @@ int netvsc_send(struct hv_device *device,
 	bool xmit_more = (skb != NULL) ? skb->xmit_more : false;
 
 	net_device = get_outbound_net_device(device);
-	if (!net_device)
+	if (unlikely(!net_device))
 		return -ENODEV;
 
 	/* We may race with netvsc_connect_vsp()/netvsc_init_buf() and get
 	 * here before the negotiation with the host is finished and
 	 * send_section_map may not be allocated yet.
 	 */
-	if (!net_device->send_section_map)
+	if (unlikely(!net_device->send_section_map))
 		return -EAGAIN;
 
 	nvchan = &net_device->chan_table[packet->q_idx];
-- 
2.11.0
