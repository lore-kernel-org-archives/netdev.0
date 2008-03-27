From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1 net-2.6.26] Pass real namespace in net scheduler classifiers.
Date: Thu, 27 Mar 2008 11:06:23 +0300
Message-ID: <1206605183-11617-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:50356 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754390AbYC0IFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 04:05:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/pkt_cls.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index d349c66..1a5942c 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -353,7 +353,7 @@ tcf_match_indev(struct sk_buff *skb, char *indev)
 	if (indev[0]) {
 		if  (!skb->iif)
 			return 0;
-		dev = __dev_get_by_index(&init_net, skb->iif);
+		dev = __dev_get_by_index(dev_net(skb->dev), skb->iif);
 		if (!dev || strcmp(indev, dev->name))
 			return 0;
 	}
-- 
1.5.3.rc5

