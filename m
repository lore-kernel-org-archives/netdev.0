From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/11] net: dsa: qca8k: enable EEE once
Date: Mon, 31 Jul 2017 18:17:11 -0400
Message-ID: <20170731221719.16695-4-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If EEE is queried enabled, qca8k_set_eee calls qca8k_eee_enable_set
twice (because it is already called in qca8k_eee_init). Fix that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index e076ab23d4df..9d6b5d2f7a4a 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -684,12 +684,13 @@ qca8k_set_eee(struct dsa_switch *ds, int port,
 
 	p->eee_enabled = e->eee_enabled;
 
-	if (e->eee_enabled) {
+	if (!p->eee_enabled) {
+		qca8k_eee_enable_set(ds, port, false);
+	} else {
 		p->eee_enabled = qca8k_eee_init(ds, port, phydev);
 		if (!p->eee_enabled)
 			ret = -EOPNOTSUPP;
 	}
-	qca8k_eee_enable_set(ds, port, p->eee_enabled);
 
 	return ret;
 }
-- 
2.13.3
