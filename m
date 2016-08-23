From: sthemmin@exchange.microsoft.com
Subject: [PATCH 03/14] hv_netvsc: use kcalloc
Date: Tue, 23 Aug 2016 12:17:46 -0700
Message-ID: <1471979877-17802-3-git-send-email-sthemmin@exchange.microsoft.com>
References: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:41326
        "EHLO p3plsmtps2ded01.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753241AbcHWSH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:07:58 -0400
In-Reply-To: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Better to use kcalloc rather than kzalloc and multiply for an array.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index b15edfc..f64c978 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -421,8 +421,8 @@ static int netvsc_init_buf(struct hv_device *device)
 	net_device->map_words = DIV_ROUND_UP(net_device->send_section_cnt,
 					     BITS_PER_LONG);
 
-	net_device->send_section_map =
-		kzalloc(net_device->map_words * sizeof(ulong), GFP_KERNEL);
+	net_device->send_section_map = kcalloc(net_device->map_words,
+					       sizeof(ulong), GFP_KERNEL);
 	if (net_device->send_section_map == NULL) {
 		ret = -ENOMEM;
 		goto cleanup;
-- 
2.9.3
