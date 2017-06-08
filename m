From: <netanel@amazon.com>
Subject: [PATCH net-next 01/13] net: ena: change return value for unsupported features unsupported return value
Date: Fri, 9 Jun 2017 00:46:38 +0300
Message-ID: <1496958410-4220-12-git-send-email-netanel@amazon.com>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:63954 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751843AbdFHVsl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:48:41 -0400
In-Reply-To: <1496958410-4220-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

return -EOPNOTSUPP instead of -EPERM.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c     | 22 +++++++++++-----------
 drivers/net/ethernet/amazon/ena/ena_ethtool.c | 10 +++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 20 ++++++++++----------
 3 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index f5b237e..02752d5 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -494,7 +494,7 @@ static int ena_com_comp_status_to_errno(u8 comp_status)
 	case ENA_ADMIN_RESOURCE_ALLOCATION_FAILURE:
 		return -ENOMEM;
 	case ENA_ADMIN_UNSUPPORTED_OPCODE:
-		return -EPERM;
+		return -EOPNOTSUPP;
 	case ENA_ADMIN_BAD_OPCODE:
 	case ENA_ADMIN_MALFORMED_REQUEST:
 	case ENA_ADMIN_ILLEGAL_PARAMETER:
@@ -786,7 +786,7 @@ static int ena_com_get_feature_ex(struct ena_com_dev *ena_dev,
 
 	if (!ena_com_check_supported_feature_id(ena_dev, feature_id)) {
 		pr_debug("Feature %d isn't supported\n", feature_id);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	memset(&get_cmd, 0x0, sizeof(get_cmd));
@@ -1324,7 +1324,7 @@ int ena_com_set_aenq_config(struct ena_com_dev *ena_dev, u32 groups_flag)
 	if ((get_resp.u.aenq.supported_groups & groups_flag) != groups_flag) {
 		pr_warn("Trying to set unsupported aenq events. supported flag: %x asked flag: %x\n",
 			get_resp.u.aenq.supported_groups, groups_flag);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	memset(&cmd, 0x0, sizeof(cmd));
@@ -1909,7 +1909,7 @@ int ena_com_set_dev_mtu(struct ena_com_dev *ena_dev, int mtu)
 
 	if (!ena_com_check_supported_feature_id(ena_dev, ENA_ADMIN_MTU)) {
 		pr_debug("Feature %d isn't supported\n", ENA_ADMIN_MTU);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	memset(&cmd, 0x0, sizeof(cmd));
@@ -1963,7 +1963,7 @@ int ena_com_set_hash_function(struct ena_com_dev *ena_dev)
 						ENA_ADMIN_RSS_HASH_FUNCTION)) {
 		pr_debug("Feature %d isn't supported\n",
 			 ENA_ADMIN_RSS_HASH_FUNCTION);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	/* Validate hash function is supported */
@@ -1975,7 +1975,7 @@ int ena_com_set_hash_function(struct ena_com_dev *ena_dev)
 	if (get_resp.u.flow_hash_func.supported_func & (1 << rss->hash_func)) {
 		pr_err("Func hash %d isn't supported by device, abort\n",
 		       rss->hash_func);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	memset(&cmd, 0x0, sizeof(cmd));
@@ -2034,7 +2034,7 @@ int ena_com_fill_hash_function(struct ena_com_dev *ena_dev,
 
 	if (!((1 << func) & get_resp.u.flow_hash_func.supported_func)) {
 		pr_err("Flow hash function %d isn't supported\n", func);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	switch (func) {
@@ -2127,7 +2127,7 @@ int ena_com_set_hash_ctrl(struct ena_com_dev *ena_dev)
 						ENA_ADMIN_RSS_HASH_INPUT)) {
 		pr_debug("Feature %d isn't supported\n",
 			 ENA_ADMIN_RSS_HASH_INPUT);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	memset(&cmd, 0x0, sizeof(cmd));
@@ -2208,7 +2208,7 @@ int ena_com_set_default_hash_ctrl(struct ena_com_dev *ena_dev)
 			pr_err("hash control doesn't support all the desire configuration. proto %x supported %x selected %x\n",
 			       i, hash_ctrl->supported_fields[i].fields,
 			       hash_ctrl->selected_fields[i].fields);
-			return -EPERM;
+			return -EOPNOTSUPP;
 		}
 	}
 
@@ -2286,7 +2286,7 @@ int ena_com_indirect_table_set(struct ena_com_dev *ena_dev)
 		    ena_dev, ENA_ADMIN_RSS_REDIRECTION_TABLE_CONFIG)) {
 		pr_debug("Feature %d isn't supported\n",
 			 ENA_ADMIN_RSS_REDIRECTION_TABLE_CONFIG);
-		return -EPERM;
+		return -EOPNOTSUPP;
 	}
 
 	ret = ena_com_ind_tbl_convert_to_device(ena_dev);
@@ -2553,7 +2553,7 @@ int ena_com_init_interrupt_moderation(struct ena_com_dev *ena_dev)
 				 ENA_ADMIN_INTERRUPT_MODERATION);
 
 	if (rc) {
-		if (rc == -EPERM) {
+		if (rc == -EOPNOTSUPP) {
 			pr_debug("Feature %d isn't supported\n",
 				 ENA_ADMIN_INTERRUPT_MODERATION);
 			rc = 0;
diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 3ee55e2..d51a67f 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -539,12 +539,8 @@ static int ena_get_rss_hash(struct ena_com_dev *ena_dev,
 	}
 
 	rc = ena_com_get_hash_ctrl(ena_dev, proto, &hash_fields);
-	if (rc) {
-		/* If device don't have permission, return unsupported */
-		if (rc == -EPERM)
-			rc = -EOPNOTSUPP;
+	if (rc)
 		return rc;
-	}
 
 	cmd->data = ena_flow_hash_to_flow_type(hash_fields);
 
@@ -612,7 +608,7 @@ static int ena_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info)
 		rc = -EOPNOTSUPP;
 	}
 
-	return (rc == -EPERM) ? -EOPNOTSUPP : rc;
+	return rc;
 }
 
 static int ena_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
@@ -638,7 +634,7 @@ static int ena_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
 		rc = -EOPNOTSUPP;
 	}
 
-	return (rc == -EPERM) ? -EOPNOTSUPP : rc;
+	return rc;
 }
 
 static u32 ena_get_rxfh_indir_size(struct net_device *netdev)
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 4f16ed3..8d4f65e 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -1446,7 +1446,7 @@ static int ena_rss_configure(struct ena_adapter *adapter)
 	/* In case the RSS table wasn't initialized by probe */
 	if (!ena_dev->rss.tbl_log_size) {
 		rc = ena_rss_init_default(adapter);
-		if (rc && (rc != -EPERM)) {
+		if (rc && (rc != -EOPNOTSUPP)) {
 			netif_err(adapter, ifup, adapter->netdev,
 				  "Failed to init RSS rc: %d\n", rc);
 			return rc;
@@ -1455,17 +1455,17 @@ static int ena_rss_configure(struct ena_adapter *adapter)
 
 	/* Set indirect table */
 	rc = ena_com_indirect_table_set(ena_dev);
-	if (unlikely(rc && rc != -EPERM))
+	if (unlikely(rc && rc != -EOPNOTSUPP))
 		return rc;
 
 	/* Configure hash function (if supported) */
 	rc = ena_com_set_hash_function(ena_dev);
-	if (unlikely(rc && (rc != -EPERM)))
+	if (unlikely(rc && (rc != -EOPNOTSUPP)))
 		return rc;
 
 	/* Configure hash inputs (if supported) */
 	rc = ena_com_set_hash_ctrl(ena_dev);
-	if (unlikely(rc && (rc != -EPERM)))
+	if (unlikely(rc && (rc != -EOPNOTSUPP)))
 		return rc;
 
 	return 0;
@@ -2144,7 +2144,7 @@ static void ena_config_host_info(struct ena_com_dev *ena_dev)
 
 	rc = ena_com_set_host_attributes(ena_dev);
 	if (rc) {
-		if (rc == -EPERM)
+		if (rc == -EOPNOTSUPP)
 			pr_warn("Cannot set host attributes\n");
 		else
 			pr_err("Cannot set host attributes\n");
@@ -2181,7 +2181,7 @@ static void ena_config_debug_area(struct ena_adapter *adapter)
 
 	rc = ena_com_set_host_attributes(adapter->ena_dev);
 	if (rc) {
-		if (rc == -EPERM)
+		if (rc == -EOPNOTSUPP)
 			netif_warn(adapter, drv, adapter->netdev,
 				   "Cannot set host attributes\n");
 		else
@@ -2886,7 +2886,7 @@ static int ena_rss_init_default(struct ena_adapter *adapter)
 		val = ethtool_rxfh_indir_default(i, adapter->num_queues);
 		rc = ena_com_indirect_table_fill_entry(ena_dev, i,
 						       ENA_IO_RXQ_IDX(val));
-		if (unlikely(rc && (rc != -EPERM))) {
+		if (unlikely(rc && (rc != -EOPNOTSUPP))) {
 			dev_err(dev, "Cannot fill indirect table\n");
 			goto err_fill_indir;
 		}
@@ -2894,13 +2894,13 @@ static int ena_rss_init_default(struct ena_adapter *adapter)
 
 	rc = ena_com_fill_hash_function(ena_dev, ENA_ADMIN_CRC32, NULL,
 					ENA_HASH_KEY_SIZE, 0xFFFFFFFF);
-	if (unlikely(rc && (rc != -EPERM))) {
+	if (unlikely(rc && (rc != -EOPNOTSUPP))) {
 		dev_err(dev, "Cannot fill hash function\n");
 		goto err_fill_indir;
 	}
 
 	rc = ena_com_set_default_hash_ctrl(ena_dev);
-	if (unlikely(rc && (rc != -EPERM))) {
+	if (unlikely(rc && (rc != -EOPNOTSUPP))) {
 		dev_err(dev, "Cannot fill hash control\n");
 		goto err_fill_indir;
 	}
@@ -3114,7 +3114,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_worker_destroy;
 	}
 	rc = ena_rss_init_default(adapter);
-	if (rc && (rc != -EPERM)) {
+	if (rc && (rc != -EOPNOTSUPP)) {
 		dev_err(&pdev->dev, "Cannot init RSS rc: %d\n", rc);
 		goto err_free_msix;
 	}
-- 
2.7.4
