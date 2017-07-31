From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 02/11] net: dsa: qca8k: fix EEE init
Date: Mon, 31 Jul 2017 18:17:10 -0400
Message-ID: <20170731221719.16695-3-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33576 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdGaWUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 18:20:18 -0400
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qca8k obviously copied code from the sf2 driver as how to set EEE:

    if (e->eee_enabled) {
        p->eee_enabled = qca8k_eee_init(ds, port, phydev);
        if (!p->eee_enabled)
            ret = -EOPNOTSUPP;
    }

But it did not use the same logic for the EEE init routine, which is
"Returns 0 if EEE was not enabled, or 1 otherwise". This results in
returning -EOPNOTSUPP on success and caching EEE enabled on failure.

This patch fixes the returned value of qca8k_eee_init.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index b3bee7eab45f..e076ab23d4df 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -666,11 +666,11 @@ qca8k_eee_init(struct dsa_switch *ds, int port,
 
 	ret = phy_init_eee(phy, 0);
 	if (ret)
-		return ret;
+		return 0;
 
 	qca8k_eee_enable_set(ds, port, true);
 
-	return 0;
+	return 1;
 }
 
 static int
-- 
2.13.3
