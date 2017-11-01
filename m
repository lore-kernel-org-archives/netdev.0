From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 01/12] net: bpf: rename ndo_xdp to ndo_bpf
Date: Tue, 31 Oct 2017 18:52:06 -0700
Message-ID: <20171101015217.10666-2-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:47618 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932868AbdKABxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id z11so731342pfk.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:52:59 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_xdp is a control path callback for setting up XDP in the
driver.  We can reuse it for other forms of communication
between the eBPF stack and the drivers.  Rename the callback
and associated structures and definitions.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h      |  2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  4 +--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  4 +--
 drivers/net/ethernet/qlogic/qede/qede.h            |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c     |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  4 +--
 drivers/net/tun.c                                  |  4 +--
 drivers/net/virtio_net.c                           |  4 +--
 include/linux/netdevice.h                          | 23 ++++++++-------
 net/core/dev.c                                     | 34 +++++++++++-----------
 net/core/rtnetlink.c                               |  4 +--
 17 files changed, 56 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c3dfaa5151aa..8e676e785d15 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7771,7 +7771,7 @@ static const struct net_device_ops bnxt_netdev_ops = {
 #endif
 	.ndo_udp_tunnel_add	= bnxt_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= bnxt_udp_tunnel_del,
-	.ndo_xdp		= bnxt_xdp,
+	.ndo_bpf		= bnxt_xdp,
 	.ndo_bridge_getlink	= bnxt_bridge_getlink,
 	.ndo_bridge_setlink	= bnxt_bridge_setlink,
 	.ndo_get_phys_port_name = bnxt_get_phys_port_name
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 06ce63c00821..261e5847557a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -208,7 +208,7 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	return 0;
 }
 
-int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+int bnxt_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	int rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
index 12a5ad66b564..414b748038ca 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
@@ -16,6 +16,6 @@ void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts);
 bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, u8 **data_ptr, unsigned int *len,
 		 u8 *event);
-int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp);
+int bnxt_xdp(struct net_device *dev, struct netdev_bpf *xdp);
 
 #endif
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 71989e180289..a063c36c4c58 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1741,7 +1741,7 @@ static int nicvf_xdp_setup(struct nicvf *nic, struct bpf_prog *prog)
 	return 0;
 }
 
-static int nicvf_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
+static int nicvf_xdp(struct net_device *netdev, struct netdev_bpf *xdp)
 {
 	struct nicvf *nic = netdev_priv(netdev);
 
@@ -1774,7 +1774,7 @@ static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_tx_timeout         = nicvf_tx_timeout,
 	.ndo_fix_features       = nicvf_fix_features,
 	.ndo_set_features       = nicvf_set_features,
-	.ndo_xdp		= nicvf_xdp,
+	.ndo_bpf		= nicvf_xdp,
 };
 
 static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54ff34faca37..1bbd85181cd0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10737,12 +10737,12 @@ static int i40e_xdp_setup(struct i40e_vsi *vsi,
 }
 
 /**
- * i40e_xdp - implements ndo_xdp for i40e
+ * i40e_xdp - implements ndo_bpf for i40e
  * @dev: netdevice
  * @xdp: XDP command
  **/
 static int i40e_xdp(struct net_device *dev,
-		    struct netdev_xdp *xdp)
+		    struct netdev_bpf *xdp)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -10794,7 +10794,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_features_check	= i40e_features_check,
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
-	.ndo_xdp		= i40e_xdp,
+	.ndo_bpf		= i40e_xdp,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 507977994a03..e5dcb25be398 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -10004,7 +10004,7 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
 	return 0;
 }
 
-static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+static int ixgbe_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
@@ -10113,7 +10113,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_udp_tunnel_add	= ixgbe_add_udp_tunnel_port,
 	.ndo_udp_tunnel_del	= ixgbe_del_udp_tunnel_port,
 	.ndo_features_check	= ixgbe_features_check,
-	.ndo_xdp		= ixgbe_xdp,
+	.ndo_bpf		= ixgbe_xdp,
 	.ndo_xdp_xmit		= ixgbe_xdp_xmit,
 	.ndo_xdp_flush		= ixgbe_xdp_flush,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d611df2f274d..736a6ccaf05e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2916,7 +2916,7 @@ static u32 mlx4_xdp_query(struct net_device *dev)
 	return prog_id;
 }
 
-static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+static int mlx4_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
@@ -2958,7 +2958,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
-	.ndo_xdp		= mlx4_xdp,
+	.ndo_bpf		= mlx4_xdp,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2995,7 +2995,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
-	.ndo_xdp		= mlx4_xdp,
+	.ndo_bpf		= mlx4_xdp,
 };
 
 struct mlx4_en_bond {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 28ae00b3eb88..3b7b7bb84eb0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3831,7 +3831,7 @@ static u32 mlx5e_xdp_query(struct net_device *dev)
 	return prog_id;
 }
 
-static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+static int mlx5e_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
@@ -3883,7 +3883,7 @@ static const struct net_device_ops mlx5e_netdev_ops = {
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
-	.ndo_xdp		 = mlx5e_xdp,
+	.ndo_bpf		 = mlx5e_xdp,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller     = mlx5e_netpoll,
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 185a3dd35a3f..f6c6ad4e8a59 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3378,7 +3378,7 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 	return 0;
 }
 
-static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
+static int nfp_net_xdp(struct net_device *netdev, struct netdev_bpf *xdp)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
@@ -3441,7 +3441,7 @@ const struct net_device_ops nfp_net_netdev_ops = {
 	.ndo_get_phys_port_name	= nfp_port_get_phys_port_name,
 	.ndo_udp_tunnel_add	= nfp_net_add_vxlan_port,
 	.ndo_udp_tunnel_del	= nfp_net_del_vxlan_port,
-	.ndo_xdp		= nfp_net_xdp,
+	.ndo_bpf		= nfp_net_xdp,
 };
 
 /**
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index adb700512baa..a3a70ade411f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -503,7 +503,7 @@ void qede_fill_rss_params(struct qede_dev *edev,
 void qede_udp_tunnel_add(struct net_device *dev, struct udp_tunnel_info *ti);
 void qede_udp_tunnel_del(struct net_device *dev, struct udp_tunnel_info *ti);
 
-int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp);
+int qede_xdp(struct net_device *dev, struct netdev_bpf *xdp);
 
 #ifdef CONFIG_DCB
 void qede_set_dcbnl_ops(struct net_device *ndev);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index f79e36e4060a..c1a0708a7d7c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -1065,7 +1065,7 @@ static int qede_xdp_set(struct qede_dev *edev, struct bpf_prog *prog)
 	return 0;
 }
 
-int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+int qede_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index e5ee9f274a71..8f9b3eb82137 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -556,7 +556,7 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
 	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
 	.ndo_features_check = qede_features_check,
-	.ndo_xdp = qede_xdp,
+	.ndo_bpf = qede_xdp,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer = qede_rx_flow_steer,
 #endif
@@ -594,7 +594,7 @@ static const struct net_device_ops qede_netdev_vf_xdp_ops = {
 	.ndo_udp_tunnel_add = qede_udp_tunnel_add,
 	.ndo_udp_tunnel_del = qede_udp_tunnel_del,
 	.ndo_features_check = qede_features_check,
-	.ndo_xdp = qede_xdp,
+	.ndo_bpf = qede_xdp,
 };
 
 /* -------------------------------------------------------------------------
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 81d0787a6dab..1a24442ae096 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1141,7 +1141,7 @@ static u32 tun_xdp_query(struct net_device *dev)
 	return 0;
 }
 
-static int tun_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+static int tun_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
@@ -1185,7 +1185,7 @@ static const struct net_device_ops tap_netdev_ops = {
 	.ndo_features_check	= passthru_features_check,
 	.ndo_set_rx_headroom	= tun_set_headroom,
 	.ndo_get_stats64	= tun_net_get_stats64,
-	.ndo_xdp		= tun_xdp,
+	.ndo_bpf		= tun_xdp,
 };
 
 static void tun_flow_init(struct tun_struct *tun)
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fc059f193e7d..edf984406ba0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2088,7 +2088,7 @@ static u32 virtnet_xdp_query(struct net_device *dev)
 	return 0;
 }
 
-static int virtnet_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+static int virtnet_xdp(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
@@ -2115,7 +2115,7 @@ static const struct net_device_ops virtnet_netdev = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
-	.ndo_xdp		= virtnet_xdp,
+	.ndo_bpf		= virtnet_xdp,
 	.ndo_xdp_xmit		= virtnet_xdp_xmit,
 	.ndo_xdp_flush		= virtnet_xdp_flush,
 	.ndo_features_check	= passthru_features_check,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e02f79b2110..331378a0a0a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -779,10 +779,10 @@ enum tc_setup_type {
 	TC_SETUP_CBS,
 };
 
-/* These structures hold the attributes of xdp state that are being passed
- * to the netdevice through the xdp op.
+/* These structures hold the attributes of bpf state that are being passed
+ * to the netdevice through the bpf op.
  */
-enum xdp_netdev_command {
+enum bpf_netdev_command {
 	/* Set or clear a bpf program used in the earliest stages of packet
 	 * rx. The prog will have been loaded as BPF_PROG_TYPE_XDP. The callee
 	 * is responsible for calling bpf_prog_put on any old progs that are
@@ -801,8 +801,8 @@ enum xdp_netdev_command {
 
 struct netlink_ext_ack;
 
-struct netdev_xdp {
-	enum xdp_netdev_command command;
+struct netdev_bpf {
+	enum bpf_netdev_command command;
 	union {
 		/* XDP_SETUP_PROG */
 		struct {
@@ -1124,9 +1124,10 @@ struct dev_ifalias {
  *	appropriate rx headroom value allows avoiding skb head copy on
  *	forward. Setting a negative value resets the rx headroom to the
  *	default value.
- * int (*ndo_xdp)(struct net_device *dev, struct netdev_xdp *xdp);
+ * int (*ndo_bpf)(struct net_device *dev, struct netdev_bpf *bpf);
  *	This function is used to set or query state related to XDP on the
- *	netdevice. See definition of enum xdp_netdev_command for details.
+ *	netdevice and manage BPF offload. See definition of
+ *	enum bpf_netdev_command for details.
  * int (*ndo_xdp_xmit)(struct net_device *dev, struct xdp_buff *xdp);
  *	This function is used to submit a XDP packet for transmit on a
  *	netdevice.
@@ -1315,8 +1316,8 @@ struct net_device_ops {
 						       struct sk_buff *skb);
 	void			(*ndo_set_rx_headroom)(struct net_device *dev,
 						       int needed_headroom);
-	int			(*ndo_xdp)(struct net_device *dev,
-					   struct netdev_xdp *xdp);
+	int			(*ndo_bpf)(struct net_device *dev,
+					   struct netdev_bpf *bpf);
 	int			(*ndo_xdp_xmit)(struct net_device *dev,
 						struct xdp_buff *xdp);
 	void			(*ndo_xdp_flush)(struct net_device *dev);
@@ -3308,10 +3309,10 @@ struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *d
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
 
-typedef int (*xdp_op_t)(struct net_device *dev, struct netdev_xdp *xdp);
+typedef int (*bpf_op_t)(struct net_device *dev, struct netdev_bpf *bpf);
 int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		      int fd, u32 flags);
-u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id);
+u8 __dev_xdp_attached(struct net_device *dev, bpf_op_t xdp_op, u32 *prog_id);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 24ac9083bc13..abed566e1b1d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4544,7 +4544,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	return ret;
 }
 
-static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
+static int generic_xdp_install(struct net_device *dev, struct netdev_bpf *xdp)
 {
 	struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
 	struct bpf_prog *new = xdp->prog;
@@ -7089,26 +7089,26 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-u8 __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op, u32 *prog_id)
+u8 __dev_xdp_attached(struct net_device *dev, bpf_op_t bpf_op, u32 *prog_id)
 {
-	struct netdev_xdp xdp;
+	struct netdev_bpf xdp;
 
 	memset(&xdp, 0, sizeof(xdp));
 	xdp.command = XDP_QUERY_PROG;
 
 	/* Query must always succeed. */
-	WARN_ON(xdp_op(dev, &xdp) < 0);
+	WARN_ON(bpf_op(dev, &xdp) < 0);
 	if (prog_id)
 		*prog_id = xdp.prog_id;
 
 	return xdp.prog_attached;
 }
 
-static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
+static int dev_xdp_install(struct net_device *dev, bpf_op_t bpf_op,
 			   struct netlink_ext_ack *extack, u32 flags,
 			   struct bpf_prog *prog)
 {
-	struct netdev_xdp xdp;
+	struct netdev_bpf xdp;
 
 	memset(&xdp, 0, sizeof(xdp));
 	if (flags & XDP_FLAGS_HW_MODE)
@@ -7119,7 +7119,7 @@ static int dev_xdp_install(struct net_device *dev, xdp_op_t xdp_op,
 	xdp.flags = flags;
 	xdp.prog = prog;
 
-	return xdp_op(dev, &xdp);
+	return bpf_op(dev, &xdp);
 }
 
 /**
@@ -7136,24 +7136,24 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	struct bpf_prog *prog = NULL;
-	xdp_op_t xdp_op, xdp_chk;
+	bpf_op_t bpf_op, bpf_chk;
 	int err;
 
 	ASSERT_RTNL();
 
-	xdp_op = xdp_chk = ops->ndo_xdp;
-	if (!xdp_op && (flags & (XDP_FLAGS_DRV_MODE | XDP_FLAGS_HW_MODE)))
+	bpf_op = bpf_chk = ops->ndo_bpf;
+	if (!bpf_op && (flags & (XDP_FLAGS_DRV_MODE | XDP_FLAGS_HW_MODE)))
 		return -EOPNOTSUPP;
-	if (!xdp_op || (flags & XDP_FLAGS_SKB_MODE))
-		xdp_op = generic_xdp_install;
-	if (xdp_op == xdp_chk)
-		xdp_chk = generic_xdp_install;
+	if (!bpf_op || (flags & XDP_FLAGS_SKB_MODE))
+		bpf_op = generic_xdp_install;
+	if (bpf_op == bpf_chk)
+		bpf_chk = generic_xdp_install;
 
 	if (fd >= 0) {
-		if (xdp_chk && __dev_xdp_attached(dev, xdp_chk, NULL))
+		if (bpf_chk && __dev_xdp_attached(dev, bpf_chk, NULL))
 			return -EEXIST;
 		if ((flags & XDP_FLAGS_UPDATE_IF_NOEXIST) &&
-		    __dev_xdp_attached(dev, xdp_op, NULL))
+		    __dev_xdp_attached(dev, bpf_op, NULL))
 			return -EBUSY;
 
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
@@ -7161,7 +7161,7 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 			return PTR_ERR(prog);
 	}
 
-	err = dev_xdp_install(dev, xdp_op, extack, flags, prog);
+	err = dev_xdp_install(dev, bpf_op, extack, flags, prog);
 	if (err < 0 && prog)
 		bpf_prog_put(prog);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index de24d394c69e..1d08f5995a67 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1269,10 +1269,10 @@ static u8 rtnl_xdp_attached_mode(struct net_device *dev, u32 *prog_id)
 		*prog_id = generic_xdp_prog->aux->id;
 		return XDP_ATTACHED_SKB;
 	}
-	if (!ops->ndo_xdp)
+	if (!ops->ndo_bpf)
 		return XDP_ATTACHED_NONE;
 
-	return __dev_xdp_attached(dev, ops->ndo_xdp, prog_id);
+	return __dev_xdp_attached(dev, ops->ndo_bpf, prog_id);
 }
 
 static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
-- 
2.14.1
