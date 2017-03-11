From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 12/17] net: dsa: add dsa_is_normal_port helper
Date: Sat, 11 Mar 2017 16:12:58 -0500
Message-ID: <20170311211303.24560-13-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a dsa_is_normal_port helper to check if a given port is a
normal user port as opposed to a CPU port or DSA link.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4e13e695f025..bf0e42c2a6f7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -248,6 +248,11 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 	return !!((ds->dsa_port_mask) & (1 << p));
 }
 
+static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
+{
+	return !dsa_is_cpu_port(ds, p) && !dsa_is_dsa_port(ds, p);
+}
+
 static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 {
 	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
-- 
2.12.0
