From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net/ethoc: fix null dereference on error exit path
Date: Sun, 22 May 2016 20:08:18 +0100
Message-ID: <1463944098-7061-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

priv is assigned to NULL however all the error exit paths to label 'free'
dereference priv, causing a null pointer dereference.

Examination of the code shows that all error exits via the 'free'
label path occur before priv is assigned to netdev_priv(netdev), hence
there is no need to call clk_disable_unprepare and so the location of
the label should be moved to free_netdev statement to avoid this null
dereference on priv.

Fixes issue found by CoverityScan, CID#113260

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/ethoc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 41b0106..96403a4 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1241,9 +1241,10 @@ error2:
 error:
 	mdiobus_unregister(priv->mdio);
 	mdiobus_free(priv->mdio);
-free:
+
 	if (priv->clk)
 		clk_disable_unprepare(priv->clk);
+free:
 	free_netdev(netdev);
 out:
 	return ret;
-- 
2.8.1
