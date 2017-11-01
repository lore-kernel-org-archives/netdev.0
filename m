From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: dl2k: remove redundant re-assignment to np
Date: Wed,  1 Nov 2017 08:57:37 +0000
Message-ID: <20171101085737.14967-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Tobias Klauser <tklauser@distanz.ch>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The pointer np is initialized and then re-assigned the same value
a few lines later. Remove the redundant duplicated assignment. Cleans
up clang warning:

drivers/net/ethernet/dlink/dl2k.c:314:25: warning: Value stored to
'np' during its initialization is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/dlink/dl2k.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 778f974e2928..e07301e0b0ad 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -313,7 +313,7 @@ find_miiphy (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int i, phy_found = 0;
-	np = netdev_priv(dev);
+
 	np->phy_addr = 1;
 
 	for (i = 31; i >= 0; i--) {
-- 
2.14.1
