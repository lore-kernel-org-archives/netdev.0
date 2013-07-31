From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 10/12] tile: make "tile_net.custom" a proper bool module parameter
Date: Wed, 31 Jul 2013 11:05:04 -0400
Message-ID: <781c9ee56f1f87d91eb691f16fc020f410143f0e.1375283106.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
	<cover.1375283104.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375283104.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/tile/tilegx.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index ebc1b43..6696807 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -256,11 +256,11 @@ static char *network_cpus_string;
 /* The actual cpus in "network_cpus". */
 static struct cpumask network_cpus_map;
 
-/* If "loopify=LINK" was specified, this is "LINK". */
+/* If "tile_net.loopify=LINK" was specified, this is "LINK". */
 static char *loopify_link_name;
 
-/* If "tile_net.custom" was specified, this is non-NULL. */
-static char *custom_str;
+/* If "tile_net.custom" was specified, this is true. */
+static bool custom_flag;
 
 /* If "tile_net.jumbo=NUM" was specified, this is "NUM". */
 static uint jumbo_num;
@@ -323,7 +323,7 @@ MODULE_PARM_DESC(loopify, "name the device to use loop0/1 for ingress/egress");
 /* The "tile_net.custom" argument causes us to ignore the "conventional"
  * classifier metadata, in particular, the "l2_offset".
  */
-module_param_named(custom, custom_str, charp, 0444);
+module_param_named(custom, custom_flag, bool, 0444);
 MODULE_PARM_DESC(custom, "indicates a (heavily) customized classifier");
 
 /* The "tile_net.jumbo" argument causes us to support "jumbo" packets,
@@ -501,7 +501,7 @@ static bool tile_net_handle_packet(int instance, gxio_mpipe_idesc_t *idesc)
 	}
 
 	/* Get the "l2_offset", if allowed. */
-	l2_offset = custom_str ? 0 : gxio_mpipe_idesc_get_l2_offset(idesc);
+	l2_offset = custom_flag ? 0 : gxio_mpipe_idesc_get_l2_offset(idesc);
 
 	/* Get the VA (including NET_IP_ALIGN bytes of "headroom"). */
 	va = tile_io_addr_to_va((unsigned long)(long)idesc->va);
-- 
1.8.3.1
