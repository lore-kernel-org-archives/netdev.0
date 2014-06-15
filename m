From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 1/2] net: delete duplicate dev_set_rx_mode() call
Date: Sun, 15 Jun 2014 18:05:09 +0800
Message-ID: <f470381d8e466741c71a38e5ad396c3850d10721.1402826534.git.panweiping3@gmail.com>
References: <cover.1402826534.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55636 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaFOKF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 06:05:59 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so3444804pdi.23
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2014 03:05:59 -0700 (PDT)
In-Reply-To: <cover.1402826534.git.panweiping3@gmail.com>
In-Reply-To: <cover.1402826534.git.panweiping3@gmail.com>
References: <cover.1402826534.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __dev_open(), it already calls dev_set_rx_mode().
and dev_set_rx_mode() has no effect for a net device which does not have
IFF_UP flag set.

So the call of dev_set_rx_mode() is duplicate in __dev_change_flags().

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/core/dev.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf6..002678f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5434,9 +5434,6 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 	ret = 0;
 	if ((old_flags ^ flags) & IFF_UP) {	/* Bit is different  ? */
 		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
-
-		if (!ret)
-			dev_set_rx_mode(dev);
 	}
 
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
-- 
1.9.0
