From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/7] altera: Remove casts of pointer to same type
Date: Mon, 24 Mar 2014 13:15:34 -0700
Message-ID: <b3437e88a3d02c3ee8b9378b5801471a38cf24c5.1395692043.git.joe@perches.com>
References: <cover.1395692043.git.joe@perches.com>
Cc: nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395692043.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 6006ef2..c70a29e 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -933,7 +933,7 @@ static int tse_change_mtu(struct net_device *dev, int new_mtu)
 static void altera_tse_set_mcfilter(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = (struct altera_tse_mac *)priv->mac_dev;
+	struct altera_tse_mac *mac = priv->mac_dev;
 	int i;
 	struct netdev_hw_addr *ha;
 
@@ -963,7 +963,7 @@ static void altera_tse_set_mcfilter(struct net_device *dev)
 static void altera_tse_set_mcfilterall(struct net_device *dev)
 {
 	struct altera_tse_private *priv = netdev_priv(dev);
-	struct altera_tse_mac *mac = (struct altera_tse_mac *)priv->mac_dev;
+	struct altera_tse_mac *mac = priv->mac_dev;
 	int i;
 
 	/* set the hash filter */
-- 
1.8.1.2.459.gbcd45b4.dirty
