From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/6] cxgb4vf: Combine substrings for 24 messages
Date: Thu, 4 May 2017 22:32:10 +0200
Message-ID: <55a232ef-f7b8-610c-2449-13d68ec3cb7a@users.sourceforge.net>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 21:00:20 +0200

The script "checkpatch.pl" pointed information out like the following.

WARNING: quoted string split across lines

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 113 ++++++++++++---------
 1 file changed, 64 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 4ac9316f3081..9c2690aeb32b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -226,17 +226,20 @@ void t4vf_os_portmod_changed(struct adapter *adapter, int pidx)
 		dev_info(adapter->pdev_dev, "%s: %s port module inserted\n",
 			 dev->name, mod_str[pi->mod_type]);
 	else if (pi->mod_type == FW_PORT_MOD_TYPE_NOTSUPPORTED)
-		dev_info(adapter->pdev_dev, "%s: unsupported optical port "
-			 "module inserted\n", dev->name);
+		dev_info(adapter->pdev_dev,
+			 "%s: unsupported optical port module inserted\n",
+			 dev->name);
 	else if (pi->mod_type == FW_PORT_MOD_TYPE_UNKNOWN)
-		dev_info(adapter->pdev_dev, "%s: unknown port module inserted,"
-			 "forcing TWINAX\n", dev->name);
+		dev_info(adapter->pdev_dev,
+			 "%s: unknown port module inserted,forcing TWINAX\n",
+			 dev->name);
 	else if (pi->mod_type == FW_PORT_MOD_TYPE_ERROR)
 		dev_info(adapter->pdev_dev, "%s: transceiver module error\n",
 			 dev->name);
 	else
-		dev_info(adapter->pdev_dev, "%s: unknown module type %d "
-			 "inserted\n", dev->name, pi->mod_type);
+		dev_info(adapter->pdev_dev,
+			 "%s: unknown module type %d inserted\n",
+			 dev->name, pi->mod_type);
 }
 
 /*
@@ -2357,8 +2360,9 @@ static void size_nports_qsets(struct adapter *adapter)
 	 */
 	adapter->params.nports = vfres->nvi;
 	if (adapter->params.nports > MAX_NPORTS) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d maximum"
-			 " allowed virtual interfaces\n", MAX_NPORTS,
+		dev_warn(adapter->pdev_dev,
+			 "only using %d of %d maximum allowed virtual interfaces\n",
+			 MAX_NPORTS,
 			 adapter->params.nports);
 		adapter->params.nports = MAX_NPORTS;
 	}
@@ -2370,9 +2374,9 @@ static void size_nports_qsets(struct adapter *adapter)
 	 */
 	pmask_nports = hweight32(adapter->params.vfres.pmask);
 	if (pmask_nports < adapter->params.nports) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d provisioned"
-			 " virtual interfaces; limited by Port Access Rights"
-			 " mask %#x\n", pmask_nports, adapter->params.nports,
+		dev_warn(adapter->pdev_dev,
+			 "only using %d of %d provisioned virtual interfaces; limited by Port Access Rights mask %#x\n",
+			 pmask_nports, adapter->params.nports,
 			 adapter->params.vfres.pmask);
 		adapter->params.nports = pmask_nports;
 	}
@@ -2403,8 +2407,8 @@ static void size_nports_qsets(struct adapter *adapter)
 	adapter->sge.max_ethqsets = ethqsets;
 
 	if (adapter->sge.max_ethqsets < adapter->params.nports) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d available"
-			 " virtual interfaces (too few Queue Sets)\n",
+		dev_warn(adapter->pdev_dev,
+			 "only using %d of %d available virtual interfaces (too few Queue Sets)\n",
 			 adapter->sge.max_ethqsets, adapter->params.nports);
 		adapter->params.nports = adapter->sge.max_ethqsets;
 	}
@@ -2448,38 +2452,44 @@ static int adap_init0(struct adapter *adapter)
 	 */
 	err = t4vf_get_dev_params(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to retrieve adapter"
-			" device parameters: err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to retrieve adapter device parameters: err=%d\n",
+			err);
 		return err;
 	}
 	err = t4vf_get_vpd_params(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to retrieve adapter"
-			" VPD parameters: err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to retrieve adapter VPD parameters: err=%d\n",
+			err);
 		return err;
 	}
 	err = t4vf_get_sge_params(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to retrieve adapter"
-			" SGE parameters: err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to retrieve adapter SGE parameters: err=%d\n",
+			err);
 		return err;
 	}
 	err = t4vf_get_rss_glb_config(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to retrieve adapter"
-			" RSS parameters: err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to retrieve adapter RSS parameters: err=%d\n",
+			err);
 		return err;
 	}
 	if (adapter->params.rss.mode !=
 	    FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL) {
-		dev_err(adapter->pdev_dev, "unable to operate with global RSS"
-			" mode %d\n", adapter->params.rss.mode);
+		dev_err(adapter->pdev_dev,
+			"unable to operate with global RSS mode %d\n",
+			adapter->params.rss.mode);
 		return -EINVAL;
 	}
 	err = t4vf_sge_init(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to use adapter parameters:"
-			" err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to use adapter parameters: err=%d\n",
+			err);
 		return err;
 	}
 
@@ -2522,20 +2532,21 @@ static int adap_init0(struct adapter *adapter)
 	 */
 	err = t4vf_get_vfres(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "unable to get virtual interface"
-			" resources: err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"unable to get virtual interface resources: err=%d\n",
+			err);
 		return err;
 	}
 
 	/* Check for various parameter sanity issues */
 	if (adapter->params.vfres.pmask == 0) {
-		dev_err(adapter->pdev_dev, "no port access configured\n"
-			"usable!\n");
+		dev_err(adapter->pdev_dev,
+			"no port access configured/usable!\n");
 		return -EINVAL;
 	}
 	if (adapter->params.vfres.nvi == 0) {
-		dev_err(adapter->pdev_dev, "no virtual interfaces configured/"
-			"usable!\n");
+		dev_err(adapter->pdev_dev,
+			"no virtual interfaces configured/usable!\n");
 		return -EINVAL;
 	}
 
@@ -2726,8 +2737,9 @@ static int enable_msix(struct adapter *adapter)
 
 	nqsets = want - MSIX_EXTRAS;
 	if (nqsets < s->max_ethqsets) {
-		dev_warn(adapter->pdev_dev, "only enough MSI-X vectors"
-			 " for %d Queue Sets\n", nqsets);
+		dev_warn(adapter->pdev_dev,
+			 "only enough MSI-X vectors for %d Queue Sets\n",
+			 nqsets);
 		s->max_ethqsets = nqsets;
 		if (nqsets < s->ethqsets)
 			reduce_ethqs(adapter, nqsets);
@@ -2804,8 +2816,8 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	if (err == 0) {
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
-			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for"
-				" coherent allocations\n");
+			dev_err(&pdev->dev,
+				"unable to obtain 64-bit DMA for coherent allocations\n");
 			goto err_release_regions;
 		}
 		pci_using_dac = 1;
@@ -2866,8 +2878,9 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 	err = t4vf_prep_adapter(adapter);
 	if (err) {
-		dev_err(adapter->pdev_dev, "device didn't become ready:"
-			" err=%d\n", err);
+		dev_err(adapter->pdev_dev,
+			"device didn't become ready: err=%d\n",
+			err);
 		goto err_unmap_bar0;
 	}
 
@@ -2914,8 +2927,9 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		pmask &= ~(1 << port_id);
 		viid = t4vf_alloc_vi(adapter, port_id);
 		if (viid < 0) {
-			dev_err(&pdev->dev, "cannot allocate VI for port %d:"
-				" err=%d\n", port_id, viid);
+			dev_err(&pdev->dev,
+				"cannot allocate VI for port %d: err=%d\n",
+				port_id, viid);
 			err = viid;
 			goto err_free_dev;
 		}
@@ -2978,8 +2992,8 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		err = t4vf_get_vf_mac_acl(adapter, pf, &naddr, mac);
 		if (err) {
 			dev_err(&pdev->dev,
-				"unable to determine MAC ACL address, "
-				"continuing anyway.. (status %d)\n", err);
+				"unable to determine MAC ACL address, continuing anyway.. (status %d)\n",
+				err);
 		} else if (naddr && adapter->params.vfres.nvi == 1) {
 			struct sockaddr addr;
 
@@ -3006,8 +3020,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	else {
 		if (msi == MSI_MSIX) {
 			dev_info(adapter->pdev_dev,
-				 "Unable to use MSI-X Interrupts; falling "
-				 "back to MSI Interrupts\n");
+				 "Unable to use MSI-X Interrupts; falling back to MSI Interrupts\n");
 
 			/* We're going to need a Forwarded Interrupt Queue so
 			 * that may cut into how many Queue Sets we can
@@ -3018,8 +3031,9 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		}
 		err = pci_enable_msi(pdev);
 		if (err) {
-			dev_err(&pdev->dev, "Unable to allocate MSI Interrupts;"
-				" err=%d\n", err);
+			dev_err(&pdev->dev,
+				"Unable to allocate MSI Interrupts; err=%d\n",
+				err);
 			goto err_free_dev;
 		}
 		adapter->flags |= USING_MSI;
@@ -3047,8 +3061,9 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 
 		err = register_netdev(netdev);
 		if (err) {
-			dev_warn(&pdev->dev, "cannot register net device %s,"
-				 " skipping\n", netdev->name);
+			dev_warn(&pdev->dev,
+				 "cannot register net device %s, skipping\n",
+				 netdev->name);
 			continue;
 		}
 
@@ -3067,8 +3082,8 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 			debugfs_create_dir(pci_name(pdev),
 					   cxgb4vf_debugfs_root);
 		if (IS_ERR_OR_NULL(adapter->debugfs_root))
-			dev_warn(&pdev->dev, "could not create debugfs"
-				 " directory");
+			dev_warn(&pdev->dev,
+				 "could not create debugfs directory");
 		else
 			setup_debugfs(adapter);
 	}
-- 
2.12.2
