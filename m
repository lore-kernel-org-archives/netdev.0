From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 5/6] net: dsa: add missing calls in dsa_switch_destroy
Date: Thu, 29 Oct 2015 14:23:25 +0100
Message-ID: <56321DCD.3070702@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing netif_carrier_off and phy_disconnect calls to the
dsa_switch_destroy function to make sure the netdev and phy
ressources are clean before complete removal.

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 597a462..11452e4 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -454,7 +454,9 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!ds->ports[port])
 			continue;

+		netif_carrier_off(ds->ports[port]);
 		unregister_netdev(ds->ports[port]);
+		phy_disconnect(p->phy);
 		free_netdev(ds->ports[port]);
 	}

-- 
1.9.1
