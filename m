From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 2/5] net: dsa: add missing dsa_switch mdiobus remove
Date: Sat, 3 Oct 2015 16:26:00 +0200
Message-ID: <560FE578.8010503@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To prevent memory leakage on unbinding, add missing mdiobus unregister
and free calls.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 12cec40..91918a3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -424,6 +424,8 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	if (ds->hwmon_dev)
 		hwmon_device_unregister(ds->hwmon_dev);
 #endif
+	mdiobus_unregister(ds->slave_mii_bus);
+	mdiobus_free(ds->slave_mii_bus);
 }

 #ifdef CONFIG_PM_SLEEP
-- 
1.9.1
