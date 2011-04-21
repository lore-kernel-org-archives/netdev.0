From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: make WARN_ON in dev_disable_lro() useful
Date: Fri, 22 Apr 2011 00:42:15 +0200 (CEST)
Message-ID: <20110421224215.9B8AC13909@rere.qmqm.pl>
References: <20110421224134.GB7888@rere.qmqm.pl>
	<20110412144940.GA26043@rere.qmqm.pl> <20110411202630.C079D13909@rere.qmqm.pl>
        <1302610228.32697.298.camel@lb-tlvb-vladz> <20110412140708.GA21835@rere.qmqm.pl>
        <1302619012.6750.8.camel@lb-tlvb-vladz> <20110412193823.0823213A65@rere.qmqm.pl>
        <1303397531.3685.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:36128 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753658Ab1DUWmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 18:42:16 -0400
In-Reply-To: <20110421224134.GB7888@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3871bf6..3421184 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1315,7 +1315,8 @@ void dev_disable_lro(struct net_device *dev)
 		return;
=20
 	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
-	WARN_ON(dev->features & NETIF_F_LRO);
+	if (unlikely(dev->features & NETIF_F_LRO))
+		netdev_WARN(dev, "failed to disable LRO!\n");
 }
 EXPORT_SYMBOL(dev_disable_lro);
=20
--=20
1.7.2.5

