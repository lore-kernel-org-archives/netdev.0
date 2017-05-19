From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/20] net: dsa: change scope of notifier call chain
Date: Fri, 19 May 2017 17:00:37 -0400
Message-ID: <20170519210055.9366-3-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48302 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932386AbdESVDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 17:03:16 -0400
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the scope of the fabric notification helper from the DSA slave to
the DSA port, since this is a DSA layer specific notion, that can be
used by non-slave ports (CPU and DSA).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 403d1dfe7f50..371f6d267917 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -27,10 +27,9 @@
 
 static bool dsa_slave_dev_check(struct net_device *dev);
 
-static int dsa_slave_notify(struct net_device *dev, unsigned long e, void *v)
+static int dsa_port_notify(struct dsa_port *dp, unsigned long e, void *v)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct raw_notifier_head *nh = &p->dp->ds->dst->nh;
+	struct raw_notifier_head *nh = &dp->ds->dst->nh;
 	int err;
 
 	err = raw_notifier_call_chain(nh, e, v);
@@ -589,7 +588,7 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	 */
 	p->dp->bridge_dev = br;
 
-	err = dsa_slave_notify(dev, DSA_NOTIFIER_BRIDGE_JOIN, &info);
+	err = dsa_port_notify(p->dp, DSA_NOTIFIER_BRIDGE_JOIN, &info);
 
 	/* The bridging is rolled back on error */
 	if (err)
@@ -614,7 +613,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev,
 	 */
 	p->dp->bridge_dev = NULL;
 
-	err = dsa_slave_notify(dev, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
+	err = dsa_port_notify(p->dp, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
 	if (err)
 		netdev_err(dev, "failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
 
-- 
2.13.0
