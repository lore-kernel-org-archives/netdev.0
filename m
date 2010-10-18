From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/3] net: fail alloc_netdev_mq if queue count < 1
Date: Mon, 18 Oct 2010 11:02:07 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010181055300.16090@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:42788 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757609Ab0JRSCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 14:02:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In alloc_netdev_mq fail if requested queue_count < 1.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 04972a4..76db105 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
+	if (queue_count < 0) {
+		printk(KERN_ERR "alloc_netdev: Unable to allocate device "
+		       "with zero queues.\n");
+		return NULL;
+	}
+
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
-- 
1.7.1

