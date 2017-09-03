From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH 7/10] net/mlx4_core: Use ARRAY_SIZE macro
Date: Sun, 03 Sep 2017 14:19:31 +0200
Message-ID: <1504439110050-1961876957-7-diffsplit-thomas@m3y3r.de>
References: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
yourself.
Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
/ARRAY_SIZE(\1)/g' and manual check/verification.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 041c0ed65929..8eca12927be0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -36,6 +36,7 @@
 #include <linux/mlx4/cmd.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/kernel.h>
 
 #include "fw.h"
 #include "icm.h"
@@ -2450,14 +2451,14 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
 	csum_mask = (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MODE_PORT1_BIT_OFFSET) &
 			CONFIG_DEV_RX_CSUM_MODE_MASK;
 
-	if (csum_mask >= sizeof(config_dev_csum_flags)/sizeof(config_dev_csum_flags[0]))
+	if (csum_mask >= ARRAY_SIZE(config_dev_csum_flags))
 		return -EINVAL;
 	params->rx_csum_flags_port_1 = config_dev_csum_flags[csum_mask];
 
 	csum_mask = (config_dev.rx_checksum_val >> CONFIG_DEV_RX_CSUM_MODE_PORT2_BIT_OFFSET) &
 			CONFIG_DEV_RX_CSUM_MODE_MASK;
 
-	if (csum_mask >= sizeof(config_dev_csum_flags)/sizeof(config_dev_csum_flags[0]))
+	if (csum_mask >= ARRAY_SIZE(config_dev_csum_flags))
 		return -EINVAL;
 	params->rx_csum_flags_port_2 = config_dev_csum_flags[csum_mask];
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5fe5cdc51357..fe18650c9342 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -34,6 +34,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/pci.h>
@@ -3658,7 +3659,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 	 * per port, we must limit the number of VFs to 63 (since their are
 	 * 128 MACs)
 	 */
-	for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) && i < num_vfs_argc;
+	for (i = 0; i < ARRAY_SIZE(nvfs) && i < num_vfs_argc;
 	     total_vfs += nvfs[param_map[num_vfs_argc - 1][i]], i++) {
 		nvfs[param_map[num_vfs_argc - 1][i]] = num_vfs[i];
 		if (nvfs[i] < 0) {
@@ -3667,7 +3668,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 			goto err_disable_pdev;
 		}
 	}
-	for (i = 0; i < sizeof(prb_vf)/sizeof(prb_vf[0]) && i < probe_vfs_argc;
+	for (i = 0; i < ARRAY_SIZE(prb_vf) && i < probe_vfs_argc;
 	     i++) {
 		prb_vf[param_map[probe_vfs_argc - 1][i]] = probe_vf[i];
 		if (prb_vf[i] < 0 || prb_vf[i] > nvfs[i]) {
@@ -3746,11 +3747,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 		if (total_vfs) {
 			unsigned vfs_offset = 0;
 
-			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) &&
+			for (i = 0; i < ARRAY_SIZE(nvfs) &&
 			     vfs_offset + nvfs[i] < extended_func_num(pdev);
 			     vfs_offset += nvfs[i], i++)
 				;
-			if (i == sizeof(nvfs)/sizeof(nvfs[0])) {
+			if (i == ARRAY_SIZE(nvfs)) {
 				err = -ENODEV;
 				goto err_release_regions;
 			}
