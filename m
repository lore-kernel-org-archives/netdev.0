From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 1/3] driver net: cpsw: Convert pr_*() to dev_*() calls
Date: Thu, 8 May 2014 15:20:50 +0530
Message-ID: <1399542652-14900-2-git-send-email-george.cherian@ti.com>
References: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>, <tklauser@distanz.ch>,
	George Cherian <george.cherian@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert all pr_*() calls to dev_*() calls.
No functional changes.

Signed-off-by: George Cherian <george.cherian@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 50 +++++++++++++++++++++---------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d14c8da..9512738 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1808,25 +1808,25 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		return -EINVAL;
 
 	if (of_property_read_u32(node, "slaves", &prop)) {
-		pr_err("Missing slaves property in the DT.\n");
+		dev_err(&pdev->dev, "Missing slaves property in the DT.\n");
 		return -EINVAL;
 	}
 	data->slaves = prop;
 
 	if (of_property_read_u32(node, "active_slave", &prop)) {
-		pr_err("Missing active_slave property in the DT.\n");
+		dev_err(&pdev->dev, "Missing active_slave property in the DT.\n");
 		return -EINVAL;
 	}
 	data->active_slave = prop;
 
 	if (of_property_read_u32(node, "cpts_clock_mult", &prop)) {
-		pr_err("Missing cpts_clock_mult property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpts_clock_mult property in the DT.\n");
 		return -EINVAL;
 	}
 	data->cpts_clock_mult = prop;
 
 	if (of_property_read_u32(node, "cpts_clock_shift", &prop)) {
-		pr_err("Missing cpts_clock_shift property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpts_clock_shift property in the DT.\n");
 		return -EINVAL;
 	}
 	data->cpts_clock_shift = prop;
@@ -1838,31 +1838,31 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		return -ENOMEM;
 
 	if (of_property_read_u32(node, "cpdma_channels", &prop)) {
-		pr_err("Missing cpdma_channels property in the DT.\n");
+		dev_err(&pdev->dev, "Missing cpdma_channels property in the DT.\n");
 		return -EINVAL;
 	}
 	data->channels = prop;
 
 	if (of_property_read_u32(node, "ale_entries", &prop)) {
-		pr_err("Missing ale_entries property in the DT.\n");
+		dev_err(&pdev->dev, "Missing ale_entries property in the DT.\n");
 		return -EINVAL;
 	}
 	data->ale_entries = prop;
 
 	if (of_property_read_u32(node, "bd_ram_size", &prop)) {
-		pr_err("Missing bd_ram_size property in the DT.\n");
+		dev_err(&pdev->dev, "Missing bd_ram_size property in the DT.\n");
 		return -EINVAL;
 	}
 	data->bd_ram_size = prop;
 
 	if (of_property_read_u32(node, "rx_descs", &prop)) {
-		pr_err("Missing rx_descs property in the DT.\n");
+		dev_err(&pdev->dev, "Missing rx_descs property in the DT.\n");
 		return -EINVAL;
 	}
 	data->rx_descs = prop;
 
 	if (of_property_read_u32(node, "mac_control", &prop)) {
-		pr_err("Missing mac_control property in the DT.\n");
+		dev_err(&pdev->dev, "Missing mac_control property in the DT.\n");
 		return -EINVAL;
 	}
 	data->mac_control = prop;
@@ -1876,7 +1876,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	ret = of_platform_populate(node, NULL, NULL, &pdev->dev);
 	/* We do not want to force this, as in some cases may not have child */
 	if (ret)
-		pr_warn("Doesn't have any child node\n");
+		dev_warn(&pdev->dev, "Doesn't have any child node\n");
 
 	for_each_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
@@ -1893,7 +1893,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
-			pr_err("Missing slave[%d] phy_id property\n", i);
+			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
 			return -EINVAL;
 		}
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
@@ -1918,18 +1918,18 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
-			pr_err("Missing or malformed slave[%d] phy-mode property\n",
-			       i);
+			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
+				i);
 			return slave_data->phy_if;
 		}
 
 		if (data->dual_emac) {
 			if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
 						 &prop)) {
-				pr_err("Missing dual_emac_res_vlan in DT.\n");
+				dev_err(&pdev->dev, "Missing dual_emac_res_vlan in DT.\n");
 				slave_data->dual_emac_res_vlan = i+1;
-				pr_err("Using %d as Reserved VLAN for %d slave\n",
-				       slave_data->dual_emac_res_vlan, i);
+				dev_err(&pdev->dev, "Using %d as Reserved VLAN for %d slave\n",
+					slave_data->dual_emac_res_vlan, i);
 			} else {
 				slave_data->dual_emac_res_vlan = prop;
 			}
@@ -1953,7 +1953,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
-		pr_err("cpsw: error allocating net_device\n");
+		dev_err(&pdev->dev, "cpsw: error allocating net_device\n");
 		return -ENOMEM;
 	}
 
@@ -1969,10 +1969,10 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
 		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
 			ETH_ALEN);
-		pr_info("cpsw: Detected MACID = %pM\n", priv_sl2->mac_addr);
+		dev_info(&pdev->dev, "cpsw: Detected MACID = %pM\n", priv_sl2->mac_addr);
 	} else {
 		random_ether_addr(priv_sl2->mac_addr);
-		pr_info("cpsw: Random MACID = %pM\n", priv_sl2->mac_addr);
+		dev_info(&pdev->dev, "cpsw: Random MACID = %pM\n", priv_sl2->mac_addr);
 	}
 	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 
@@ -2010,7 +2010,7 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ret = register_netdev(ndev);
 	if (ret) {
-		pr_err("cpsw: error registering net device\n");
+		dev_err(&pdev->dev, "cpsw: error registering net device\n");
 		free_netdev(ndev);
 		ret = -ENODEV;
 	}
@@ -2032,7 +2032,7 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 	if (!ndev) {
-		pr_err("error allocating net_device\n");
+		dev_err(&pdev->dev, "error allocating net_device\n");
 		return -ENOMEM;
 	}
 
@@ -2047,7 +2047,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	priv->cpts = devm_kzalloc(&pdev->dev, sizeof(struct cpts), GFP_KERNEL);
 	priv->irq_enabled = true;
 	if (!priv->cpts) {
-		pr_err("error allocating cpts\n");
+		dev_err(&pdev->dev, "error allocating cpts\n");
 		goto clean_ndev_ret;
 	}
 
@@ -2060,7 +2060,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	pinctrl_pm_select_default_state(&pdev->dev);
 
 	if (cpsw_probe_dt(&priv->data, pdev)) {
-		pr_err("cpsw: platform data missing\n");
+		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
 		goto clean_runtime_disable_ret;
 	}
@@ -2068,10 +2068,10 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	if (is_valid_ether_addr(data->slave_data[0].mac_addr)) {
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
-		pr_info("Detected MACID = %pM\n", priv->mac_addr);
+		dev_info(&pdev->dev, "Detected MACID = %pM\n", priv->mac_addr);
 	} else {
 		eth_random_addr(priv->mac_addr);
-		pr_info("Random MACID = %pM\n", priv->mac_addr);
+		dev_info(&pdev->dev, "Random MACID = %pM\n", priv->mac_addr);
 	}
 
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
-- 
1.8.3.1
