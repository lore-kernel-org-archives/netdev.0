From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get NCSI hw statistics
Date: Wed,  3 May 2017 14:44:37 +1000
Message-ID: <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55021 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751601AbdECEqR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:46:17 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434iB5n044977
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:46:12 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a77pg1hhd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:46:11 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:46:08 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jwgM57147512
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:46:06 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434jXX8024738
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:33 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
NCSI hardware statistics. The simplified output of this command is
shown as follows from the modified (private) ethtool. It's obvious
the HW statistics isn't fetched from hardware yet, which is to be
sorted out later.

 # ethtool --ncsi eth0 stats
 NCSI statistics as below

   hnc_cnt_hi:           0
   hnc_cnt_lo:           0
   hnc_rx_bytes:         0
   hnc_tx_bytes:         0
   hnc_rx_uc_pkts:       0
   hnc_rx_mc_pkts:       0
   hnc_rx_bc_pkts:       0
   hnc_tx_uc_pkts:       0
   hnc_tx_mc_pkts:       0
   hnc_tx_bc_pkts:       0
   hnc_fcs_err:          0
   hnc_align_err:        0
   hnc_false_carrier:    0
   hnc_runt_pkts:        0
   hnc_jabber_pkts:      0
   hnc_rx_pause_xon:     0
   hnc_rx_pause_xoff:    0
   hnc_tx_pause_xon:     0
   hnc_tx_pause_xoff:    0
   hnc_tx_s_collision:   0
   hnc_tx_m_collision:   0
   hnc_l_collision:      0
   hnc_e_collision:      0
   hnc_rx_ctl_frames:    0
   hnc_rx_64_frames:     0
   hnc_rx_127_frames:    0
   hnc_rx_255_frames:    0
   hnc_rx_511_frames:    0
   hnc_rx_1023_frames:   0
   hnc_rx_1522_frames:   0
   hnc_rx_9022_frames:   0
   hnc_tx_64_frames:     0
   hnc_tx_127_frames:    0
   hnc_tx_255_frames:    0
   hnc_tx_511_frames:    0
   hnc_tx_1023_frames:   0
   hnc_tx_1522_frames:   0
   hnc_tx_9022_frames:   0
   hnc_rx_valid_bytes:   0
   hnc_rx_runt_pkts:     0
   hnc_rx_jabber_pkts:   0
   ncsi_rx_cmds:         0
   ncsi_dropped_cmds:    0
   ncsi_cmd_type_errs:   0
   ncsi_cmd_csum_errs:   0
   ncsi_rx_pkts:         0
   ncsi_tx_pkts:         0
   ncsi_tx_aen_pkts:     0
   pt_tx_pkts:           0
   pt_tx_dropped:        0
   pt_tx_channel_err:    0
   pt_tx_us_err:         0
   pt_rx_pkts:           0
   pt_rx_dropped:        0
   pt_rx_channel_err:    0
   pt_rx_us_err:         0
   pt_rx_os_err:         0

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/linux/ethtool.h      |   2 +
 include/uapi/linux/ethtool.h | 124 +++++++++++++++++++++++++++++++++++++++++++
 net/core/ethtool.c           |  29 ++++++++++
 net/ncsi/ncsi-ethtool.c      |  87 ++++++++++++++++++++++++++++++
 4 files changed, 242 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 5704b8b..6d712ca 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -378,5 +378,7 @@ struct ethtool_ops {
 				     struct ethtool_ncsi_channels *);
 	int	(*get_ncsi_channel_info)(struct net_device *,
 					 struct ethtool_ncsi_channel_info *);
+	int	(*get_ncsi_stats)(struct net_device *,
+				  struct ethtool_ncsi_stats *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 81fbd51..472773c 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1333,6 +1333,7 @@ struct ethtool_per_queue_op {
 
 #define ETHTOOL_GNCSICHANNELS	0x00000050 /* Get NCSI channels */
 #define ETHTOOL_GNCSICINFO	0x00000051 /* Get NCSI channel information */
+#define ETHTOOL_GNCSISTATS	0x00000052 /* Get NCSI HW statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1931,4 +1932,127 @@ struct ethtool_ncsi_channel_info {
 	__u32	vlan_valid_bits;
 	__u16	vlan[16];
 };
+
+/**
+ * struct ethtool_ncsi_stats - NCSI hardware statistics
+ *
+ * @cmd: Command number = %ETHTOOL_GNCSISTATS
+ * @hnc_cnt_hi: Counter cleared
+ * @hnc_cnt_lo: Counter cleared
+ * @hnc_rx_bytes: Rx bytes
+ * @hnc_tx_bytes: Tx bytes
+ * @hnc_rx_uc_pkts: Rx UC packets
+ * @hnc_rx_mc_pkts: Rx MC packets
+ * @hnc_rx_bc_pkts: Rx BC packets
+ * @hnc_tx_uc_pkts: Tx UC packets
+ * @hnc_tx_mc_pkts: Tx MC packets
+ * @hnc_tx_bc_pkts: Tx BC packets
+ * @hnc_fcs_err: FCS errors
+ * @hnc_align_err: Alignment errors
+ * @hnc_false_carrier: False carrier detection
+ * @hnc_runt_pkts: Rx runt packets
+ * @hnc_jabber_pkts: Rx jabber packets
+ * @hnc_rx_pause_xon: Rx pause XON frames
+ * @hnc_rx_pause_xoff: Rx XOFF frames
+ * @hnc_tx_pause_xon: Tx XON frames
+ * @hnc_tx_pause_xoff: Tx XOFF frames
+ * @hnc_tx_s_collision: Single collision frames
+ * @hnc_tx_m_collision: Multiple collision frames
+ * @hnc_l_collision: Late collision frames
+ * @hnc_e_collision: Excessive collision frames
+ * @hnc_rx_ctl_frames: Rx control frames
+ * @hnc_rx_64_frames: Rx 64-bytes frames
+ * @hnc_rx_127_frames: Rx 65-127 bytes frames
+ * @hnc_rx_255_frames: Rx 128-255 bytes frames
+ * @hnc_rx_511_frames: Rx 256-511 bytes frames
+ * @hnc_rx_1023_frames: Rx 512-1023 bytes frames
+ * @hnc_rx_1522_frames: Rx 1024-1522 bytes frames
+ * @hnc_rx_9022_frames: Rx 1523-9022 bytes frames
+ * @hnc_tx_64_frames: Tx 64-bytes frames
+ * @hnc_tx_127_frames: Tx 65-127 bytes frames
+ * @hnc_tx_255_frames: Tx 128-255 bytes frames
+ * @hnc_tx_511_frames: Tx 256-511 bytes frames
+ * @hnc_tx_1023_frames: Tx 512-1023 bytes frames
+ * @hnc_tx_1522_frames: Tx 1024-1522 bytes frames
+ * @hnc_tx_9022_frames: Tx 1523-9022 bytes frames
+ * @hnc_rx_valid_bytes: Rx valid bytes
+ * @hnc_rx_runt_pkts: Rx error runt packets
+ * @hnc_rx_jabber_pkts: Rx error jabber packets
+ * @ncsi_rx_cmds: Rx NCSI commands
+ * @ncsi_dropped_cmds: Dropped commands
+ * @ncsi_cmd_type_errs: Command type errors
+ * @ncsi_cmd_csum_errs: Command checksum errors
+ * @ncsi_rx_pkts: Rx NCSI packets
+ * @ncsi_tx_pkts: Tx NCSI packets
+ * @ncsi_tx_aen_pkts: Tx AEN packets
+ * @pt_tx_pkts: Tx packets
+ * @pt_tx_dropped: Tx dropped packets
+ * @pt_tx_channel_err: Tx channel errors
+ * @pt_tx_us_err: Tx undersize errors
+ * @pt_rx_pkts: Rx packets
+ * @pt_rx_dropped: Rx dropped packets
+ * @pt_rx_channel_err: Rx channel errors
+ * @pt_rx_us_err: Rx undersize errors
+ * @pt_rx_os_err: Rx oversize errors
+ */
+struct ethtool_ncsi_stats {
+	__u32	cmd;
+	__u64	hnc_cnt_hi;
+	__u64	hnc_cnt_lo;
+	__u64	hnc_rx_bytes;
+	__u64	hnc_tx_bytes;
+	__u64	hnc_rx_uc_pkts;
+	__u64	hnc_rx_mc_pkts;
+	__u64	hnc_rx_bc_pkts;
+	__u64	hnc_tx_uc_pkts;
+	__u64	hnc_tx_mc_pkts;
+	__u64	hnc_tx_bc_pkts;
+	__u64	hnc_fcs_err;
+	__u64	hnc_align_err;
+	__u64	hnc_false_carrier;
+	__u64	hnc_runt_pkts;
+	__u64	hnc_jabber_pkts;
+	__u64	hnc_rx_pause_xon;
+	__u64	hnc_rx_pause_xoff;
+	__u64	hnc_tx_pause_xon;
+	__u64	hnc_tx_pause_xoff;
+	__u64	hnc_tx_s_collision;
+	__u64	hnc_tx_m_collision;
+	__u64	hnc_l_collision;
+	__u64	hnc_e_collision;
+	__u64	hnc_rx_ctl_frames;
+	__u64	hnc_rx_64_frames;
+	__u64	hnc_rx_127_frames;
+	__u64	hnc_rx_255_frames;
+	__u64	hnc_rx_511_frames;
+	__u64	hnc_rx_1023_frames;
+	__u64	hnc_rx_1522_frames;
+	__u64	hnc_rx_9022_frames;
+	__u64	hnc_tx_64_frames;
+	__u64	hnc_tx_127_frames;
+	__u64	hnc_tx_255_frames;
+	__u64	hnc_tx_511_frames;
+	__u64	hnc_tx_1023_frames;
+	__u64	hnc_tx_1522_frames;
+	__u64	hnc_tx_9022_frames;
+	__u64	hnc_rx_valid_bytes;
+	__u64	hnc_rx_runt_pkts;
+	__u64	hnc_rx_jabber_pkts;
+	__u64	ncsi_rx_cmds;
+	__u64	ncsi_dropped_cmds;
+	__u64	ncsi_cmd_type_errs;
+	__u64	ncsi_cmd_csum_errs;
+	__u64	ncsi_rx_pkts;
+	__u64	ncsi_tx_pkts;
+	__u64	ncsi_tx_aen_pkts;
+	__u64	pt_tx_pkts;
+	__u64	pt_tx_dropped;
+	__u64	pt_tx_channel_err;
+	__u64	pt_tx_us_err;
+	__u64	pt_rx_pkts;
+	__u64	pt_rx_dropped;
+	__u64	pt_rx_channel_err;
+	__u64	pt_rx_us_err;
+	__u64	pt_rx_os_err;
+};
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 116ef10..f26aa36 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -812,6 +812,32 @@ static int ethtool_get_ncsi_channel_info(struct net_device *dev,
 	return ret;
 }
 
+static int ethtool_get_ncsi_stats(struct net_device *dev,
+				  void __user *useraddr)
+{
+	struct ethtool_ncsi_stats *ens;
+	int ret;
+
+	if (!dev->ethtool_ops->get_ncsi_stats)
+		return -EOPNOTSUPP;
+
+	ens = kzalloc(sizeof(*ens), GFP_KERNEL);
+	if (!ens)
+		return -ENOMEM;
+
+	if (copy_from_user(ens, useraddr, sizeof(*ens))) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = dev->ethtool_ops->get_ncsi_stats(dev, ens);
+	if (!ret && copy_to_user(useraddr, ens, sizeof(*ens)))
+		ret = -EFAULT;
+out:
+	kfree(ens);
+	return ret;
+}
+
 static void
 warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
 {
@@ -2855,6 +2881,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GNCSICINFO:
 		rc = ethtool_get_ncsi_channel_info(dev, useraddr);
 		break;
+	case ETHTOOL_GNCSISTATS:
+		rc = ethtool_get_ncsi_stats(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
diff --git a/net/ncsi/ncsi-ethtool.c b/net/ncsi/ncsi-ethtool.c
index 9eee5fb..1ccdb50 100644
--- a/net/ncsi/ncsi-ethtool.c
+++ b/net/ncsi/ncsi-ethtool.c
@@ -175,6 +175,91 @@ static int ncsi_get_channel_info(struct net_device *dev,
 	return 0;
 }
 
+static int ncsi_get_stats(struct net_device *dev,
+			  struct ethtool_ncsi_stats *ens)
+{
+	struct ncsi_dev *nd;
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	struct ncsi_channel_stats *ncs;
+	unsigned long flags;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd)
+		return -ENXIO;
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			spin_lock_irqsave(&nc->lock, flags);
+
+			ncs = &nc->stats;
+			ens->hnc_cnt_hi += ncs->hnc_cnt_hi;
+			ens->hnc_cnt_lo += ncs->hnc_cnt_lo;
+			ens->hnc_rx_bytes += ncs->hnc_rx_bytes;
+			ens->hnc_tx_bytes += ncs->hnc_tx_bytes;
+			ens->hnc_rx_uc_pkts += ncs->hnc_rx_uc_pkts;
+			ens->hnc_rx_mc_pkts += ncs->hnc_rx_mc_pkts;
+			ens->hnc_rx_bc_pkts += ncs->hnc_rx_bc_pkts;
+			ens->hnc_tx_uc_pkts += ncs->hnc_tx_uc_pkts;
+			ens->hnc_tx_mc_pkts += ncs->hnc_tx_mc_pkts;
+			ens->hnc_tx_bc_pkts += ncs->hnc_tx_bc_pkts;
+			ens->hnc_fcs_err += ncs->hnc_fcs_err;
+			ens->hnc_align_err += ncs->hnc_align_err;
+			ens->hnc_false_carrier += ncs->hnc_false_carrier;
+			ens->hnc_runt_pkts += ncs->hnc_runt_pkts;
+			ens->hnc_jabber_pkts += ncs->hnc_jabber_pkts;
+			ens->hnc_rx_pause_xon += ncs->hnc_rx_pause_xon;
+			ens->hnc_rx_pause_xoff += ncs->hnc_rx_pause_xoff;
+			ens->hnc_tx_pause_xon += ncs->hnc_tx_pause_xon;
+			ens->hnc_tx_pause_xoff += ncs->hnc_tx_pause_xoff;
+			ens->hnc_tx_s_collision += ncs->hnc_tx_s_collision;
+			ens->hnc_tx_m_collision += ncs->hnc_tx_m_collision;
+			ens->hnc_l_collision += ncs->hnc_l_collision;
+			ens->hnc_e_collision += ncs->hnc_e_collision;
+			ens->hnc_rx_ctl_frames += ncs->hnc_rx_ctl_frames;
+			ens->hnc_rx_64_frames += ncs->hnc_rx_64_frames;
+			ens->hnc_rx_127_frames += ncs->hnc_rx_127_frames;
+			ens->hnc_rx_255_frames += ncs->hnc_rx_255_frames;
+			ens->hnc_rx_511_frames += ncs->hnc_rx_511_frames;
+			ens->hnc_rx_1023_frames += ncs->hnc_rx_1023_frames;
+			ens->hnc_rx_1522_frames += ncs->hnc_rx_1522_frames;
+			ens->hnc_rx_9022_frames += ncs->hnc_rx_9022_frames;
+			ens->hnc_tx_64_frames += ncs->hnc_tx_64_frames;
+			ens->hnc_tx_127_frames += ncs->hnc_tx_127_frames;
+			ens->hnc_tx_255_frames += ncs->hnc_tx_255_frames;
+			ens->hnc_tx_511_frames += ncs->hnc_tx_511_frames;
+			ens->hnc_tx_1023_frames += ncs->hnc_tx_1023_frames;
+			ens->hnc_tx_1522_frames += ncs->hnc_tx_1522_frames;
+			ens->hnc_tx_9022_frames += ncs->hnc_tx_9022_frames;
+			ens->hnc_rx_valid_bytes += ncs->hnc_rx_valid_bytes;
+			ens->hnc_rx_runt_pkts += ncs->hnc_rx_runt_pkts;
+			ens->hnc_rx_jabber_pkts += ncs->hnc_rx_jabber_pkts;
+			ens->ncsi_rx_cmds += ncs->ncsi_rx_cmds;
+			ens->ncsi_dropped_cmds += ncs->ncsi_dropped_cmds;
+			ens->ncsi_cmd_type_errs += ncs->ncsi_cmd_type_errs;
+			ens->ncsi_cmd_csum_errs += ncs->ncsi_cmd_csum_errs;
+			ens->ncsi_rx_pkts += ncs->ncsi_rx_pkts;
+			ens->ncsi_tx_pkts += ncs->ncsi_tx_pkts;
+			ens->ncsi_tx_aen_pkts += ncs->ncsi_tx_aen_pkts;
+			ens->pt_tx_pkts += ncs->pt_tx_pkts;
+			ens->pt_tx_dropped += ncs->pt_tx_dropped;
+			ens->pt_tx_channel_err += ncs->pt_tx_channel_err;
+			ens->pt_tx_us_err += ncs->pt_tx_us_err;
+			ens->pt_rx_pkts += ncs->pt_rx_pkts;
+			ens->pt_rx_dropped += ncs->pt_rx_dropped;
+			ens->pt_rx_channel_err += ncs->pt_rx_channel_err;
+			ens->pt_rx_us_err += ncs->pt_rx_us_err;
+			ens->pt_rx_os_err += ncs->pt_rx_os_err;
+
+			spin_unlock_irqrestore(&nc->lock, flags);
+		}
+	}
+
+	return 0;
+}
+
 void ncsi_ethtool_register_dev(struct net_device *dev)
 {
 	struct ethtool_ops *ops;
@@ -185,6 +270,7 @@ void ncsi_ethtool_register_dev(struct net_device *dev)
 
 	ops->get_ncsi_channels = ncsi_get_channels;
 	ops->get_ncsi_channel_info = ncsi_get_channel_info;
+	ops->get_ncsi_stats = ncsi_get_stats;
 }
 
 void ncsi_ethtool_unregister_dev(struct net_device *dev)
@@ -197,4 +283,5 @@ void ncsi_ethtool_unregister_dev(struct net_device *dev)
 
 	ops->get_ncsi_channels = NULL;
 	ops->get_ncsi_channel_info = NULL;
+	ops->get_ncsi_stats = NULL;
 }
-- 
2.7.4
