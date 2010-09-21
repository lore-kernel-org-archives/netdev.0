From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 2/3] caif: Fix function NULL pointer check.
Date: Tue, 21 Sep 2010 23:44:45 +0200
Message-ID: <1285105486-7649-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1285105486-7649-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:49296 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333Ab0IUVox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:44:53 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400AAC9QQ8C70@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:50 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.92]) by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400IWQ9QPI2F1@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:50 +0200 (CEST)
In-reply-to: <1285105486-7649-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Check that receive function pointer is not null before calling it.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 0fd01dd..b99369a 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -173,7 +173,7 @@ static int receive(struct sk_buff *skb, struct net_device *dev,
 	net = dev_net(dev);
 	pkt = cfpkt_fromnative(CAIF_DIR_IN, skb);
 	caifd = caif_get(dev);
-	if (!caifd || !caifd->layer.up || !caifd->layer.up->ctrlcmd)
+	if (!caifd || !caifd->layer.up || !caifd->layer.up->receive)
 		return NET_RX_DROP;
 
 	if (caifd->layer.up->receive(caifd->layer.up, pkt))
-- 
1.6.3.3

