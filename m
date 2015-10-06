From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 2/5] net: dsa: add missing dsa_switch mdiobus remove
Date: Tue, 6 Oct 2015 15:40:25 +0100
Message-ID: <5613DD59.2000602@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
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
and unallocation calls.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index ed9d43f..14fac4e 100644
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
