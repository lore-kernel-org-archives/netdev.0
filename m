From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 27/33] net: tile - set name assign type
Date: Thu, 10 Jul 2014 10:17:32 +0200
Message-ID: <1404980258-30853-28-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Chris Metcalf <cmetcalf@tilera.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name is obtained from the 'hardware', so consider it predictable.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c  |  7 ++++---
 drivers/net/ethernet/tile/tilepro.c | 13 +++++++------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 69557a2..42a6cb4 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2188,7 +2188,8 @@ static void tile_net_setup(struct net_device *dev)
 /* Allocate the device structure, register the device, and obtain the
  * MAC address from the hypervisor.
  */
-static void tile_net_dev_init(const char *name, const uint8_t *mac)
+static void tile_net_dev_init(const char *name, unsigned char name_assign_type,
+			      const uint8_t *mac)
 {
 	int ret;
 	struct net_device *dev;
@@ -2201,7 +2202,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	/* Allocate the device structure.  Normally, "name" is a
 	 * template, instantiated by register_netdev(), but not for us.
 	 */
-	dev = alloc_netdev_mqs(sizeof(*priv), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev_mqs(sizeof(*priv), name, name_assign_type,
 			       tile_net_setup, NR_CPUS, 1);
 	if (!dev) {
 		pr_err("alloc_netdev_mqs(%s) failed\n", name);
@@ -2270,7 +2271,7 @@ static int __init tile_net_init_module(void)
 
 	/* Find out what devices we have, and initialize them. */
 	for (i = 0; gxio_mpipe_link_enumerate_mac(i, name, mac) >= 0; i++)
-		tile_net_dev_init(name, mac);
+		tile_net_dev_init(name, NET_NAME_PREDICTABLE, mac);
 
 	if (!network_cpus_init())
 		network_cpus_map = *cpu_online_mask;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 88c7121..73d1e45 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2281,7 +2281,8 @@ static void tile_net_setup(struct net_device *dev)
  * Allocate the device structure, register the device, and obtain the
  * MAC address from the hypervisor.
  */
-static struct net_device *tile_net_dev_init(const char *name)
+static struct net_device *tile_net_dev_init(const char *name,
+					    unsigned char name_assign_type)
 {
 	int ret;
 	struct net_device *dev;
@@ -2292,7 +2293,7 @@ static struct net_device *tile_net_dev_init(const char *name)
 	 * tile_net_setup(), and saves "name".  Normally, "name" is a
 	 * template, instantiated by register_netdev(), but not for us.
 	 */
-	dev = alloc_netdev(sizeof(*priv), name, NET_NAME_UNKNOWN,
+	dev = alloc_netdev(sizeof(*priv), name, name_assign_type,
 			   tile_net_setup);
 	if (!dev) {
 		pr_err("alloc_netdev(%s) failed\n", name);
@@ -2372,10 +2373,10 @@ static int tile_net_init_module(void)
 {
 	pr_info("Tilera Network Driver\n");
 
-	tile_net_devs[0] = tile_net_dev_init("xgbe0");
-	tile_net_devs[1] = tile_net_dev_init("xgbe1");
-	tile_net_devs[2] = tile_net_dev_init("gbe0");
-	tile_net_devs[3] = tile_net_dev_init("gbe1");
+	tile_net_devs[0] = tile_net_dev_init("xgbe0", NET_NAME_PREDICTABLE);
+	tile_net_devs[1] = tile_net_dev_init("xgbe1", NET_NAME_PREDICTABLE);
+	tile_net_devs[2] = tile_net_dev_init("gbe0", NET_NAME_PREDICTABLE);
+	tile_net_devs[3] = tile_net_dev_init("gbe1", NET_NAME_PREDICTABLE);
 
 	return 0;
 }
-- 
1.9.3
