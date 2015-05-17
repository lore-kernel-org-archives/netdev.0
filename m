From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4/cxgb4vf: function and argument name cleanup
Date: Sun, 17 May 2015 16:15:23 +0530
Message-ID: <1431859523-7423-4-git-send-email-hariprasad@chelsio.com>
References: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11398 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751949AbbEQFcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 01:32:46 -0400
In-Reply-To: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes variable name 'fn' to 'pf' of structure adapter.
A 'fn' usually stands for PCI function which could be a PF or a VF.
However, the use of this particular variable is explicitly limited to PF
only. So, be specific about it in the variable name.

Also corrects arguments passed for fn t4_ofld_eq_free, t4_ctrl_eq_free,
t4_eth_eq_free, t4_iq_free, t4_alloc_vi, t4_fw_hello, t4_wr_mbox and
t4_cfg_pfvf function.

Also renames cxgb4_t4_bar2_sge_qregs to t4_bar2_sge_qregs and renames
the latter function name in cxgb4vf driver to t4vf_bar2_sge_qregs to avoid
conflicts. Also fixes alignment for these function.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 16 ++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 80 +++++++++++-----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 30 ++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 14 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |  4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h | 10 +--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     | 12 ++--
 9 files changed, 86 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 6016f0d..e843968 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -679,7 +679,7 @@ struct adapter {
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
 	unsigned int mbox;
-	unsigned int fn;
+	unsigned int pf;
 	unsigned int flags;
 	enum chip_type chip;
 
@@ -1190,7 +1190,7 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 int t4_prep_adapter(struct adapter *adapter);
 
 enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
-int cxgb4_t4_bar2_sge_qregs(struct adapter *adapter,
+int t4_bar2_sge_qregs(struct adapter *adapter,
 		      unsigned int qid,
 		      enum t4_bar2_qtype qtype,
 		      u64 *pbar2_qoffset,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 3fa3632..7cb4237 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1222,7 +1222,7 @@ static int sensors_show(struct seq_file *seq, void *v)
 	param[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
 		    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_DIAG) |
 		    FW_PARAMS_PARAM_Y_V(FW_PARAM_DEV_DIAG_VDD));
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2,
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2,
 			      param, val);
 
 	if (ret < 0 || val[0] == 0)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 401272a..13d5101 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -250,7 +250,7 @@ static int restart_autoneg(struct net_device *dev)
 		return -EAGAIN;
 	if (p->link_cfg.autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
-	t4_restart_aneg(p->adapter, p->adapter->fn, p->tx_chan);
+	t4_restart_aneg(p->adapter, p->adapter->pf, p->tx_chan);
 	return 0;
 }
 
@@ -267,7 +267,7 @@ static int identify_port(struct net_device *dev,
 	else
 		return -EINVAL;
 
-	return t4_identify_port(adap, adap->fn, netdev2pinfo(dev)->viid, val);
+	return t4_identify_port(adap, adap->pf, netdev2pinfo(dev)->viid, val);
 }
 
 static unsigned int from_fw_linkcaps(enum fw_port_type type, unsigned int caps)
@@ -439,7 +439,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	lc->autoneg = cmd->autoneg;
 
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, p->adapter->fn, p->tx_chan,
+		return t4_link_start(p->adapter, p->adapter->pf, p->tx_chan,
 				     lc);
 	return 0;
 }
@@ -472,7 +472,7 @@ static int set_pauseparam(struct net_device *dev,
 	if (epause->tx_pause)
 		lc->requested_fc |= PAUSE_TX;
 	if (netif_running(dev))
-		return t4_link_start(p->adapter, p->adapter->fn, p->tx_chan,
+		return t4_link_start(p->adapter, p->adapter->pf, p->tx_chan,
 				     lc);
 	return 0;
 }
@@ -617,7 +617,7 @@ static int eeprom_ptov(unsigned int phys_addr, unsigned int fn, unsigned int sz)
  */
 static int eeprom_rd_phys(struct adapter *adap, unsigned int phys_addr, u32 *v)
 {
-	int vaddr = eeprom_ptov(phys_addr, adap->fn, EEPROMPFSIZE);
+	int vaddr = eeprom_ptov(phys_addr, adap->pf, EEPROMPFSIZE);
 
 	if (vaddr >= 0)
 		vaddr = pci_read_vpd(adap->pdev, vaddr, sizeof(u32), v);
@@ -626,7 +626,7 @@ static int eeprom_rd_phys(struct adapter *adap, unsigned int phys_addr, u32 *v)
 
 static int eeprom_wr_phys(struct adapter *adap, unsigned int phys_addr, u32 v)
 {
-	int vaddr = eeprom_ptov(phys_addr, adap->fn, EEPROMPFSIZE);
+	int vaddr = eeprom_ptov(phys_addr, adap->pf, EEPROMPFSIZE);
 
 	if (vaddr >= 0)
 		vaddr = pci_write_vpd(adap->pdev, vaddr, sizeof(u32), &v);
@@ -669,8 +669,8 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	aligned_offset = eeprom->offset & ~3;
 	aligned_len = (eeprom->len + (eeprom->offset & 3) + 3) & ~3;
 
-	if (adapter->fn > 0) {
-		u32 start = 1024 + adapter->fn * EEPROMPFSIZE;
+	if (adapter->pf > 0) {
+		u32 start = 1024 + adapter->pf * EEPROMPFSIZE;
 
 		if (aligned_offset < start ||
 		    aligned_offset + aligned_len > start + EEPROMPFSIZE)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4ec9492..47d20bb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -330,7 +330,7 @@ static void dcb_tx_queue_prio_enable(struct net_device *dev, int enable)
 		 * level") we need to issue the Set Parameters Commannd
 		 * without sleeping (timeout < 0).
 		 */
-		err = t4_set_params_nosleep(adap, adap->mbox, adap->fn, 0, 1,
+		err = t4_set_params_nosleep(adap, adap->mbox, adap->pf, 0, 1,
 					    &name, &value);
 
 		if (err)
@@ -394,7 +394,7 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 	int uc_cnt = netdev_uc_count(dev);
 	int mc_cnt = netdev_mc_count(dev);
 	const struct port_info *pi = netdev_priv(dev);
-	unsigned int mb = pi->adapter->fn;
+	unsigned int mb = pi->adapter->pf;
 
 	/* first do the secondary unicast addresses */
 	netdev_for_each_uc_addr(ha, dev) {
@@ -451,7 +451,7 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 
 	ret = set_addr_filters(dev, sleep_ok);
 	if (ret == 0)
-		ret = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, mtu,
+		ret = t4_set_rxmode(pi->adapter, pi->adapter->pf, pi->viid, mtu,
 				    (dev->flags & IFF_PROMISC) ? 1 : 0,
 				    (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1, -1,
 				    sleep_ok);
@@ -468,7 +468,7 @@ static int link_start(struct net_device *dev)
 {
 	int ret;
 	struct port_info *pi = netdev_priv(dev);
-	unsigned int mb = pi->adapter->fn;
+	unsigned int mb = pi->adapter->pf;
 
 	/*
 	 * We do not set address filters and promiscuity here, the stack does
@@ -886,7 +886,7 @@ int cxgb4_write_rss(const struct port_info *pi, const u16 *queues)
 	for (i = 0; i < pi->rss_size; i++, queues++)
 		rss[i] = rxq[*queues].rspq.abs_id;
 
-	err = t4_config_rss_range(adapter, adapter->fn, pi->viid, 0,
+	err = t4_config_rss_range(adapter, adapter->pf, pi->viid, 0,
 				  pi->rss_size, rss, pi->rss_size);
 	/* If Tunnel All Lookup isn't specified in the global RSS
 	 * Configuration, then we need to specify a default Ingress
@@ -1423,8 +1423,8 @@ int cxgb4_set_rspq_intr_params(struct sge_rspq *q,
 			    FW_PARAMS_PARAM_X_V(
 					FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH) |
 			    FW_PARAMS_PARAM_YZ_V(q->cntxt_id);
-			err = t4_set_params(adap, adap->fn, adap->fn, 0, 1, &v,
-					    &new_idx);
+			err = t4_set_params(adap, adap->mbox, adap->pf, 0, 1,
+					    &v, &new_idx);
 			if (err)
 				return err;
 		}
@@ -1445,7 +1445,7 @@ static int cxgb_set_features(struct net_device *dev, netdev_features_t features)
 	if (!(changed & NETIF_F_HW_VLAN_CTAG_RX))
 		return 0;
 
-	err = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1,
+	err = t4_set_rxmode(pi->adapter, pi->adapter->pf, pi->viid, -1,
 			    -1, -1, -1,
 			    !!(features & NETIF_F_HW_VLAN_CTAG_RX), true);
 	if (unlikely(err))
@@ -2182,7 +2182,7 @@ int cxgb4_bar2_sge_qregs(struct net_device *dev,
 			 u64 *pbar2_qoffset,
 			 unsigned int *pbar2_qid)
 {
-	return cxgb4_t4_bar2_sge_qregs(netdev2adap(dev),
+	return t4_bar2_sge_qregs(netdev2adap(dev),
 				 qid,
 				 (qtype == CXGB4_BAR2_QTYPE_EGRESS
 				  ? T4_BAR2_QTYPE_EGRESS
@@ -2384,7 +2384,7 @@ static void process_db_drop(struct work_struct *work)
 		unsigned int bar2_qid;
 		int ret;
 
-		ret = cxgb4_t4_bar2_sge_qregs(adap, qid, T4_BAR2_QTYPE_EGRESS,
+		ret = t4_bar2_sge_qregs(adap, qid, T4_BAR2_QTYPE_EGRESS,
 					&bar2_qoffset, &bar2_qid);
 		if (ret)
 			dev_err(adap->pdev_dev, "doorbell drop recovery: "
@@ -2427,7 +2427,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	unsigned short i;
 
 	lli.pdev = adap->pdev;
-	lli.pf = adap->fn;
+	lli.pf = adap->pf;
 	lli.l2t = adap->l2t;
 	lli.tids = &adap->tids;
 	lli.ports = adap->port;
@@ -2764,7 +2764,7 @@ static int cxgb_close(struct net_device *dev)
 
 	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
-	return t4_enable_vi(adapter, adapter->fn, pi->viid, false, false);
+	return t4_enable_vi(adapter, adapter->pf, pi->viid, false, false);
 }
 
 /* Return an error number if the indicated filter isn't writable ...
@@ -2967,7 +2967,7 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		} else
 			return -EINVAL;
 
-		mbox = pi->adapter->fn;
+		mbox = pi->adapter->pf;
 		if (cmd == SIOCGMIIREG)
 			ret = t4_mdio_rd(pi->adapter, mbox, prtad, devad,
 					 data->reg_num, &data->val_out);
@@ -2994,7 +2994,7 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (new_mtu < 81 || new_mtu > MAX_MTU)         /* accommodate SACK */
 		return -EINVAL;
-	ret = t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, new_mtu, -1,
+	ret = t4_set_rxmode(pi->adapter, pi->adapter->pf, pi->viid, new_mtu, -1,
 			    -1, -1, -1, true);
 	if (!ret)
 		dev->mtu = new_mtu;
@@ -3010,7 +3010,7 @@ static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	ret = t4_change_mac(pi->adapter, pi->adapter->fn, pi->viid,
+	ret = t4_change_mac(pi->adapter, pi->adapter->pf, pi->viid,
 			    pi->xact_addr_filt, addr->sa_data, true, true);
 	if (ret < 0)
 		return ret;
@@ -3092,7 +3092,7 @@ static u32 t4_read_pcie_cfg4(struct adapter *adap, int reg)
 	ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
 	ldst_cmd.u.pcie.select_naccess = FW_LDST_CMD_NACCESS_V(1);
 	ldst_cmd.u.pcie.ctrl_to_fn =
-		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(adap->fn));
+		(FW_LDST_CMD_LC_F | FW_LDST_CMD_FN_V(adap->pf));
 	ldst_cmd.u.pcie.r = reg;
 	ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd, sizeof(ldst_cmd),
 			 &ldst_cmd);
@@ -3182,7 +3182,7 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	c->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST_F | FW_CMD_READ_F);
 	c->cfvalid_to_len16 = htonl(FW_LEN16(*c));
-	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), c);
+	ret = t4_wr_mbox(adap, adap->mbox, c, sizeof(*c), c);
 	if (ret < 0)
 		return ret;
 
@@ -3198,18 +3198,18 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	}
 	c->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
-	ret = t4_wr_mbox(adap, adap->fn, c, sizeof(*c), NULL);
+	ret = t4_wr_mbox(adap, adap->mbox, c, sizeof(*c), NULL);
 	if (ret < 0)
 		return ret;
 
-	ret = t4_config_glbl_rss(adap, adap->fn,
+	ret = t4_config_glbl_rss(adap, adap->pf,
 				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
 				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F |
 				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F);
 	if (ret < 0)
 		return ret;
 
-	ret = t4_cfg_pfvf(adap, adap->fn, adap->fn, 0, adap->sge.egr_sz, 64,
+	ret = t4_cfg_pfvf(adap, adap->mbox, adap->pf, 0, adap->sge.egr_sz, 64,
 			  MAX_INGQ, 0, 0, 4, 0xf, 0xf, 16, FW_CMD_CAP_PF,
 			  FW_CMD_CAP_PF);
 	if (ret < 0)
@@ -3253,7 +3253,7 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	}
 
 	/* get basic stuff going */
-	return t4_early_init(adap, adap->fn);
+	return t4_early_init(adap, adap->pf);
 }
 
 /*
@@ -3370,7 +3370,7 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 			params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
 			     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CF));
 			ret = t4_query_params(adapter, adapter->mbox,
-					      adapter->fn, 0, 1, params, val);
+					      adapter->pf, 0, 1, params, val);
 			if (ret == 0) {
 				/*
 				 * For t4_memory_rw() below addresses and
@@ -3659,7 +3659,7 @@ static int adap_init0(struct adapter *adap)
 	v =
 	    FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
 	    FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_PORTVEC);
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1, &v, &port_vec);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 1, &v, &port_vec);
 	if (ret < 0)
 		goto bye;
 
@@ -3682,7 +3682,7 @@ static int adap_init0(struct adapter *adap)
 		 */
 		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
 			     FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CF));
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 1,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 1,
 				      params, val);
 
 		/* If the firmware doesn't support Configuration Files,
@@ -3741,7 +3741,7 @@ static int adap_init0(struct adapter *adap)
 	params[3] = FW_PARAM_PFVF(FILTER_START);
 	params[4] = FW_PARAM_PFVF(FILTER_END);
 	params[5] = FW_PARAM_PFVF(IQFLINT_START);
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 6, params, val);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 6, params, val);
 	if (ret < 0)
 		goto bye;
 	adap->sge.egr_start = val[0];
@@ -3759,7 +3759,7 @@ static int adap_init0(struct adapter *adap)
 	 */
 	params[0] = FW_PARAM_PFVF(EQ_END);
 	params[1] = FW_PARAM_PFVF(IQFLINT_END);
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2, params, val);
 	if (ret < 0)
 		goto bye;
 	adap->sge.egr_sz = val[0] - adap->sge.egr_start + 1;
@@ -3807,7 +3807,7 @@ static int adap_init0(struct adapter *adap)
 
 	params[0] = FW_PARAM_PFVF(CLIP_START);
 	params[1] = FW_PARAM_PFVF(CLIP_END);
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2, params, val);
 	if (ret < 0)
 		goto bye;
 	adap->clipt_start = val[0];
@@ -3816,7 +3816,7 @@ static int adap_init0(struct adapter *adap)
 	/* query params related to active filter region */
 	params[0] = FW_PARAM_PFVF(ACTIVE_FILTER_START);
 	params[1] = FW_PARAM_PFVF(ACTIVE_FILTER_END);
-	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2, params, val);
 	/* If Active filter size is set we enable establishing
 	 * offload connection through firmware work request
 	 */
@@ -3833,7 +3833,7 @@ static int adap_init0(struct adapter *adap)
 	 */
 	params[0] = FW_PARAM_PFVF(CPLFW4MSG_ENCAP);
 	val[0] = 1;
-	(void) t4_set_params(adap, adap->mbox, adap->fn, 0, 1, params, val);
+	(void)t4_set_params(adap, adap->mbox, adap->pf, 0, 1, params, val);
 
 	/*
 	 * Find out whether we're allowed to use the T5+ ULPTX MEMWRITE DSGL
@@ -3845,7 +3845,7 @@ static int adap_init0(struct adapter *adap)
 		adap->params.ulptx_memwrite_dsgl = false;
 	} else {
 		params[0] = FW_PARAM_DEV(ULPTX_MEMWRITE_DSGL);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0,
 				      1, params, val);
 		adap->params.ulptx_memwrite_dsgl = (ret == 0 && val[0] != 0);
 	}
@@ -3871,7 +3871,7 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(TDDP_START);
 		params[4] = FW_PARAM_PFVF(TDDP_END);
 		params[5] = FW_PARAM_DEV(FLOWC_BUFFIFO_SZ);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 6,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 6,
 				      params, val);
 		if (ret < 0)
 			goto bye;
@@ -3909,7 +3909,7 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(RQ_END);
 		params[4] = FW_PARAM_PFVF(PBL_START);
 		params[5] = FW_PARAM_PFVF(PBL_END);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 6,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 6,
 				      params, val);
 		if (ret < 0)
 			goto bye;
@@ -3926,7 +3926,7 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(CQ_END);
 		params[4] = FW_PARAM_PFVF(OCQ_START);
 		params[5] = FW_PARAM_PFVF(OCQ_END);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 6, params,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 6, params,
 				      val);
 		if (ret < 0)
 			goto bye;
@@ -3939,7 +3939,7 @@ static int adap_init0(struct adapter *adap)
 
 		params[0] = FW_PARAM_DEV(MAXORDIRD_QP);
 		params[1] = FW_PARAM_DEV(MAXIRD_ADAPTER);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2, params,
 				      val);
 		if (ret < 0) {
 			adap->params.max_ordird_qp = 8;
@@ -3957,7 +3957,7 @@ static int adap_init0(struct adapter *adap)
 	if (caps_cmd.iscsicaps) {
 		params[0] = FW_PARAM_PFVF(ISCSI_START);
 		params[1] = FW_PARAM_PFVF(ISCSI_END);
-		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2,
+		ret = t4_query_params(adap, adap->mbox, adap->pf, 0, 2,
 				      params, val);
 		if (ret < 0)
 			goto bye;
@@ -4085,7 +4085,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 
 	if (t4_wait_dev_ready(adap->regs) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
-	if (t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, NULL) < 0)
+	if (t4_fw_hello(adap, adap->mbox, adap->pf, MASTER_MUST, NULL) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
 	adap->flags |= FW_OK;
 	if (adap_init1(adap, &c))
@@ -4094,7 +4094,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 	for_each_port(adap, i) {
 		struct port_info *p = adap2pinfo(adap, i);
 
-		ret = t4_alloc_vi(adap, adap->fn, p->tx_chan, adap->fn, 0, 1,
+		ret = t4_alloc_vi(adap, adap->mbox, p->tx_chan, adap->pf, 0, 1,
 				  NULL, NULL);
 		if (ret < 0)
 			return PCI_ERS_RESULT_DISCONNECT;
@@ -4470,7 +4470,7 @@ static void free_some_resources(struct adapter *adapter)
 			free_netdev(adapter->port[i]);
 		}
 	if (adapter->flags & FW_OK)
-		t4_fw_bye(adapter, adapter->fn);
+		t4_fw_bye(adapter, adapter->pf);
 }
 
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
@@ -4561,7 +4561,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
 	adapter->mbox = func;
-	adapter->fn = func;
+	adapter->pf = func;
 	adapter->msg_enable = dflt_msg_enable;
 	memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
 
@@ -4581,7 +4581,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!is_t4(adapter->params.chip)) {
 		s_qpp = (QUEUESPERPAGEPF0_S +
 			(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) *
-			adapter->fn);
+			adapter->pf);
 		qpp = 1 << QUEUESPERPAGEPF0_G(t4_read_reg(adapter,
 		      SGE_EGRESS_QUEUES_PER_PAGE_PF_A) >> s_qpp);
 		num_seg = PAGE_SIZE / SEGMENT_SIZE;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 9871165..6122358 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1263,7 +1263,7 @@ out_free:	dev_kfree_skb_any(skb);
 
 	cpl->ctrl0 = htonl(TXPKT_OPCODE_V(CPL_TX_PKT_XT) |
 			   TXPKT_INTF_V(pi->tx_chan) |
-			   TXPKT_PF_V(adap->fn));
+			   TXPKT_PF_V(adap->pf));
 	cpl->pack = htons(0);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
@@ -2739,7 +2739,7 @@ static void __iomem *bar2_address(struct adapter *adapter,
 	u64 bar2_qoffset;
 	int ret;
 
-	ret = cxgb4_t4_bar2_sge_qregs(adapter, qid, qtype,
+	ret = t4_bar2_sge_qregs(adapter, qid, qtype,
 				&bar2_qoffset, pbar2_qid);
 	if (ret)
 		return NULL;
@@ -2770,7 +2770,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_IQ_CMD_PFN_V(adap->fn) | FW_IQ_CMD_VFN_V(0));
+			    FW_IQ_CMD_PFN_V(adap->pf) | FW_IQ_CMD_VFN_V(0));
 	c.alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC_F | FW_IQ_CMD_IQSTART_F |
 				 FW_LEN16(c));
 	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(FW_IQ_TYPE_FL_INT_CAP) |
@@ -2822,7 +2822,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		c.fl0addr = cpu_to_be64(fl->addr);
 	}
 
-	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), &c);
 	if (ret)
 		goto err;
 
@@ -2890,7 +2890,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 					     CONMCTXT_CNGCHMAP_V(1 << (i << 2));
 			}
 		}
-		ret = t4_set_params(adap, adap->mbox, adap->fn, 0, 1,
+		ret = t4_set_params(adap, adap->mbox, adap->pf, 0, 1,
 				    &param, &val);
 		if (ret)
 			dev_warn(adap->pdev_dev, "Failed to set Congestion"
@@ -2955,7 +2955,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_ETH_CMD_PFN_V(adap->fn) |
+			    FW_EQ_ETH_CMD_PFN_V(adap->pf) |
 			    FW_EQ_ETH_CMD_VFN_V(0));
 	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC_F |
 				 FW_EQ_ETH_CMD_EQSTART_F | FW_LEN16(c));
@@ -2972,7 +2972,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 		      FW_EQ_ETH_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), &c);
 	if (ret) {
 		kfree(txq->q.sdesc);
 		txq->q.sdesc = NULL;
@@ -3010,7 +3010,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_CTRL_CMD_PFN_V(adap->fn) |
+			    FW_EQ_CTRL_CMD_PFN_V(adap->pf) |
 			    FW_EQ_CTRL_CMD_VFN_V(0));
 	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_ALLOC_F |
 				 FW_EQ_CTRL_CMD_EQSTART_F | FW_LEN16(c));
@@ -3027,7 +3027,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 		      FW_EQ_CTRL_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), &c);
 	if (ret) {
 		dma_free_coherent(adap->pdev_dev,
 				  nentries * sizeof(struct tx_desc),
@@ -3065,7 +3065,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_OFLD_CMD_PFN_V(adap->fn) |
+			    FW_EQ_OFLD_CMD_PFN_V(adap->pf) |
 			    FW_EQ_OFLD_CMD_VFN_V(0));
 	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC_F |
 				 FW_EQ_OFLD_CMD_EQSTART_F | FW_LEN16(c));
@@ -3080,7 +3080,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 		      FW_EQ_OFLD_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
-	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
+	ret = t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), &c);
 	if (ret) {
 		kfree(txq->q.sdesc);
 		txq->q.sdesc = NULL;
@@ -3119,7 +3119,7 @@ static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 	unsigned int fl_id = fl ? fl->cntxt_id : 0xffff;
 
 	adap->sge.ingr_map[rq->cntxt_id - adap->sge.ingr_start] = NULL;
-	t4_iq_free(adap, adap->fn, adap->fn, 0, FW_IQ_TYPE_FL_INT_CAP,
+	t4_iq_free(adap, adap->mbox, adap->pf, 0, FW_IQ_TYPE_FL_INT_CAP,
 		   rq->cntxt_id, fl_id, 0xffff);
 	dma_free_coherent(adap->pdev_dev, (rq->size + 1) * rq->iqe_len,
 			  rq->desc, rq->phys_addr);
@@ -3174,7 +3174,7 @@ void t4_free_sge_resources(struct adapter *adap)
 			free_rspq_fl(adap, &eq->rspq,
 				     eq->fl.size ? &eq->fl : NULL);
 		if (etq->q.desc) {
-			t4_eth_eq_free(adap, adap->fn, adap->fn, 0,
+			t4_eth_eq_free(adap, adap->mbox, adap->pf, 0,
 				       etq->q.cntxt_id);
 			free_tx_desc(adap, &etq->q, etq->q.in_use, true);
 			kfree(etq->q.sdesc);
@@ -3193,7 +3193,7 @@ void t4_free_sge_resources(struct adapter *adap)
 
 		if (q->q.desc) {
 			tasklet_kill(&q->qresume_tsk);
-			t4_ofld_eq_free(adap, adap->fn, adap->fn, 0,
+			t4_ofld_eq_free(adap, adap->mbox, adap->pf, 0,
 					q->q.cntxt_id);
 			free_tx_desc(adap, &q->q, q->q.in_use, false);
 			kfree(q->q.sdesc);
@@ -3208,7 +3208,7 @@ void t4_free_sge_resources(struct adapter *adap)
 
 		if (cq->q.desc) {
 			tasklet_kill(&cq->qresume_tsk);
-			t4_ctrl_eq_free(adap, adap->fn, adap->fn, 0,
+			t4_ctrl_eq_free(adap, adap->mbox, adap->pf, 0,
 					cq->q.cntxt_id);
 			__skb_queue_purge(&cq->sendq);
 			free_txq(adap, &cq->q);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c626252..e23ca39 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -150,7 +150,7 @@ void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
  */
 void t4_hw_pci_read_cfg4(struct adapter *adap, int reg, u32 *val)
 {
-	u32 req = ENABLE_F | FUNCTION_V(adap->fn) | REGISTER_V(reg);
+	u32 req = ENABLE_F | FUNCTION_V(adap->pf) | REGISTER_V(reg);
 
 	if (is_t4(adap->params.chip))
 		req |= LOCALCFG_F;
@@ -514,7 +514,7 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	mem_base = PCIEOFST_G(mem_reg) << PCIEOFST_SHIFT_X;
 	if (is_t4(adap->params.chip))
 		mem_base -= adap->t4_bar0;
-	win_pf = is_t4(adap->params.chip) ? 0 : PFNUM_V(adap->fn);
+	win_pf = is_t4(adap->params.chip) ? 0 : PFNUM_V(adap->pf);
 
 	/* Calculate our initial PCI-E Memory Window Position and Offset into
 	 * that Window.
@@ -2051,7 +2051,7 @@ int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op)
 	c.op_to_vfn =
 		cpu_to_be32(FW_CMD_OP_V(FW_PARAMS_CMD) |
 			    FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-			    FW_PARAMS_CMD_PFN_V(adap->fn) |
+			    FW_PARAMS_CMD_PFN_V(adap->pf) |
 			    FW_PARAMS_CMD_VFN_V(0));
 	c.retval_len16 = cpu_to_be32(FW_LEN16(c));
 	c.param[0].mnem =
@@ -5123,7 +5123,7 @@ int t4_prep_adapter(struct adapter *adapter)
 }
 
 /**
- *	cxgb4_t4_bar2_sge_qregs - return BAR2 SGE Queue register information
+ *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
  *	@adapter: the adapter
  *	@qid: the Queue ID
  *	@qtype: the Ingress or Egress type for @qid
@@ -5147,7 +5147,7 @@ int t4_prep_adapter(struct adapter *adapter)
  *	Write Combining Doorbell Buffer. If the BAR2 Queue ID is not 0,
  *	then these "Inferred Queue ID" register may not be used.
  */
-int cxgb4_t4_bar2_sge_qregs(struct adapter *adapter,
+int t4_bar2_sge_qregs(struct adapter *adapter,
 		      unsigned int qid,
 		      enum t4_bar2_qtype qtype,
 		      u64 *pbar2_qoffset,
@@ -5280,13 +5280,13 @@ int t4_init_sge_params(struct adapter *adapter)
 	 */
 	hps = t4_read_reg(adapter, SGE_HOST_PAGE_SIZE_A);
 	s_hps = (HOSTPAGESIZEPF0_S +
-		 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * adapter->fn);
+		 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * adapter->pf);
 	sge_params->hps = ((hps >> s_hps) & HOSTPAGESIZEPF0_M);
 
 	/* Extract the SGE Egress and Ingess Queues Per Page for our PF.
 	 */
 	s_qpp = (QUEUESPERPAGEPF0_S +
-		(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * adapter->fn);
+		(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * adapter->pf);
 	qpp = t4_read_reg(adapter, SGE_EGRESS_QUEUES_PER_PAGE_PF_A);
 	sge_params->eq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_M);
 	qpp = t4_read_reg(adapter, SGE_INGRESS_QUEUES_PER_PAGE_PF_A);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 2e41d15..be4ab09 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2162,8 +2162,8 @@ static void __iomem *bar2_address(struct adapter *adapter,
 	u64 bar2_qoffset;
 	int ret;
 
-	ret = t4_bar2_sge_qregs(adapter, qid, qtype,
-				&bar2_qoffset, pbar2_qid);
+	ret = t4vf_bar2_sge_qregs(adapter, qid, qtype,
+				  &bar2_qoffset, pbar2_qid);
 	if (ret)
 		return NULL;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index b9debb4..75df259 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -284,11 +284,11 @@ int t4vf_fw_reset(struct adapter *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
 enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
-int t4_bar2_sge_qregs(struct adapter *adapter,
-		      unsigned int qid,
-		      enum t4_bar2_qtype qtype,
-		      u64 *pbar2_qoffset,
-		      unsigned int *pbar2_qid);
+int t4vf_bar2_sge_qregs(struct adapter *adapter,
+			unsigned int qid,
+			enum t4_bar2_qtype qtype,
+			u64 *pbar2_qoffset,
+			unsigned int *pbar2_qid);
 
 int t4vf_get_sge_params(struct adapter *);
 int t4vf_get_vpd_params(struct adapter *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 966ee90..135909e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -428,7 +428,7 @@ int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
 }
 
 /**
- *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
+ *	t4vf_bar2_sge_qregs - return BAR2 SGE Queue register information
  *	@adapter: the adapter
  *	@qid: the Queue ID
  *	@qtype: the Ingress or Egress type for @qid
@@ -452,11 +452,11 @@ int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
  *	Write Combining Doorbell Buffer. If the BAR2 Queue ID is not 0,
  *	then these "Inferred Queue ID" register may not be used.
  */
-int t4_bar2_sge_qregs(struct adapter *adapter,
-		      unsigned int qid,
-		      enum t4_bar2_qtype qtype,
-		      u64 *pbar2_qoffset,
-		      unsigned int *pbar2_qid)
+int t4vf_bar2_sge_qregs(struct adapter *adapter,
+			unsigned int qid,
+			enum t4_bar2_qtype qtype,
+			u64 *pbar2_qoffset,
+			unsigned int *pbar2_qid)
 {
 	unsigned int page_shift, page_size, qpp_shift, qpp_mask;
 	u64 bar2_page_offset, bar2_qoffset;
-- 
2.3.4
