From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/2] net: dsa: legacy: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 14:17:30 -0400
Message-ID: <20171023181731.7977-2-vivien.didelot@savoirfairelinux.com>
References: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The legacy code does not unmask the cpu_port_mask and dsa_port_mask as
stated. But this is done on the error path and those masks won't be used
after that. So instead of fixing the bit operation, simply remove it.

Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/legacy.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index b6c88fd33d4f..93c1c43bcc58 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -272,10 +272,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 		dsa_cpu_dsa_destroy(&ds->ports[port]);
-
-		/* Clearing a bit which is not set does no harm */
-		ds->cpu_port_mask |= ~(1 << port);
-		ds->dsa_port_mask |= ~(1 << port);
 	}
 
 	if (ds->slave_mii_bus && ds->ops->phy_read)
-- 
2.14.2
