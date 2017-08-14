From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/11] net: dsa: legacy: assign dst->applied
Date: Mon, 14 Aug 2017 18:22:32 -0400
Message-ID: <20170814222242.10643-2-vivien.didelot@savoirfairelinux.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "applied" boolean of the dsa_switch_tree is only set in the new
bindings. This patch sets it in the legacy code as well.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/legacy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 91e6f7981d39..a6a0849483d1 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -605,6 +605,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	 */
 	wmb();
 	dev->dsa_ptr = dst;
+	dst->applied = true;
 
 	return 0;
 }
@@ -689,6 +690,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
 
 	dev_put(dst->cpu_dp->netdev);
+
+	dst->applied = false;
 }
 
 static int dsa_remove(struct platform_device *pdev)
-- 
2.14.0
