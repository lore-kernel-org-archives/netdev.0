From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: move i40e_vsi_config_rss below i40e_get_rss_aq
Date: Fri, 19 Aug 2016 23:19:37 -0700
Message-ID: <1471673991-117115-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37803 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751546AbcHTGTx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:53 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Move this function below the two functions related to configuring RSS
via the admin queue. This helps co-locate the two functions, and made it
easier to spot a bug in the first i40e_config_rss_aq function as
compared to the i40e_get_rss_aq function.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 54 ++++++++++++++---------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 798c4e2..1692a89 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8028,33 +8028,6 @@ config_rss_aq_out:
 }
 
 /**
- * i40e_vsi_config_rss - Prepare for VSI(VMDq) RSS if used
- * @vsi: VSI structure
- **/
-static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
-{
-	u8 seed[I40E_HKEY_ARRAY_SIZE];
-	struct i40e_pf *pf = vsi->back;
-	u8 *lut;
-	int ret;
-
-	if (!(pf->flags & I40E_FLAG_RSS_AQ_CAPABLE))
-		return 0;
-
-	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
-
-	i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
-	netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
-	vsi->rss_size = min_t(int, pf->alloc_rss_size, vsi->num_queue_pairs);
-	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
-	kfree(lut);
-
-	return ret;
-}
-
-/**
  * i40e_get_rss_aq - Get RSS keys and lut by using AQ commands
  * @vsi: Pointer to vsi structure
  * @seed: Buffter to store the hash keys
@@ -8101,6 +8074,33 @@ static int i40e_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
 }
 
 /**
+ * i40e_vsi_config_rss - Prepare for VSI(VMDq) RSS if used
+ * @vsi: VSI structure
+ **/
+static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
+{
+	u8 seed[I40E_HKEY_ARRAY_SIZE];
+	struct i40e_pf *pf = vsi->back;
+	u8 *lut;
+	int ret;
+
+	if (!(pf->flags & I40E_FLAG_RSS_AQ_CAPABLE))
+		return 0;
+
+	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
+	if (!lut)
+		return -ENOMEM;
+
+	i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
+	netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
+	vsi->rss_size = min_t(int, pf->alloc_rss_size, vsi->num_queue_pairs);
+	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
+	kfree(lut);
+
+	return ret;
+}
+
+/**
  * i40e_config_rss_reg - Configure RSS keys and lut by writing registers
  * @vsi: Pointer to vsi structure
  * @seed: RSS hash seed
-- 
2.7.4
