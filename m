From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Bring back device detaching in dsa_slave_suspend()
Date: Wed, 25 Jan 2017 09:10:41 -0800
Message-ID: <20170125171041.21442-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid
lockdep splat") removed the netif_device_detach() call done in
dsa_slave_suspend() which is necessary, and paired with a corresponding
netif_device_attach(), bring it back.

Fixes: 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid lockdep splat")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David,

Can you also queue this for -stable? Thanks!

 net/dsa/slave.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 68c9eea00518..020a28d5c93e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1203,6 +1203,8 @@ int dsa_slave_suspend(struct net_device *slave_dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 
+	netif_device_detach(slave_dev);
+
 	if (p->phy) {
 		phy_stop(p->phy);
 		p->old_pause = -1;
-- 
2.9.3
