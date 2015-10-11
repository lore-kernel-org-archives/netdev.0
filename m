From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/4] net: dsa: do not warn unsupported bridge ops
Date: Sun, 11 Oct 2015 18:08:37 -0400
Message-ID: <1444601318-20561-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A DSA driver may not provide the port_join_bridge and port_leave_bridge
functions, so don't warn in such case.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bb2bd3b..43d7342 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1276,7 +1276,7 @@ int dsa_slave_netdevice_event(struct notifier_block *unused,
 			goto out;
 
 		err = dsa_slave_master_changed(dev);
-		if (err)
+		if (err && err != -EOPNOTSUPP)
 			netdev_warn(dev, "failed to reflect master change\n");
 
 		break;
-- 
2.6.0
