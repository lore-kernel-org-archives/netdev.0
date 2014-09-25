From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/6] net: dsa: start and stop the PHY state machine
Date: Wed, 24 Sep 2014 17:05:17 -0700
Message-ID: <1411603522-8384-2-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58256 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIYAGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:00 -0400
Received: by mail-pa0-f51.google.com with SMTP id eu11so8062072pac.38
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:05:59 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_slave_open() should start the PHY library state machine for its PHY
interface, and dsa_slave_close() should stop the PHY library state
machine accordingly.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 43c1e4ade689..4392e983abda 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -84,6 +84,9 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
+	if (p->phy)
+		phy_start(p->phy);
+
 	return 0;
 
 clear_allmulti:
@@ -101,6 +104,9 @@ static int dsa_slave_close(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = p->parent->dst->master_netdev;
 
+	if (p->phy)
+		phy_stop(p->phy);
+
 	dev_mc_unsync(master, dev);
 	dev_uc_unsync(master, dev);
 	if (dev->flags & IFF_ALLMULTI)
-- 
1.9.1
