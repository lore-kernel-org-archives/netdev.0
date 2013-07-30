From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] net: rename CONFIG_NET_LL_RX_POLL to CONFIG_NET_RX_BUSY_POLL
Date: Tue, 30 Jul 2013 17:38:45 +0800
Message-ID: <1375177125-7209-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932637Ab3G3JjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 05:39:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Eliezer renames several *ll_poll to *busy_poll, but forgets
CONFIG_NET_LL_RX_POLL, so in case of confusion, rename it too.

Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    8 ++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   12 ++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |   10 +++++-----
 include/linux/netdevice.h                        |    2 +-
 include/linux/skbuff.h                           |    2 +-
 include/net/busy_poll.h                          |    6 +++---
 include/net/sock.h                               |    2 +-
 net/Kconfig                                      |    2 +-
 net/core/skbuff.c                                |    2 +-
 net/core/sock.c                                  |    6 +++---
 net/core/sysctl_net_core.c                       |    2 +-
 net/socket.c                                     |    2 +-
 17 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index dedbd76..d80e34b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -486,7 +486,7 @@ struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int state;
 #define BNX2X_FP_STATE_IDLE		      0
 #define BNX2X_FP_STATE_NAPI		(1 << 0)    /* NAPI owns this FP */
@@ -498,7 +498,7 @@ struct bnx2x_fastpath {
 #define BNX2X_FP_USER_PEND (BNX2X_FP_STATE_POLL | BNX2X_FP_STATE_POLL_YIELD)
 	/* protect state */
 	spinlock_t lock;
-#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 
 	union host_hc_status_block	status_blk;
 	/* chip independent shortcuts into sb structure */
@@ -572,7 +572,7 @@ struct bnx2x_fastpath {
 #define bnx2x_fp_stats(bp, fp)	(&((bp)->fp_stats[(fp)->index]))
 #define bnx2x_fp_qstats(bp, fp)	(&((bp)->fp_stats[(fp)->index].eth_q_stats))
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void bnx2x_fp_init_lock(struct bnx2x_fastpath *fp)
 {
 	spin_lock_init(&fp->lock);
@@ -680,7 +680,7 @@ static inline bool bnx2x_fp_ll_polling(struct bnx2x_fastpath *fp)
 {
 	return false;
 }
-#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 
 /* Use 2500 as a mini-jumbo MTU for FCoE */
 #define BNX2X_FCOE_MINI_JUMBO_MTU	2500
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ee350bd..f2d1ff1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3117,7 +3117,7 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 int bnx2x_low_latency_recv(struct napi_struct *napi)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e5da078..e06186c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12026,7 +12026,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_fcoe_get_wwn	= bnx2x_fcoe_get_wwn,
 #endif
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= bnx2x_low_latency_recv,
 #endif
 };
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7be725c..a6494e5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -54,7 +54,7 @@
 
 #include <net/busy_poll.h>
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 #define LL_EXTENDED_STATS
 #endif
 /* common prefix used by pr_<> macros */
@@ -366,7 +366,7 @@ struct ixgbe_q_vector {
 	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[IFNAMSIZ + 9];
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int state;
 #define IXGBE_QV_STATE_IDLE        0
 #define IXGBE_QV_STATE_NAPI	   1    /* NAPI owns this QV */
@@ -377,12 +377,12 @@ struct ixgbe_q_vector {
 #define IXGBE_QV_YIELD (IXGBE_QV_STATE_NAPI_YIELD | IXGBE_QV_STATE_POLL_YIELD)
 #define IXGBE_QV_USER_PEND (IXGBE_QV_STATE_POLL | IXGBE_QV_STATE_POLL_YIELD)
 	spinlock_t lock;
-#endif  /* CONFIG_NET_LL_RX_POLL */
+#endif  /* CONFIG_NET_RX_BUSY_POLL */
 
 	/* for dynamic allocation of rings associated with this q_vector */
 	struct ixgbe_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
 {
 
@@ -462,7 +462,7 @@ static inline bool ixgbe_qv_ll_polling(struct ixgbe_q_vector *q_vector)
 	WARN_ON(!(q_vector->state & IXGBE_QV_LOCKED));
 	return q_vector->state & IXGBE_QV_USER_PEND;
 }
-#else /* CONFIG_NET_LL_RX_POLL */
+#else /* CONFIG_NET_RX_BUSY_POLL */
 static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
 {
 }
@@ -491,7 +491,7 @@ static inline bool ixgbe_qv_ll_polling(struct ixgbe_q_vector *q_vector)
 {
 	return false;
 }
-#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 
 #ifdef CONFIG_IXGBE_HWMON
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bad8f14..be4b1fb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1998,7 +1998,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	return total_rx_packets;
 }
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 static int ixgbe_low_latency_recv(struct napi_struct *napi)
 {
@@ -2030,7 +2030,7 @@ static int ixgbe_low_latency_recv(struct napi_struct *napi)
 
 	return found;
 }
-#endif	/* CONFIG_NET_LL_RX_POLL */
+#endif	/* CONFIG_NET_RX_BUSY_POLL */
 
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
@@ -7227,7 +7227,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= ixgbe_low_latency_recv,
 #endif
 #ifdef IXGBE_FCOE
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 727874f..a28cd80 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -223,7 +223,7 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_STATS:
 		return (priv->stats_bitmap ? bit_count : NUM_ALL_STATS) +
 			(priv->tx_ring_num * 2) +
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 			(priv->rx_ring_num * 5);
 #else
 			(priv->rx_ring_num * 2);
@@ -276,7 +276,7 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		data[index++] = priv->rx_ring[i].packets;
 		data[index++] = priv->rx_ring[i].bytes;
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 		data[index++] = priv->rx_ring[i].yields;
 		data[index++] = priv->rx_ring[i].misses;
 		data[index++] = priv->rx_ring[i].cleaned;
@@ -344,7 +344,7 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				"rx%d_packets", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_bytes", i);
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_napi_yield", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5eac871..fa37b7a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -68,7 +68,7 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 static int mlx4_en_low_latency_recv(struct napi_struct *napi)
 {
@@ -94,7 +94,7 @@ static int mlx4_en_low_latency_recv(struct napi_struct *napi)
 
 	return done;
 }
-#endif	/* CONFIG_NET_LL_RX_POLL */
+#endif	/* CONFIG_NET_RX_BUSY_POLL */
 
 #ifdef CONFIG_RFS_ACCEL
 
@@ -2140,7 +2140,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= mlx4_en_low_latency_recv,
 #endif
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 35fb60e..5e0aa56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -292,7 +292,7 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned long yields;
 	unsigned long misses;
 	unsigned long cleaned;
@@ -318,7 +318,7 @@ struct mlx4_en_cq {
 	struct mlx4_cqe *buf;
 #define MLX4_EN_OPCODE_ERROR	0x1e
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int state;
 #define MLX4_EN_CQ_STATE_IDLE        0
 #define MLX4_EN_CQ_STATE_NAPI     1    /* NAPI owns this CQ */
@@ -329,7 +329,7 @@ struct mlx4_en_cq {
 #define CQ_YIELD (MLX4_EN_CQ_STATE_NAPI_YIELD | MLX4_EN_CQ_STATE_POLL_YIELD)
 #define CQ_USER_PEND (MLX4_EN_CQ_STATE_POLL | MLX4_EN_CQ_STATE_POLL_YIELD)
 	spinlock_t poll_lock; /* protects from LLS/napi conflicts */
-#endif  /* CONFIG_NET_LL_RX_POLL */
+#endif  /* CONFIG_NET_RX_BUSY_POLL */
 };
 
 struct mlx4_en_port_profile {
@@ -580,7 +580,7 @@ struct mlx4_mac_entry {
 	struct rcu_head rcu;
 };
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void mlx4_en_cq_init_lock(struct mlx4_en_cq *cq)
 {
 	spin_lock_init(&cq->poll_lock);
@@ -687,7 +687,7 @@ static inline bool mlx4_en_cq_ll_polling(struct mlx4_en_cq *cq)
 {
 	return false;
 }
-#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 
 #define MLX4_EN_WOL_DO_MODIFY (1ULL << 63)
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3ca60b0..6884b27 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -973,7 +973,7 @@ struct net_device_ops {
 						     gfp_t gfp);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	int			(*ndo_busy_poll)(struct napi_struct *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5afefa0..3b71a4e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -501,7 +501,7 @@ struct sk_buff {
 	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
-#if defined CONFIG_NET_DMA || defined CONFIG_NET_LL_RX_POLL
+#if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
 	union {
 		unsigned int	napi_id;
 		dma_cookie_t	dma_cookie;
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index a14339c..1428c32 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -27,7 +27,7 @@
 #include <linux/netdevice.h>
 #include <net/ip.h>
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 
 struct napi_struct;
 extern unsigned int sysctl_net_busy_read __read_mostly;
@@ -146,7 +146,7 @@ static inline void sk_mark_napi_id(struct sock *sk, struct sk_buff *skb)
 	sk->sk_napi_id = skb->napi_id;
 }
 
-#else /* CONFIG_NET_LL_RX_POLL */
+#else /* CONFIG_NET_RX_BUSY_POLL */
 static inline unsigned long net_busy_loop_on(void)
 {
 	return 0;
@@ -181,5 +181,5 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 	return true;
 }
 
-#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 #endif /* _LINUX_NET_BUSY_POLL_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index b9f2b09..f5731bf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -327,7 +327,7 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	unsigned int		sk_napi_id;
 	unsigned int		sk_ll_usec;
 #endif
diff --git a/net/Kconfig b/net/Kconfig
index 3770249..2b40660 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -244,7 +244,7 @@ config NETPRIO_CGROUP
 	  Cgroup subsystem for use in assigning processes to network priorities on
 	  a per-interface basis
 
-config NET_LL_RX_POLL
+config NET_RX_BUSY_POLL
 	boolean
 	default y
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 20e02d2..6a9aa52 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -739,7 +739,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 
 	skb_copy_secmark(new, old);
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	new->napi_id	= old->napi_id;
 #endif
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 85e8de1..2179bcb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -901,7 +901,7 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_SELECT_ERR_QUEUE, valbool);
 		break;
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	case SO_BUSY_POLL:
 		/* allow unprivileged users to decrease the value */
 		if ((val > sk->sk_ll_usec) && !capable(CAP_NET_ADMIN))
@@ -1171,7 +1171,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = sock_flag(sk, SOCK_SELECT_ERR_QUEUE);
 		break;
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	case SO_BUSY_POLL:
 		v.val = sk->sk_ll_usec;
 		break;
@@ -2293,7 +2293,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_stamp = ktime_set(-1L, 0);
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	sk->sk_napi_id		=	0;
 	sk->sk_ll_usec		=	sysctl_net_busy_read;
 #endif
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 6609686..b59b680 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -298,7 +298,7 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= flow_limit_table_len_sysctl
 	},
 #endif /* CONFIG_NET_FLOW_LIMIT */
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	{
 		.procname	= "busy_poll",
 		.data		= &sysctl_net_busy_poll,
diff --git a/net/socket.c b/net/socket.c
index 829b460..b2d7c62 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -106,7 +106,7 @@
 #include <linux/atalk.h>
 #include <net/busy_poll.h>
 
-#ifdef CONFIG_NET_LL_RX_POLL
+#ifdef CONFIG_NET_RX_BUSY_POLL
 unsigned int sysctl_net_busy_read __read_mostly;
 unsigned int sysctl_net_busy_poll __read_mostly;
 #endif
