From: Alexander Aring <alex.aring@googlemail.com>
Subject: [PATCH] mac802154: fix NOHZ local_softirq_pending 08 warning
Date: Wed,  2 Jan 2013 12:01:10 +0100
Message-ID: <1357124470-2375-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	mkl@pengutronix.de, davem@davemloft.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:63778 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab3ABLA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 06:00:57 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so6678465eek.6
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 03:00:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using nanosleep() in an userspace application we get a
ratelimit warning

NOHZ: local_softirq_pending 08

for 10 times.

This patch replaces netif_rx() with netif_rx_ni() which has
to be used from process/softirq context.
The process/softirq context will be called from fakelb driver.

See linux-kernel commit 481a819 for similar fix.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/mac802154/wpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 1191039..199b922 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -389,7 +389,7 @@ void mac802154_wpan_setup(struct net_device *dev)
 
 static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
 {
-	return netif_rx(skb);
+	return netif_rx_ni(skb);
 }
 
 static int
-- 
1.8.0.2
