From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/3 v2] net: fail alloc_netdev_mq if queue count < 1
Date: Mon, 18 Oct 2010 20:55:58 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010182053060.6676@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:61612 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653Ab0JSD4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 23:56:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In alloc_netdev_mq fail if requested queue_count < 1.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 04972a4..f44d29a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
+	if (queue_count < 1) {
+		pr_err("alloc_netdev: Unable to allocate device "
+		       "with zero queues.\n");
+		return NULL;
+	}
+
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
-- 
1.7.1

