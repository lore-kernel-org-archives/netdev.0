From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 2/7] net: ethernet: update drivers to handle HWTSTAMP_FILTER_NTP_ALL
Date: Wed, 12 Apr 2017 16:17:32 +0200
Message-ID: <20170412141737.5881-3-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752484AbdDLORq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:46 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update drivers which can timestamp all packets to handle also
HWTSTAMP_FILTER_NTP_ALL.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 1 +
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   | 1 +
 drivers/net/ethernet/intel/e1000e/netdev.c         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 1 +
 drivers/net/ethernet/intel/igb/igb_ptp.c           | 1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       | 1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 1 +
 drivers/net/ethernet/neterion/vxge/vxge-main.c     | 1 +
 drivers/net/ethernet/qlogic/qede/qede_ptp.c        | 1 +
 drivers/net/ethernet/sfc/ef10.c                    | 1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 1 +
 drivers/net/ethernet/ti/cpsw.c                     | 1 +
 drivers/net/ethernet/tile/tilegx.c                 | 1 +
 net/core/dev_ioctl.c                               | 1 +
 18 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index c772420..89b21d7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1268,6 +1268,7 @@ static int xgbe_set_hwtstamp_settings(struct xgbe_prv_data *pdata,
 	case HWTSTAMP_FILTER_NONE:
 		break;
 
+	case HWTSTAMP_FILTER_NTP_ALL:
 	case HWTSTAMP_FILTER_ALL:
 		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENALL, 1);
 		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a851f95..2f30b1a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -15351,6 +15351,7 @@ int bnx2x_configure_ptp_filters(struct bnx2x *bp)
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		bp->rx_filter = HWTSTAMP_FILTER_NONE;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 927617c..7a0ef5b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3020,6 +3020,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		conf.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 34c7782..15e21b5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -2100,6 +2100,7 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		conf.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index a213868..2887bca 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -755,6 +755,7 @@ static int octeon_mgmt_ioctl_hwtstamp(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		p->has_rx_tstamp = have_hw_timestamps;
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		if (p->has_rx_tstamp) {
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e9af89a..3a77054 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3662,6 +3662,7 @@ static int e1000e_config_hwtstamp(struct e1000_adapter *adapter,
 		 * Delay Request messages but not both so fall-through to
 		 * time stamp all packets.
 		 */
+	case HWTSTAMP_FILTER_NTP_ALL:
 	case HWTSTAMP_FILTER_ALL:
 		is_l2 = true;
 		is_l4 = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 2caee35..198b770 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -562,6 +562,7 @@ static int i40e_ptp_set_timestamp_mode(struct i40e_pf *pf,
 			config->rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
 		}
 		break;
+	case HWTSTAMP_FILTER_NTP_ALL:
 	case HWTSTAMP_FILTER_ALL:
 	default:
 		return -ERANGE;
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 7a3fd4d..d333d6d 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -941,6 +941,7 @@ static int igb_ptp_set_timestamp_mode(struct igb_adapter *adapter,
 		is_l4 = true;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_NTP_ALL:
 	case HWTSTAMP_FILTER_ALL:
 		/* 82576 cannot timestamp all packets, which it needs to do to
 		 * support both V1 Sync and Delay_Req messages
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index ef0635e..d44c728 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -883,6 +883,7 @@ static int ixgbe_ptp_set_timestamp_mode(struct ixgbe_adapter *adapter,
 				   IXGBE_FLAG_RX_HWTSTAMP_IN_REGISTER);
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_NTP_ALL:
 	case HWTSTAMP_FILTER_ALL:
 		/* The X550 controller is capable of timestamping all packets,
 		 * which allows it to accept any filter.
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 94fab20..8243674 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2375,6 +2375,7 @@ static int mlx4_en_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index e706a87..e294944 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -128,6 +128,7 @@ int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		/* Disable CQE compression */
 		netdev_warn(dev, "Disabling cqe compression");
 		err = mlx5e_modify_rx_cqe_compression_locked(priv, false);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 6a4310a..50ea69d 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3218,6 +3218,7 @@ static int vxge_hwtstamp_set(struct vxgedev *vdev, void __user *data)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		if (vdev->devh->config.hwts_en != VXGE_HW_HWTS_ENABLE)
 			return -EFAULT;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.c b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
index 2e62dec..e977745 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ptp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
@@ -250,6 +250,7 @@ static int qede_ptp_cfg_filters(struct qede_dev *edev)
 		break;
 	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		ptp->rx_filter = HWTSTAMP_FILTER_NONE;
 		break;
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 78efb28..ad9c4de 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -6068,6 +6068,7 @@ static int efx_ef10_ptp_set_ts_config(struct efx_nic *efx,
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		init->rx_filter = HWTSTAMP_FILTER_ALL;
 		rc = efx_ptp_change_mode(efx, true, 0);
 		if (!rc)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 85f315e..a290c50 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -644,6 +644,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ethernet = PTP_TCR_TSIPENA;
 			break;
 
+		case HWTSTAMP_FILTER_NTP_ALL:
 		case HWTSTAMP_FILTER_ALL:
 			/* time stamp any incoming packet */
 			config.rx_filter = HWTSTAMP_FILTER_ALL;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index fa674a8..8da70fa 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1718,6 +1718,7 @@ static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		return -ERANGE;
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 7c634bc..aec9538 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -512,6 +512,7 @@ static int tile_hwtstamp_set(struct net_device *dev, struct ifreq *rq)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	default:
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index b94b1d2..77f04e7 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -225,6 +225,7 @@ static int net_hwtstamp_validate(struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_NTP_ALL:
 		rx_filter_valid = 1;
 		break;
 	}
-- 
2.9.3
