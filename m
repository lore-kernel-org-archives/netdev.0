From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: remove dsa_port_is_bridged
Date: Fri, 26 May 2017 18:12:42 -0400
Message-ID: <20170526221242.14875-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49266 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948793AbdEZWOu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 18:14:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The helper is only used once and makes the code more complicated that it
should. Remove it and reorganize the variables so that it fits on 80
columns.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 887e26695519..0442b6bf52fa 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -69,18 +69,13 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 	return p->dp->ds->dst->master_netdev->ifindex;
 }
 
-static inline bool dsa_port_is_bridged(struct dsa_port *dp)
-{
-	return !!dp->bridge_dev;
-}
-
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = p->dp->ds->dst->master_netdev;
-	struct dsa_switch *ds = p->dp->ds;
-	u8 stp_state = dsa_port_is_bridged(p->dp) ?
-			BR_STATE_BLOCKING : BR_STATE_FORWARDING;
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch *ds = dp->ds;
+	struct net_device *master = ds->dst->master_netdev;
+	u8 stp_state = dp->bridge_dev ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	if (!(master->flags & IFF_UP))
-- 
2.13.0
