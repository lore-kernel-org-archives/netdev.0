From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 1/2] net: delete duplicate dev_set_rx_mode() call
Date: Mon, 16 Jun 2014 21:57:22 +0800
Message-ID: <3b4f2d21523f2a03b21d4dc1350327752c634771.1402926490.git.panweiping3@gmail.com>
References: <cover.1402926490.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60119 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbaFPN6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 09:58:20 -0400
Received: by mail-pd0-f169.google.com with SMTP id g10so1838313pdj.14
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 06:58:20 -0700 (PDT)
In-Reply-To: <cover.1402926490.git.panweiping3@gmail.com>
In-Reply-To: <cover.1402926490.git.panweiping3@gmail.com>
References: <cover.1402926490.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __dev_open(), it already calls dev_set_rx_mode().
and dev_set_rx_mode() has no effect for a net device which does not have
IFF_UP flag set.

So the call of dev_set_rx_mode() is duplicate in __dev_change_flags().

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/core/dev.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf6..a04b12f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5432,13 +5432,9 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 	 */
 
 	ret = 0;
-	if ((old_flags ^ flags) & IFF_UP) {	/* Bit is different  ? */
+	if ((old_flags ^ flags) & IFF_UP)
 		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
 
-		if (!ret)
-			dev_set_rx_mode(dev);
-	}
-
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
 		int inc = (flags & IFF_PROMISC) ? 1 : -1;
 		unsigned int old_flags = dev->flags;
-- 
1.9.0
