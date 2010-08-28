From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] phonet: use for_each_set_bit
Date: Sat, 28 Aug 2010 14:08:26 +0900
Message-ID: <1282972106-9914-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45962 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab0H1FPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 01:15:17 -0400
Received: by mail-pw0-f46.google.com with SMTP id 7so1423243pwi.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 22:15:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace open-coded loop with for_each_set_bit().

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/phonet/pn_dev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index b18e48f..d0a4294 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -292,8 +292,7 @@ static void phonet_route_autodel(struct net_device *dev)
 	if (bitmap_empty(deleted, 64))
 		return; /* short-circuit RCU */
 	synchronize_rcu();
-	for (i = find_first_bit(deleted, 64); i < 64;
-			i = find_next_bit(deleted, 64, i + 1)) {
+	for_each_set_bit(i, deleted, 64) {
 		rtm_phonet_notify(RTM_DELROUTE, dev, i);
 		dev_put(dev);
 	}
-- 
1.6.0.6

