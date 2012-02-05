From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 3/3] net/hyperv: Remove the unnecessary memset in rndis_filter_send()
Date: Sun,  5 Feb 2012 14:13:10 -0800
Message-ID: <1328479990-1436-3-git-send-email-haiyangz@microsoft.com>
References: <1328479990-1436-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net ([208.109.80.58]:58248
	"HELO p3plsmtps2ded01-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753251Ab2BEWJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Feb 2012 17:09:00 -0500
In-Reply-To: <1328479990-1436-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory has been allocated by kzalloc, so it's unnecessary to memset
again.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index a60e5e2..136efd8 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -778,8 +778,6 @@ int rndis_filter_send(struct hv_device *dev,
 	/* Add the rndis header */
 	filter_pkt = (struct rndis_filter_packet *)pkt->extension;
 
-	memset(filter_pkt, 0, sizeof(struct rndis_filter_packet));
-
 	rndis_msg = &filter_pkt->msg;
 	rndis_msg_size = RNDIS_MESSAGE_SIZE(struct rndis_packet);
 
-- 
1.7.7
