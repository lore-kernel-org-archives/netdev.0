From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/7] net: dsa: use port's cpu_dp when creating a slave
Date: Mon, 16 Oct 2017 11:12:13 -0400
Message-ID: <20171016151219.22023-2-vivien.didelot@savoirfairelinux.com>
References: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When dsa_slave_create is called, the related port already has a CPU port
assigned to it, available in its cpu_dp member. Use it instead of the
unique tree cpu_dp.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45f4ea845c07..c6f4829645bf 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1117,16 +1117,13 @@ int dsa_slave_resume(struct net_device *slave_dev)
 int dsa_slave_create(struct dsa_port *port, const char *name)
 {
 	struct dsa_notifier_register_info rinfo = { };
+	struct dsa_port *cpu_dp = port->cpu_dp;
+	struct net_device *master = cpu_dp->netdev;
 	struct dsa_switch *ds = port->ds;
-	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
-	struct dsa_port *cpu_dp;
 	int ret;
 
-	cpu_dp = ds->dst->cpu_dp;
-	master = cpu_dp->netdev;
-
 	if (!ds->num_tx_queues)
 		ds->num_tx_queues = 1;
 
-- 
2.14.2
