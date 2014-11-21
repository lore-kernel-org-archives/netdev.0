From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 5/5] RDMA/cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related to PCIE, RSS and FW
Date: Fri, 21 Nov 2014 12:52:05 +0530
Message-ID: <1416554525-11844-6-git-send-email-hariprasad@chelsio.com>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveen-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416554525-11844-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch cleanups all PCIE, RSS & FW related macros/register defines that are
defined in t4fw_api.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/provider.c             |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   56 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   68 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  227 ++++++++++++++------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   16 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   52 +++---
 drivers/scsi/csiostor/csio_hw.c                    |   18 +-
 drivers/scsi/csiostor/csio_init.c                  |    8 +-
 drivers/scsi/csiostor/csio_mb.c                    |    2 +-
 10 files changed, 282 insertions(+), 181 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 72e3b69..66bd6a2 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -408,10 +408,10 @@ static ssize_t show_fw_ver(struct device *dev, struct device_attribute *attr,
 	PDBG("%s dev 0x%p\n", __func__, dev);
 
 	return sprintf(buf, "%u.%u.%u.%u\n",
-			FW_HDR_FW_VER_MAJOR_GET(c4iw_dev->rdev.lldi.fw_vers),
-			FW_HDR_FW_VER_MINOR_GET(c4iw_dev->rdev.lldi.fw_vers),
-			FW_HDR_FW_VER_MICRO_GET(c4iw_dev->rdev.lldi.fw_vers),
-			FW_HDR_FW_VER_BUILD_GET(c4iw_dev->rdev.lldi.fw_vers));
+			FW_HDR_FW_VER_MAJOR_G(c4iw_dev->rdev.lldi.fw_vers),
+			FW_HDR_FW_VER_MINOR_G(c4iw_dev->rdev.lldi.fw_vers),
+			FW_HDR_FW_VER_MICRO_G(c4iw_dev->rdev.lldi.fw_vers),
+			FW_HDR_FW_VER_BUILD_G(c4iw_dev->rdev.lldi.fw_vers));
 }
 
 static ssize_t show_hca(struct device *dev, struct device_attribute *attr,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index a2196bc..e8b09bb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -318,10 +318,10 @@ struct adapter_params {
 #include "t4fw_api.h"
 
 #define FW_VERSION(chip) ( \
-		FW_HDR_FW_VER_MAJOR_GET(chip##FW_VERSION_MAJOR) | \
-		FW_HDR_FW_VER_MINOR_GET(chip##FW_VERSION_MINOR) | \
-		FW_HDR_FW_VER_MICRO_GET(chip##FW_VERSION_MICRO) | \
-		FW_HDR_FW_VER_BUILD_GET(chip##FW_VERSION_BUILD))
+		FW_HDR_FW_VER_MAJOR_G(chip##FW_VERSION_MAJOR) | \
+		FW_HDR_FW_VER_MINOR_G(chip##FW_VERSION_MINOR) | \
+		FW_HDR_FW_VER_MICRO_G(chip##FW_VERSION_MICRO) | \
+		FW_HDR_FW_VER_BUILD_G(chip##FW_VERSION_BUILD))
 #define FW_INTFVER(chip, intf) (FW_HDR_INTFVER_##intf)
 
 struct fw_info {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4c663cc..a576da1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1616,14 +1616,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	if (adapter->params.fw_vers)
 		snprintf(info->fw_version, sizeof(info->fw_version),
 			"%u.%u.%u.%u, TP %u.%u.%u.%u",
-			FW_HDR_FW_VER_MAJOR_GET(adapter->params.fw_vers),
-			FW_HDR_FW_VER_MINOR_GET(adapter->params.fw_vers),
-			FW_HDR_FW_VER_MICRO_GET(adapter->params.fw_vers),
-			FW_HDR_FW_VER_BUILD_GET(adapter->params.fw_vers),
-			FW_HDR_FW_VER_MAJOR_GET(adapter->params.tp_vers),
-			FW_HDR_FW_VER_MINOR_GET(adapter->params.tp_vers),
-			FW_HDR_FW_VER_MICRO_GET(adapter->params.tp_vers),
-			FW_HDR_FW_VER_BUILD_GET(adapter->params.tp_vers));
+			FW_HDR_FW_VER_MAJOR_G(adapter->params.fw_vers),
+			FW_HDR_FW_VER_MINOR_G(adapter->params.fw_vers),
+			FW_HDR_FW_VER_MICRO_G(adapter->params.fw_vers),
+			FW_HDR_FW_VER_BUILD_G(adapter->params.fw_vers),
+			FW_HDR_FW_VER_MAJOR_G(adapter->params.tp_vers),
+			FW_HDR_FW_VER_MINOR_G(adapter->params.tp_vers),
+			FW_HDR_FW_VER_MICRO_G(adapter->params.tp_vers),
+			FW_HDR_FW_VER_BUILD_G(adapter->params.tp_vers));
 }
 
 static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -2935,7 +2935,7 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 	int ret;
 	const struct firmware *fw;
 	struct adapter *adap = netdev2adap(netdev);
-	unsigned int mbox = FW_PCIE_FW_MASTER_MASK + 1;
+	unsigned int mbox = PCIE_FW_MASTER_M + 1;
 
 	ef->data[sizeof(ef->data) - 1] = '\0';
 	ret = request_firmware(&fw, ef->data, adap->pdev_dev);
@@ -3046,45 +3046,45 @@ static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 		info->data = 0;
 		switch (info->flow_type) {
 		case TCP_V4_FLOW:
-			if (v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN)
+			if (v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST |
 					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
-			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		case UDP_V4_FLOW:
-			if ((v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN) &&
-			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN))
+			if ((v & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F) &&
+			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN_F))
 				info->data = RXH_IP_SRC | RXH_IP_DST |
 					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
-			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		case SCTP_V4_FLOW:
 		case AH_ESP_V4_FLOW:
 		case IPV4_FLOW:
-			if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN)
+			if (v & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		case TCP_V6_FLOW:
-			if (v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN)
+			if (v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST |
 					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
-			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		case UDP_V6_FLOW:
-			if ((v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN) &&
-			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN))
+			if ((v & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F) &&
+			    (v & FW_RSS_VI_CONFIG_CMD_UDPEN_F))
 				info->data = RXH_IP_SRC | RXH_IP_DST |
 					     RXH_L4_B_0_1 | RXH_L4_B_2_3;
-			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+			else if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		case SCTP_V6_FLOW:
 		case AH_ESP_V6_FLOW:
 		case IPV6_FLOW:
-			if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN)
+			if (v & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F)
 				info->data = RXH_IP_SRC | RXH_IP_DST;
 			break;
 		}
@@ -3420,7 +3420,7 @@ int cxgb4_clip_get(const struct net_device *dev,
 	memset(&c, 0, sizeof(c));
 	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
 			FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
-	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_ALLOC | FW_LEN16(c));
+	c.alloc_to_len16 = htonl(FW_CLIP_CMD_ALLOC_F | FW_LEN16(c));
 	c.ip_hi = *(__be64 *)(lip->s6_addr);
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
@@ -3437,7 +3437,7 @@ int cxgb4_clip_release(const struct net_device *dev,
 	memset(&c, 0, sizeof(c));
 	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
 			FW_CMD_REQUEST_F | FW_CMD_READ_F);
-	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_FREE | FW_LEN16(c));
+	c.alloc_to_len16 = htonl(FW_CLIP_CMD_FREE_F | FW_LEN16(c));
 	c.ip_hi = *(__be64 *)(lip->s6_addr);
 	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
@@ -4988,8 +4988,8 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 
 	ret = t4_config_glbl_rss(adap, adap->fn,
 				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
-				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN |
-				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP);
+				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F |
+				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F);
 	if (ret < 0)
 		return ret;
 
@@ -5365,10 +5365,10 @@ static int adap_init0_no_config(struct adapter *adapter, int reset)
 	adapter->flags |= RSS_TNLALLLOOKUP;
 	ret = t4_config_glbl_rss(adapter, adapter->mbox,
 				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
-				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN |
-				 FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ |
+				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F |
+				 FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_F |
 				 ((adapter->flags & RSS_TNLALLLOOKUP) ?
-					FW_RSS_GLB_CONFIG_CMD_TNLALLLKP : 0));
+					FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F : 0));
 	if (ret < 0)
 		goto bye;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 20432e2..7975d26 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -188,9 +188,9 @@ static void t4_report_fw_error(struct adapter *adap)
 	u32 pcie_fw;
 
 	pcie_fw = t4_read_reg(adap, MA_PCIE_FW);
-	if (pcie_fw & FW_PCIE_FW_ERR)
+	if (pcie_fw & PCIE_FW_ERR)
 		dev_err(adap->pdev_dev, "Firmware reports adapter error: %s\n",
-			reason[FW_PCIE_FW_EVAL_GET(pcie_fw)]);
+			reason[PCIE_FW_EVAL_G(pcie_fw)]);
 }
 
 /*
@@ -993,10 +993,10 @@ static int should_install_fs_fw(struct adapter *adap, int card_fw_usable,
 install:
 	dev_err(adap->pdev_dev, "firmware on card (%u.%u.%u.%u) is %s, "
 		"installing firmware %u.%u.%u.%u on card.\n",
-		FW_HDR_FW_VER_MAJOR_GET(c), FW_HDR_FW_VER_MINOR_GET(c),
-		FW_HDR_FW_VER_MICRO_GET(c), FW_HDR_FW_VER_BUILD_GET(c), reason,
-		FW_HDR_FW_VER_MAJOR_GET(k), FW_HDR_FW_VER_MINOR_GET(k),
-		FW_HDR_FW_VER_MICRO_GET(k), FW_HDR_FW_VER_BUILD_GET(k));
+		FW_HDR_FW_VER_MAJOR_G(c), FW_HDR_FW_VER_MINOR_G(c),
+		FW_HDR_FW_VER_MICRO_G(c), FW_HDR_FW_VER_BUILD_G(c), reason,
+		FW_HDR_FW_VER_MAJOR_G(k), FW_HDR_FW_VER_MINOR_G(k),
+		FW_HDR_FW_VER_MICRO_G(k), FW_HDR_FW_VER_BUILD_G(k));
 
 	return 1;
 }
@@ -1068,12 +1068,12 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 			"driver compiled with %d.%d.%d.%d, "
 			"card has %d.%d.%d.%d, filesystem has %d.%d.%d.%d\n",
 			state,
-			FW_HDR_FW_VER_MAJOR_GET(d), FW_HDR_FW_VER_MINOR_GET(d),
-			FW_HDR_FW_VER_MICRO_GET(d), FW_HDR_FW_VER_BUILD_GET(d),
-			FW_HDR_FW_VER_MAJOR_GET(c), FW_HDR_FW_VER_MINOR_GET(c),
-			FW_HDR_FW_VER_MICRO_GET(c), FW_HDR_FW_VER_BUILD_GET(c),
-			FW_HDR_FW_VER_MAJOR_GET(k), FW_HDR_FW_VER_MINOR_GET(k),
-			FW_HDR_FW_VER_MICRO_GET(k), FW_HDR_FW_VER_BUILD_GET(k));
+			FW_HDR_FW_VER_MAJOR_G(d), FW_HDR_FW_VER_MINOR_G(d),
+			FW_HDR_FW_VER_MICRO_G(d), FW_HDR_FW_VER_BUILD_G(d),
+			FW_HDR_FW_VER_MAJOR_G(c), FW_HDR_FW_VER_MINOR_G(c),
+			FW_HDR_FW_VER_MICRO_G(c), FW_HDR_FW_VER_BUILD_G(c),
+			FW_HDR_FW_VER_MAJOR_G(k), FW_HDR_FW_VER_MINOR_G(k),
+			FW_HDR_FW_VER_MICRO_G(k), FW_HDR_FW_VER_BUILD_G(k));
 		ret = EINVAL;
 		goto bye;
 	}
@@ -1564,7 +1564,7 @@ static void cim_intr_handler(struct adapter *adapter)
 
 	int fat;
 
-	if (t4_read_reg(adapter, MA_PCIE_FW) & FW_PCIE_FW_ERR)
+	if (t4_read_reg(adapter, MA_PCIE_FW) & PCIE_FW_ERR)
 		t4_report_fw_error(adapter);
 
 	fat = t4_handle_intr_status(adapter, CIM_HOST_INT_CAUSE,
@@ -2074,7 +2074,7 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.op_to_viid = htonl(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
 			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-			       FW_RSS_IND_TBL_CMD_VIID(viid));
+			       FW_RSS_IND_TBL_CMD_VIID_V(viid));
 	cmd.retval_len16 = htonl(FW_LEN16(cmd));
 
 	/* each fw_rss_ind_tbl_cmd takes up to 32 entries */
@@ -2091,13 +2091,13 @@ int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
 		while (nq > 0) {
 			unsigned int v;
 
-			v = FW_RSS_IND_TBL_CMD_IQ0(*rsp);
+			v = FW_RSS_IND_TBL_CMD_IQ0_V(*rsp);
 			if (++rsp >= rsp_end)
 				rsp = rspq;
-			v |= FW_RSS_IND_TBL_CMD_IQ1(*rsp);
+			v |= FW_RSS_IND_TBL_CMD_IQ1_V(*rsp);
 			if (++rsp >= rsp_end)
 				rsp = rspq;
-			v |= FW_RSS_IND_TBL_CMD_IQ2(*rsp);
+			v |= FW_RSS_IND_TBL_CMD_IQ2_V(*rsp);
 			if (++rsp >= rsp_end)
 				rsp = rspq;
 
@@ -2131,10 +2131,10 @@ int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
 			      FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	c.retval_len16 = htonl(FW_LEN16(c));
 	if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL) {
-		c.u.manual.mode_pkd = htonl(FW_RSS_GLB_CONFIG_CMD_MODE(mode));
+		c.u.manual.mode_pkd = htonl(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
 	} else if (mode == FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL) {
 		c.u.basicvirtual.mode_pkd =
-			htonl(FW_RSS_GLB_CONFIG_CMD_MODE(mode));
+			htonl(FW_RSS_GLB_CONFIG_CMD_MODE_V(mode));
 		c.u.basicvirtual.synmapen_to_hashtoeplitz = htonl(flags);
 	} else
 		return -EINVAL;
@@ -2793,7 +2793,7 @@ retry:
 	if (ret < 0) {
 		if ((ret == -EBUSY || ret == -ETIMEDOUT) && retries-- > 0)
 			goto retry;
-		if (t4_read_reg(adap, MA_PCIE_FW) & FW_PCIE_FW_ERR)
+		if (t4_read_reg(adap, MA_PCIE_FW) & PCIE_FW_ERR)
 			t4_report_fw_error(adap);
 		return ret;
 	}
@@ -2818,7 +2818,7 @@ retry:
 	 * and we wouldn't want to fail pointlessly.  (This can happen when an
 	 * OS loads lots of different drivers rapidly at the same time).  In
 	 * this case, the Master PF returned by the firmware will be
-	 * FW_PCIE_FW_MASTER_MASK so the test below will work ...
+	 * PCIE_FW_MASTER_M so the test below will work ...
 	 */
 	if ((v & (FW_HELLO_CMD_ERR_F|FW_HELLO_CMD_INIT_F)) == 0 &&
 	    master_mbox != mbox) {
@@ -2844,7 +2844,7 @@ retry:
 			 * our retries ...
 			 */
 			pcie_fw = t4_read_reg(adap, MA_PCIE_FW);
-			if (!(pcie_fw & (FW_PCIE_FW_ERR|FW_PCIE_FW_INIT))) {
+			if (!(pcie_fw & (PCIE_FW_ERR|PCIE_FW_INIT))) {
 				if (waiting <= 0) {
 					if (retries-- > 0)
 						goto retry;
@@ -2859,9 +2859,9 @@ retry:
 			 * report errors preferentially.
 			 */
 			if (state) {
-				if (pcie_fw & FW_PCIE_FW_ERR)
+				if (pcie_fw & PCIE_FW_ERR)
 					*state = DEV_STATE_ERR;
-				else if (pcie_fw & FW_PCIE_FW_INIT)
+				else if (pcie_fw & PCIE_FW_INIT)
 					*state = DEV_STATE_INIT;
 			}
 
@@ -2870,9 +2870,9 @@ retry:
 			 * there's not a valid Master PF, grab its identity
 			 * for our caller.
 			 */
-			if (master_mbox == FW_PCIE_FW_MASTER_MASK &&
-			    (pcie_fw & FW_PCIE_FW_MASTER_VLD))
-				master_mbox = FW_PCIE_FW_MASTER_GET(pcie_fw);
+			if (master_mbox == PCIE_FW_MASTER_M &&
+			    (pcie_fw & PCIE_FW_MASTER_VLD))
+				master_mbox = PCIE_FW_MASTER_G(pcie_fw);
 			break;
 		}
 	}
@@ -2940,7 +2940,7 @@ int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset)
  *	Issues a RESET command to firmware (if desired) with a HALT indication
  *	and then puts the microprocessor into RESET state.  The RESET command
  *	will only be issued if a legitimate mailbox is provided (mbox <=
- *	FW_PCIE_FW_MASTER_MASK).
+ *	PCIE_FW_MASTER_M).
  *
  *	This is generally used in order for the host to safely manipulate the
  *	adapter without fear of conflicting with whatever the firmware might
@@ -2955,7 +2955,7 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 	 * If a legitimate mailbox is provided, issue a RESET command
 	 * with a HALT indication.
 	 */
-	if (mbox <= FW_PCIE_FW_MASTER_MASK) {
+	if (mbox <= PCIE_FW_MASTER_M) {
 		struct fw_reset_cmd c;
 
 		memset(&c, 0, sizeof(c));
@@ -2980,8 +2980,8 @@ static int t4_fw_halt(struct adapter *adap, unsigned int mbox, int force)
 	 */
 	if (ret == 0 || force) {
 		t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, UPCRST);
-		t4_set_reg_field(adap, PCIE_FW, FW_PCIE_FW_HALT,
-				 FW_PCIE_FW_HALT);
+		t4_set_reg_field(adap, PCIE_FW, PCIE_FW_HALT_F,
+				 PCIE_FW_HALT_F);
 	}
 
 	/*
@@ -3020,7 +3020,7 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 		 * doing it automatically, we need to clear the PCIE_FW.HALT
 		 * bit.
 		 */
-		t4_set_reg_field(adap, PCIE_FW, FW_PCIE_FW_HALT, 0);
+		t4_set_reg_field(adap, PCIE_FW, PCIE_FW_HALT_F, 0);
 
 		/*
 		 * If we've been given a valid mailbox, first try to get the
@@ -3029,7 +3029,7 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 		 * valid mailbox or the RESET command failed, fall back to
 		 * hitting the chip with a hammer.
 		 */
-		if (mbox <= FW_PCIE_FW_MASTER_MASK) {
+		if (mbox <= PCIE_FW_MASTER_M) {
 			t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, 0);
 			msleep(100);
 			if (t4_fw_reset(adap, mbox,
@@ -3044,7 +3044,7 @@ static int t4_fw_restart(struct adapter *adap, unsigned int mbox, int reset)
 
 		t4_set_reg_field(adap, CIM_BOOT_CFG, UPCRST, 0);
 		for (ms = 0; ms < FW_CMD_MAX_TIMEOUT; ) {
-			if (!(t4_read_reg(adap, PCIE_FW) & FW_PCIE_FW_HALT))
+			if (!(t4_read_reg(adap, PCIE_FW) & PCIE_FW_HALT_F))
 				return 0;
 			msleep(100);
 			ms += 100;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 4c8eb87..beaf80a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -613,7 +613,6 @@ struct fw_ofld_tx_data_wr {
 
 struct fw_cmd_wr {
 	__be32 op_dma;
-#define FW_CMD_WR_DMA (1U << 17)
 	__be32 len16_pkd;
 	__be64 cookie_daddr;
 };
@@ -2644,11 +2643,6 @@ struct fw_port_stats_cmd {
 	} u;
 };
 
-#define FW_PORT_STATS_CMD_NSTATS(x) ((x) << 4)
-#define FW_PORT_STATS_CMD_BG_BM(x) ((x) << 0)
-#define FW_PORT_STATS_CMD_TX(x) ((x) << 7)
-#define FW_PORT_STATS_CMD_IX(x) ((x) << 0)
-
 /* port loopback stats */
 #define FW_NUM_LB_STATS 16
 enum fw_port_lb_stats_index {
@@ -2704,22 +2698,13 @@ struct fw_port_lb_stats_cmd {
 	} u;
 };
 
-#define FW_PORT_LB_STATS_CMD_LBPORT(x) ((x) << 0)
-#define FW_PORT_LB_STATS_CMD_NSTATS(x) ((x) << 4)
-#define FW_PORT_LB_STATS_CMD_BG_BM(x) ((x) << 0)
-#define FW_PORT_LB_STATS_CMD_IX(x) ((x) << 0)
-
 struct fw_rss_ind_tbl_cmd {
 	__be32 op_to_viid;
-#define FW_RSS_IND_TBL_CMD_VIID(x) ((x) << 0)
 	__be32 retval_len16;
 	__be16 niqid;
 	__be16 startidx;
 	__be32 r3;
 	__be32 iq0_to_iq2;
-#define FW_RSS_IND_TBL_CMD_IQ0(x) ((x) << 20)
-#define FW_RSS_IND_TBL_CMD_IQ1(x) ((x) << 10)
-#define FW_RSS_IND_TBL_CMD_IQ2(x) ((x) << 0)
 	__be32 iq3_to_iq5;
 	__be32 iq6_to_iq8;
 	__be32 iq9_to_iq11;
@@ -2733,6 +2718,18 @@ struct fw_rss_ind_tbl_cmd {
 	__be32 r15_lo;
 };
 
+#define FW_RSS_IND_TBL_CMD_VIID_S	0
+#define FW_RSS_IND_TBL_CMD_VIID_V(x)	((x) << FW_RSS_IND_TBL_CMD_VIID_S)
+
+#define FW_RSS_IND_TBL_CMD_IQ0_S	20
+#define FW_RSS_IND_TBL_CMD_IQ0_V(x)	((x) << FW_RSS_IND_TBL_CMD_IQ0_S)
+
+#define FW_RSS_IND_TBL_CMD_IQ1_S	10
+#define FW_RSS_IND_TBL_CMD_IQ1_V(x)	((x) << FW_RSS_IND_TBL_CMD_IQ1_S)
+
+#define FW_RSS_IND_TBL_CMD_IQ2_S	0
+#define FW_RSS_IND_TBL_CMD_IQ2_V(x)	((x) << FW_RSS_IND_TBL_CMD_IQ2_S)
+
 struct fw_rss_glb_config_cmd {
 	__be32 op_to_write;
 	__be32 retval_len16;
@@ -2746,27 +2743,75 @@ struct fw_rss_glb_config_cmd {
 		struct fw_rss_glb_config_basicvirtual {
 			__be32 mode_pkd;
 			__be32 synmapen_to_hashtoeplitz;
-#define FW_RSS_GLB_CONFIG_CMD_SYNMAPEN      (1U << 8)
-#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6 (1U << 7)
-#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6 (1U << 6)
-#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4 (1U << 5)
-#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4 (1U << 4)
-#define FW_RSS_GLB_CONFIG_CMD_OFDMAPEN      (1U << 3)
-#define FW_RSS_GLB_CONFIG_CMD_TNLMAPEN      (1U << 2)
-#define FW_RSS_GLB_CONFIG_CMD_TNLALLLKP     (1U << 1)
-#define FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ  (1U << 0)
 			__be64 r8;
 			__be64 r9;
 		} basicvirtual;
 	} u;
 };
 
-#define FW_RSS_GLB_CONFIG_CMD_MODE(x)	((x) << 28)
-#define FW_RSS_GLB_CONFIG_CMD_MODE_GET(x) (((x) >> 28) & 0xf)
+#define FW_RSS_GLB_CONFIG_CMD_MODE_S	28
+#define FW_RSS_GLB_CONFIG_CMD_MODE_M	0xf
+#define FW_RSS_GLB_CONFIG_CMD_MODE_V(x)	((x) << FW_RSS_GLB_CONFIG_CMD_MODE_S)
+#define FW_RSS_GLB_CONFIG_CMD_MODE_G(x)	\
+	(((x) >> FW_RSS_GLB_CONFIG_CMD_MODE_S) & FW_RSS_GLB_CONFIG_CMD_MODE_M)
 
 #define FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL	0
 #define FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL	1
 
+#define FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_S	8
+#define FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_S)
+#define FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_F	\
+	FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_S		7
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_S)
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_F	\
+	FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_S		6
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_S)
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_F	\
+	FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_S		5
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_S)
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_F	\
+	FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_S		4
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_S)
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_F	\
+	FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_S	3
+#define FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_S)
+#define FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_F	\
+	FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_S	2
+#define FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_S)
+#define FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F	\
+	FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_S	1
+#define FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_S)
+#define FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F	\
+	FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_V(1U)
+
+#define FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_S	0
+#define FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_V(x)	\
+	((x) << FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_S)
+#define FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_F	\
+	FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_V(1U)
+
 struct fw_rss_vi_config_cmd {
 	__be32 op_to_viid;
 #define FW_RSS_VI_CONFIG_CMD_VIID(x) ((x) << 0)
@@ -2780,19 +2825,51 @@ struct fw_rss_vi_config_cmd {
 		struct fw_rss_vi_config_basicvirtual {
 			__be32 r6;
 			__be32 defaultq_to_udpen;
-#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ(x)  ((x) << 16)
-#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_GET(x) (((x) >> 16) & 0x3ff)
-#define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN (1U << 4)
-#define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN  (1U << 3)
-#define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN (1U << 2)
-#define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN  (1U << 1)
-#define FW_RSS_VI_CONFIG_CMD_UDPEN        (1U << 0)
 			__be64 r9;
 			__be64 r10;
 		} basicvirtual;
 	} u;
 };
 
+#define FW_RSS_VI_CONFIG_CMD_VIID_S	0
+#define FW_RSS_VI_CONFIG_CMD_VIID_V(x)	((x) << FW_RSS_VI_CONFIG_CMD_VIID_S)
+
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_S		16
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_M		0x3ff
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_V(x)	\
+	((x) << FW_RSS_VI_CONFIG_CMD_DEFAULTQ_S)
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_G(x)	\
+	(((x) >> FW_RSS_VI_CONFIG_CMD_DEFAULTQ_S) & \
+	 FW_RSS_VI_CONFIG_CMD_DEFAULTQ_M)
+
+#define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_S	4
+#define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_V(x)	\
+	((x) << FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_S)
+#define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F	\
+	FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_V(1U)
+
+#define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_S	3
+#define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_V(x)	\
+	((x) << FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_S)
+#define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F	\
+	FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_V(1U)
+
+#define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_S	2
+#define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_V(x)	\
+	((x) << FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_S)
+#define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F	\
+	FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_V(1U)
+
+#define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_S	1
+#define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_V(x)	\
+	((x) << FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_S)
+#define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F	\
+	FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_V(1U)
+
+#define FW_RSS_VI_CONFIG_CMD_UDPEN_S	0
+#define FW_RSS_VI_CONFIG_CMD_UDPEN_V(x)	((x) << FW_RSS_VI_CONFIG_CMD_UDPEN_S)
+#define FW_RSS_VI_CONFIG_CMD_UDPEN_F	FW_RSS_VI_CONFIG_CMD_UDPEN_V(1U)
+
 struct fw_clip_cmd {
 	__be32 op_to_write;
 	__be32 alloc_to_len16;
@@ -2801,19 +2878,13 @@ struct fw_clip_cmd {
 	__be32 r4[2];
 };
 
-#define S_FW_CLIP_CMD_ALLOC     31
-#define M_FW_CLIP_CMD_ALLOC     0x1
-#define V_FW_CLIP_CMD_ALLOC(x)  ((x) << S_FW_CLIP_CMD_ALLOC)
-#define G_FW_CLIP_CMD_ALLOC(x)  \
-	(((x) >> S_FW_CLIP_CMD_ALLOC) & M_FW_CLIP_CMD_ALLOC)
-#define F_FW_CLIP_CMD_ALLOC     V_FW_CLIP_CMD_ALLOC(1U)
+#define FW_CLIP_CMD_ALLOC_S     31
+#define FW_CLIP_CMD_ALLOC_V(x)  ((x) << FW_CLIP_CMD_ALLOC_S)
+#define FW_CLIP_CMD_ALLOC_F     FW_CLIP_CMD_ALLOC_V(1U)
 
-#define S_FW_CLIP_CMD_FREE      30
-#define M_FW_CLIP_CMD_FREE      0x1
-#define V_FW_CLIP_CMD_FREE(x)   ((x) << S_FW_CLIP_CMD_FREE)
-#define G_FW_CLIP_CMD_FREE(x)   \
-	(((x) >> S_FW_CLIP_CMD_FREE) & M_FW_CLIP_CMD_FREE)
-#define F_FW_CLIP_CMD_FREE      V_FW_CLIP_CMD_FREE(1U)
+#define FW_CLIP_CMD_FREE_S      30
+#define FW_CLIP_CMD_FREE_V(x)   ((x) << FW_CLIP_CMD_FREE_S)
+#define FW_CLIP_CMD_FREE_F      FW_CLIP_CMD_FREE_V(1U)
 
 enum fw_error_type {
 	FW_ERROR_TYPE_EXCEPTION		= 0x0,
@@ -2852,7 +2923,6 @@ struct fw_error_cmd {
 
 struct fw_debug_cmd {
 	__be32 op_type;
-#define FW_DEBUG_CMD_TYPE_GET(x) ((x) & 0xff)
 	__be32 len16_pkd;
 	union fw_debug {
 		struct fw_debug_assert {
@@ -2875,19 +2945,35 @@ struct fw_debug_cmd {
 	} u;
 };
 
-#define FW_PCIE_FW_ERR           (1U << 31)
-#define FW_PCIE_FW_INIT          (1U << 30)
-#define FW_PCIE_FW_HALT          (1U << 29)
-#define FW_PCIE_FW_MASTER_VLD    (1U << 15)
-#define FW_PCIE_FW_MASTER_MASK   0x7
-#define FW_PCIE_FW_MASTER_SHIFT  12
-#define FW_PCIE_FW_MASTER(x)     ((x) << FW_PCIE_FW_MASTER_SHIFT)
-#define FW_PCIE_FW_MASTER_GET(x) (((x) >> FW_PCIE_FW_MASTER_SHIFT) & \
-				 FW_PCIE_FW_MASTER_MASK)
-#define FW_PCIE_FW_EVAL_MASK   0x7
-#define FW_PCIE_FW_EVAL_SHIFT  24
-#define FW_PCIE_FW_EVAL_GET(x) (((x) >> FW_PCIE_FW_EVAL_SHIFT) & \
-				 FW_PCIE_FW_EVAL_MASK)
+#define FW_DEBUG_CMD_TYPE_S	0
+#define FW_DEBUG_CMD_TYPE_M	0xff
+#define FW_DEBUG_CMD_TYPE_G(x)	\
+	(((x) >> FW_DEBUG_CMD_TYPE_S) & FW_DEBUG_CMD_TYPE_M)
+
+#define PCIE_FW_ERR_S		31
+#define PCIE_FW_ERR_V(x)	((x) << PCIE_FW_ERR_S)
+#define PCIE_FW_ERR_F		PCIE_FW_ERR_V(1U)
+
+#define PCIE_FW_INIT_S		30
+#define PCIE_FW_INIT_V(x)	((x) << PCIE_FW_INIT_S)
+#define PCIE_FW_INIT_F		PCIE_FW_INIT_V(1U)
+
+#define PCIE_FW_HALT_S          29
+#define PCIE_FW_HALT_V(x)       ((x) << PCIE_FW_HALT_S)
+#define PCIE_FW_HALT_F          PCIE_FW_HALT_V(1U)
+
+#define PCIE_FW_EVAL_S		24
+#define PCIE_FW_EVAL_M		0x7
+#define PCIE_FW_EVAL_G(x)	(((x) >> PCIE_FW_EVAL_S) & PCIE_FW_EVAL_M)
+
+#define PCIE_FW_MASTER_VLD_S	15
+#define PCIE_FW_MASTER_VLD_V(x)	((x) << PCIE_FW_MASTER_VLD_S)
+#define PCIE_FW_MASTER_VLD_F	PCIE_FW_MASTER_VLD_V(1U)
+
+#define PCIE_FW_MASTER_S	12
+#define PCIE_FW_MASTER_M	0x7
+#define PCIE_FW_MASTER_V(x)	((x) << PCIE_FW_MASTER_S)
+#define PCIE_FW_MASTER_G(x)	(((x) >> PCIE_FW_MASTER_S) & PCIE_FW_MASTER_M)
 
 struct fw_hdr {
 	u8 ver;
@@ -2915,10 +3001,25 @@ enum fw_hdr_chip {
 	FW_HDR_CHIP_T5
 };
 
-#define FW_HDR_FW_VER_MAJOR_GET(x) (((x) >> 24) & 0xff)
-#define FW_HDR_FW_VER_MINOR_GET(x) (((x) >> 16) & 0xff)
-#define FW_HDR_FW_VER_MICRO_GET(x) (((x) >> 8) & 0xff)
-#define FW_HDR_FW_VER_BUILD_GET(x) (((x) >> 0) & 0xff)
+#define FW_HDR_FW_VER_MAJOR_S	24
+#define FW_HDR_FW_VER_MAJOR_M	0xff
+#define FW_HDR_FW_VER_MAJOR_G(x) \
+	(((x) >> FW_HDR_FW_VER_MAJOR_S) & FW_HDR_FW_VER_MAJOR_M)
+
+#define FW_HDR_FW_VER_MINOR_S	16
+#define FW_HDR_FW_VER_MINOR_M	0xff
+#define FW_HDR_FW_VER_MINOR_G(x) \
+	(((x) >> FW_HDR_FW_VER_MINOR_S) & FW_HDR_FW_VER_MINOR_M)
+
+#define FW_HDR_FW_VER_MICRO_S	8
+#define FW_HDR_FW_VER_MICRO_M	0xff
+#define FW_HDR_FW_VER_MICRO_G(x) \
+	(((x) >> FW_HDR_FW_VER_MICRO_S) & FW_HDR_FW_VER_MICRO_M)
+
+#define FW_HDR_FW_VER_BUILD_S	0
+#define FW_HDR_FW_VER_BUILD_M	0xff
+#define FW_HDR_FW_VER_BUILD_G(x) \
+	(((x) >> FW_HDR_FW_VER_BUILD_S) & FW_HDR_FW_VER_BUILD_M)
 
 enum fw_hdr_intfver {
 	FW_HDR_INTFVER_NIC      = 0x00,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 7c24b50..099f7ce 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1230,14 +1230,14 @@ static void cxgb4vf_get_drvinfo(struct net_device *dev,
 		sizeof(drvinfo->bus_info));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
 		 "%u.%u.%u.%u, TP %u.%u.%u.%u",
-		 FW_HDR_FW_VER_MAJOR_GET(adapter->params.dev.fwrev),
-		 FW_HDR_FW_VER_MINOR_GET(adapter->params.dev.fwrev),
-		 FW_HDR_FW_VER_MICRO_GET(adapter->params.dev.fwrev),
-		 FW_HDR_FW_VER_BUILD_GET(adapter->params.dev.fwrev),
-		 FW_HDR_FW_VER_MAJOR_GET(adapter->params.dev.tprev),
-		 FW_HDR_FW_VER_MINOR_GET(adapter->params.dev.tprev),
-		 FW_HDR_FW_VER_MICRO_GET(adapter->params.dev.tprev),
-		 FW_HDR_FW_VER_BUILD_GET(adapter->params.dev.tprev));
+		 FW_HDR_FW_VER_MAJOR_G(adapter->params.dev.fwrev),
+		 FW_HDR_FW_VER_MINOR_G(adapter->params.dev.fwrev),
+		 FW_HDR_FW_VER_MICRO_G(adapter->params.dev.fwrev),
+		 FW_HDR_FW_VER_BUILD_G(adapter->params.dev.fwrev),
+		 FW_HDR_FW_VER_MAJOR_G(adapter->params.dev.tprev),
+		 FW_HDR_FW_VER_MINOR_G(adapter->params.dev.tprev),
+		 FW_HDR_FW_VER_MICRO_G(adapter->params.dev.tprev),
+		 FW_HDR_FW_VER_BUILD_G(adapter->params.dev.tprev));
 }
 
 /*
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 960d35c..624a213 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -585,7 +585,7 @@ int t4vf_get_rss_glb_config(struct adapter *adapter)
 	 * filtering at this point to weed out modes which don't support
 	 * VF Drivers ...
 	 */
-	rss->mode = FW_RSS_GLB_CONFIG_CMD_MODE_GET(
+	rss->mode = FW_RSS_GLB_CONFIG_CMD_MODE_G(
 			be32_to_cpu(rpl.u.manual.mode_pkd));
 	switch (rss->mode) {
 	case FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL: {
@@ -593,26 +593,26 @@ int t4vf_get_rss_glb_config(struct adapter *adapter)
 				rpl.u.basicvirtual.synmapen_to_hashtoeplitz);
 
 		rss->u.basicvirtual.synmapen =
-			((word & FW_RSS_GLB_CONFIG_CMD_SYNMAPEN) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_SYNMAPEN_F) != 0);
 		rss->u.basicvirtual.syn4tupenipv6 =
-			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6_F) != 0);
 		rss->u.basicvirtual.syn2tupenipv6 =
-			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6_F) != 0);
 		rss->u.basicvirtual.syn4tupenipv4 =
-			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4_F) != 0);
 		rss->u.basicvirtual.syn2tupenipv4 =
-			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4_F) != 0);
 
 		rss->u.basicvirtual.ofdmapen =
-			((word & FW_RSS_GLB_CONFIG_CMD_OFDMAPEN) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_OFDMAPEN_F) != 0);
 
 		rss->u.basicvirtual.tnlmapen =
-			((word & FW_RSS_GLB_CONFIG_CMD_TNLMAPEN) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_TNLMAPEN_F) != 0);
 		rss->u.basicvirtual.tnlalllookup =
-			((word  & FW_RSS_GLB_CONFIG_CMD_TNLALLLKP) != 0);
+			((word  & FW_RSS_GLB_CONFIG_CMD_TNLALLLKP_F) != 0);
 
 		rss->u.basicvirtual.hashtoeplitz =
-			((word & FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ) != 0);
+			((word & FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ_F) != 0);
 
 		/* we need at least Tunnel Map Enable to be set */
 		if (!rss->u.basicvirtual.tnlmapen)
@@ -709,17 +709,17 @@ int t4vf_read_rss_vi_config(struct adapter *adapter, unsigned int viid,
 		u32 word = be32_to_cpu(rpl.u.basicvirtual.defaultq_to_udpen);
 
 		config->basicvirtual.ip6fourtupen =
-			((word & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN) != 0);
+			((word & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F) != 0);
 		config->basicvirtual.ip6twotupen =
-			((word & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN) != 0);
+			((word & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F) != 0);
 		config->basicvirtual.ip4fourtupen =
-			((word & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN) != 0);
+			((word & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F) != 0);
 		config->basicvirtual.ip4twotupen =
-			((word & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN) != 0);
+			((word & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F) != 0);
 		config->basicvirtual.udpen =
-			((word & FW_RSS_VI_CONFIG_CMD_UDPEN) != 0);
+			((word & FW_RSS_VI_CONFIG_CMD_UDPEN_F) != 0);
 		config->basicvirtual.defaultq =
-			FW_RSS_VI_CONFIG_CMD_DEFAULTQ_GET(word);
+			FW_RSS_VI_CONFIG_CMD_DEFAULTQ_G(word);
 		break;
 	}
 
@@ -755,16 +755,16 @@ int t4vf_write_rss_vi_config(struct adapter *adapter, unsigned int viid,
 		u32 word = 0;
 
 		if (config->basicvirtual.ip6fourtupen)
-			word |= FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN;
+			word |= FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN_F;
 		if (config->basicvirtual.ip6twotupen)
-			word |= FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN;
+			word |= FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN_F;
 		if (config->basicvirtual.ip4fourtupen)
-			word |= FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN;
+			word |= FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN_F;
 		if (config->basicvirtual.ip4twotupen)
-			word |= FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN;
+			word |= FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN_F;
 		if (config->basicvirtual.udpen)
-			word |= FW_RSS_VI_CONFIG_CMD_UDPEN;
-		word |= FW_RSS_VI_CONFIG_CMD_DEFAULTQ(
+			word |= FW_RSS_VI_CONFIG_CMD_UDPEN_F;
+		word |= FW_RSS_VI_CONFIG_CMD_DEFAULTQ_V(
 				config->basicvirtual.defaultq);
 		cmd.u.basicvirtual.defaultq_to_udpen = cpu_to_be32(word);
 		break;
@@ -806,7 +806,7 @@ int t4vf_config_rss_range(struct adapter *adapter, unsigned int viid,
 	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_RSS_IND_TBL_CMD) |
 				     FW_CMD_REQUEST_F |
 				     FW_CMD_WRITE_F |
-				     FW_RSS_IND_TBL_CMD_VIID(viid));
+				     FW_RSS_IND_TBL_CMD_VIID_V(viid));
 	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
 
 	/*
@@ -857,9 +857,9 @@ int t4vf_config_rss_range(struct adapter *adapter, unsigned int viid,
 				if (rsp >= rsp_end)
 					rsp = rspq;
 			}
-			*qp++ = cpu_to_be32(FW_RSS_IND_TBL_CMD_IQ0(qbuf[0]) |
-					    FW_RSS_IND_TBL_CMD_IQ1(qbuf[1]) |
-					    FW_RSS_IND_TBL_CMD_IQ2(qbuf[2]));
+			*qp++ = cpu_to_be32(FW_RSS_IND_TBL_CMD_IQ0_V(qbuf[0]) |
+					    FW_RSS_IND_TBL_CMD_IQ1_V(qbuf[1]) |
+					    FW_RSS_IND_TBL_CMD_IQ2_V(qbuf[2]));
 		}
 
 		/*
diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 80ad9c5..1e4c4ee 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -650,10 +650,10 @@ static void
 csio_hw_print_fw_version(struct csio_hw *hw, char *str)
 {
 	csio_info(hw, "%s: %u.%u.%u.%u\n", str,
-		    FW_HDR_FW_VER_MAJOR_GET(hw->fwrev),
-		    FW_HDR_FW_VER_MINOR_GET(hw->fwrev),
-		    FW_HDR_FW_VER_MICRO_GET(hw->fwrev),
-		    FW_HDR_FW_VER_BUILD_GET(hw->fwrev));
+		    FW_HDR_FW_VER_MAJOR_G(hw->fwrev),
+		    FW_HDR_FW_VER_MINOR_G(hw->fwrev),
+		    FW_HDR_FW_VER_MICRO_G(hw->fwrev),
+		    FW_HDR_FW_VER_BUILD_G(hw->fwrev));
 }
 
 /*
@@ -706,9 +706,9 @@ csio_hw_check_fw_version(struct csio_hw *hw)
 	if (ret)
 		return ret;
 
-	major = FW_HDR_FW_VER_MAJOR_GET(hw->fwrev);
-	minor = FW_HDR_FW_VER_MINOR_GET(hw->fwrev);
-	micro = FW_HDR_FW_VER_MICRO_GET(hw->fwrev);
+	major = FW_HDR_FW_VER_MAJOR_G(hw->fwrev);
+	minor = FW_HDR_FW_VER_MINOR_G(hw->fwrev);
+	micro = FW_HDR_FW_VER_MICRO_G(hw->fwrev);
 
 	if (major != FW_VERSION_MAJOR(hw)) {	/* major mismatch - fail */
 		csio_err(hw, "card FW has major version %u, driver wants %u\n",
@@ -1998,13 +1998,13 @@ csio_hw_flash_fw(struct csio_hw *hw)
 
 	hdr = (const struct fw_hdr *)fw->data;
 	fw_ver = ntohl(hdr->fw_ver);
-	if (FW_HDR_FW_VER_MAJOR_GET(fw_ver) != FW_VERSION_MAJOR(hw))
+	if (FW_HDR_FW_VER_MAJOR_G(fw_ver) != FW_VERSION_MAJOR(hw))
 		return -EINVAL;      /* wrong major version, won't do */
 
 	/*
 	 * If the flash FW is unusable or we found something newer, load it.
 	 */
-	if (FW_HDR_FW_VER_MAJOR_GET(hw->fwrev) != FW_VERSION_MAJOR(hw) ||
+	if (FW_HDR_FW_VER_MAJOR_G(hw->fwrev) != FW_VERSION_MAJOR(hw) ||
 	    fw_ver > hw->fwrev) {
 		ret = csio_hw_fw_upgrade(hw, hw->pfn, fw->data, fw->size,
 				    /*force=*/false);
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index 70e1eb6..1ed5b21 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -974,10 +974,10 @@ static int csio_probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	sprintf(hw->fwrev_str, "%u.%u.%u.%u\n",
-		    FW_HDR_FW_VER_MAJOR_GET(hw->fwrev),
-		    FW_HDR_FW_VER_MINOR_GET(hw->fwrev),
-		    FW_HDR_FW_VER_MICRO_GET(hw->fwrev),
-		    FW_HDR_FW_VER_BUILD_GET(hw->fwrev));
+		    FW_HDR_FW_VER_MAJOR_G(hw->fwrev),
+		    FW_HDR_FW_VER_MINOR_G(hw->fwrev),
+		    FW_HDR_FW_VER_MICRO_G(hw->fwrev),
+		    FW_HDR_FW_VER_BUILD_G(hw->fwrev));
 
 	for (i = 0; i < hw->num_pports; i++) {
 		ln = csio_shost_init(hw, &pdev->dev, true, NULL);
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 8298878..08c265c 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -1126,7 +1126,7 @@ csio_mb_dump_fw_dbg(struct csio_hw *hw, __be64 *cmd)
 {
 	struct fw_debug_cmd *dbg = (struct fw_debug_cmd *)cmd;
 
-	if ((FW_DEBUG_CMD_TYPE_GET(ntohl(dbg->op_type))) == 1) {
+	if ((FW_DEBUG_CMD_TYPE_G(ntohl(dbg->op_type))) == 1) {
 		csio_info(hw, "FW print message:\n");
 		csio_info(hw, "\tdebug->dprtstridx = %d\n",
 			    ntohs(dbg->u.prt.dprtstridx));
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
