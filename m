From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 1/3] cxgb3: function namespace cleanup
Date: Mon, 18 Oct 2010 18:14:52 -0700
Message-ID: <4CBCF10C.4010900@chelsio.com>
References: <20101015224309.179898823@vyatta.com> <20101015224523.536739529@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18837 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab0JSBPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 21:15:25 -0400
In-Reply-To: <20101015224523.536739529@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 10/15/2010 03:43 PM, Stephen Hemminger wrote:
> Make local functions static. Remove functions that are
> defined and never used. Compile tested only.
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>

Acked-by: Divy Le Ray <divy@chelsio.com>

> ---
>   drivers/net/cxgb3/adapter.h       |    3
>   drivers/net/cxgb3/common.h        |   18 ---
>   drivers/net/cxgb3/cxgb3_defs.h    |    3
>   drivers/net/cxgb3/cxgb3_offload.c |    9 +
>   drivers/net/cxgb3/mc5.c           |   38 -------
>   drivers/net/cxgb3/sge.c           |   39 -------
>   drivers/net/cxgb3/t3_hw.c         |  197 ++------------------------------------
>   7 files changed, 18 insertions(+), 289 deletions(-)
>
> --- a/drivers/net/cxgb3/common.h	2010-10-15 11:13:45.087851624 -0700
> +++ b/drivers/net/cxgb3/common.h	2010-10-15 11:24:41.425577576 -0700
> @@ -673,7 +673,6 @@ void t3_xgm_intr_enable(struct adapter *
>   void t3_xgm_intr_disable(struct adapter *adapter, int idx);
>   void t3_port_intr_enable(struct adapter *adapter, int idx);
>   void t3_port_intr_disable(struct adapter *adapter, int idx);
> -void t3_port_intr_clear(struct adapter *adapter, int idx);
>   int t3_slow_intr_handler(struct adapter *adapter);
>   int t3_phy_intr_handler(struct adapter *adapter);
>
> @@ -689,14 +688,10 @@ int t3_check_tpsram_version(struct adapt
>   int t3_check_tpsram(struct adapter *adapter, const u8 *tp_ram,
>   		    unsigned int size);
>   int t3_set_proto_sram(struct adapter *adap, const u8 *data);
> -int t3_read_flash(struct adapter *adapter, unsigned int addr,
> -		  unsigned int nwords, u32 *data, int byte_oriented);
>   int t3_load_fw(struct adapter *adapter, const u8 * fw_data, unsigned int size);
>   int t3_get_fw_version(struct adapter *adapter, u32 *vers);
>   int t3_check_fw_version(struct adapter *adapter);
>   int t3_init_hw(struct adapter *adapter, u32 fw_params);
> -void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
> -void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
>   int t3_reset_adapter(struct adapter *adapter);
>   int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
>   		    int reset);
> @@ -706,8 +701,6 @@ void t3_fatal_err(struct adapter *adapte
>   void t3_set_vlan_accel(struct adapter *adapter, unsigned int ports, int on);
>   void t3_config_rss(struct adapter *adapter, unsigned int rss_config,
>   		   const u8 * cpus, const u16 *rspq);
> -int t3_read_rss(struct adapter *adapter, u8 * lkup, u16 *map);
> -int t3_mps_set_active_ports(struct adapter *adap, unsigned int port_mask);
>   int t3_cim_ctl_blk_read(struct adapter *adap, unsigned int addr,
>   			unsigned int n, unsigned int *valp);
>   int t3_mc7_bd_read(struct mc7 *mc7, unsigned int start, unsigned int n,
> @@ -731,19 +724,12 @@ void t3_mc5_prep(struct adapter *adapter
>   int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
>   		unsigned int nroutes);
>   void t3_mc5_intr_handler(struct mc5 *mc5);
> -int t3_read_mc5_range(const struct mc5 *mc5, unsigned int start, unsigned int n,
> -		      u32 *buf);
>
> -int t3_tp_set_coalescing_size(struct adapter *adap, unsigned int size, int psh);
> -void t3_tp_set_max_rxsize(struct adapter *adap, unsigned int size);
>   void t3_tp_set_offload_mode(struct adapter *adap, int enable);
>   void t3_tp_get_mib_stats(struct adapter *adap, struct tp_mib_stats *tps);
>   void t3_load_mtus(struct adapter *adap, unsigned short mtus[NMTUS],
>   		  unsigned short alpha[NCCTRL_WIN],
>   		  unsigned short beta[NCCTRL_WIN], unsigned short mtu_cap);
> -void t3_read_hw_mtus(struct adapter *adap, unsigned short mtus[NMTUS]);
> -void t3_get_cong_cntl_tab(struct adapter *adap,
> -			  unsigned short incr[NMTUS][NCCTRL_WIN]);
>   void t3_config_trace_filter(struct adapter *adapter,
>   			    const struct trace_params *tp, int filter_index,
>   			    int invert, int enable);
> @@ -769,10 +755,6 @@ int t3_sge_enable_ecntxt(struct adapter
>   int t3_sge_disable_fl(struct adapter *adapter, unsigned int id);
>   int t3_sge_disable_rspcntxt(struct adapter *adapter, unsigned int id);
>   int t3_sge_disable_cqcntxt(struct adapter *adapter, unsigned int id);
> -int t3_sge_read_ecntxt(struct adapter *adapter, unsigned int id, u32 data[4]);
> -int t3_sge_read_fl(struct adapter *adapter, unsigned int id, u32 data[4]);
> -int t3_sge_read_cq(struct adapter *adapter, unsigned int id, u32 data[4]);
> -int t3_sge_read_rspq(struct adapter *adapter, unsigned int id, u32 data[4]);
>   int t3_sge_cqcntxt_op(struct adapter *adapter, unsigned int id, unsigned int op,
>   		      unsigned int credits);
>
> --- a/drivers/net/cxgb3/cxgb3_defs.h	2010-10-15 11:17:35.345242098 -0700
> +++ b/drivers/net/cxgb3/cxgb3_defs.h	2010-10-15 11:28:15.233294035 -0700
> @@ -43,8 +43,6 @@
>
>   void *cxgb_alloc_mem(unsigned long size);
>   void cxgb_free_mem(void *addr);
> -void cxgb_neigh_update(struct neighbour *neigh);
> -void cxgb_redirect(struct dst_entry *old, struct dst_entry *new);
>
>   /*
>    * Map an ATID or STID to their entries in the corresponding TID tables.
> @@ -111,7 +109,6 @@ static inline struct t3c_tid_entry *look
>   	return&e->t3c_tid;
>   }
>
> -int process_rx(struct t3cdev *dev, struct sk_buff **skbs, int n);
>   int attach_t3cdev(struct t3cdev *dev);
>   void detach_t3cdev(struct t3cdev *dev);
>   #endif
> --- a/drivers/net/cxgb3/cxgb3_offload.c	2010-10-15 11:12:57.413912920 -0700
> +++ b/drivers/net/cxgb3/cxgb3_offload.c	2010-10-15 11:28:04.412900334 -0700
> @@ -60,6 +60,9 @@ static LIST_HEAD(adapter_list);
>   static const unsigned int MAX_ATIDS = 64 * 1024;
>   static const unsigned int ATID_BASE = 0x10000;
>
> +static void cxgb_neigh_update(struct neighbour *neigh);
> +static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new);
> +
>   static inline int offload_activated(struct t3cdev *tdev)
>   {
>   	const struct adapter *adapter = tdev2adap(tdev);
> @@ -1015,7 +1018,7 @@ EXPORT_SYMBOL(t3_register_cpl_handler);
>   /*
>    * T3CDEV's receive method.
>    */
> -int process_rx(struct t3cdev *dev, struct sk_buff **skbs, int n)
> +static int process_rx(struct t3cdev *dev, struct sk_buff **skbs, int n)
>   {
>   	while (n--) {
>   		struct sk_buff *skb = *skbs++;
> @@ -1070,7 +1073,7 @@ static int is_offloading(struct net_devi
>   	return 0;
>   }
>
> -void cxgb_neigh_update(struct neighbour *neigh)
> +static void cxgb_neigh_update(struct neighbour *neigh)
>   {
>   	struct net_device *dev = neigh->dev;
>
> @@ -1104,7 +1107,7 @@ static void set_l2t_ix(struct t3cdev *td
>   	tdev->send(tdev, skb);
>   }
>
> -void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
> +static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
>   {
>   	struct net_device *olddev, *newdev;
>   	struct tid_info *ti;
> --- a/drivers/net/cxgb3/mc5.c	2010-10-15 11:12:49.041572658 -0700
> +++ b/drivers/net/cxgb3/mc5.c	2010-10-15 11:15:00.746932380 -0700
> @@ -374,44 +374,6 @@ int t3_mc5_init(struct mc5 *mc5, unsigne
>   	return err;
>   }
>
> -/*
> - *	read_mc5_range - dump a part of the memory managed by MC5
> - *	@mc5: the MC5 handle
> - *	@start: the start address for the dump
> - *	@n: number of 72-bit words to read
> - *	@buf: result buffer
> - *
> - *	Read n 72-bit words from MC5 memory from the given start location.
> - */
> -int t3_read_mc5_range(const struct mc5 *mc5, unsigned int start,
> -		      unsigned int n, u32 *buf)
> -{
> -	u32 read_cmd;
> -	int err = 0;
> -	struct adapter *adap = mc5->adapter;
> -
> -	if (mc5->part_type == IDT75P52100)
> -		read_cmd = IDT_CMD_READ;
> -	else if (mc5->part_type == IDT75N43102)
> -		read_cmd = IDT4_CMD_READ;
> -	else
> -		return -EINVAL;
> -
> -	mc5_dbgi_mode_enable(mc5);
> -
> -	while (n--) {
> -		t3_write_reg(adap, A_MC5_DB_DBGI_REQ_ADDR0, start++);
> -		if (mc5_cmd_write(adap, read_cmd)) {
> -			err = -EIO;
> -			break;
> -		}
> -		dbgi_rd_rsp3(adap, buf + 2, buf + 1, buf);
> -		buf += 3;
> -	}
> -
> -	mc5_dbgi_mode_disable(mc5);
> -	return 0;
> -}
>
>   #define MC5_INT_FATAL (F_PARITYERR | F_REQQPARERR | F_DISPQPARERR)
>
> --- a/drivers/net/cxgb3/t3_hw.c	2010-10-15 11:13:07.590326587 -0700
> +++ b/drivers/net/cxgb3/t3_hw.c	2010-10-15 11:26:01.636456578 -0700
> @@ -34,6 +34,8 @@
>   #include "sge_defs.h"
>   #include "firmware_exports.h"
>
> +static void t3_port_intr_clear(struct adapter *adapter, int idx);
> +
>   /**
>    *	t3_wait_op_done_val - wait until an operation is completed
>    *	@adapter: the adapter performing the operation
> @@ -840,8 +842,8 @@ static int flash_wait_op(struct adapter
>    *	(i.e., big-endian), otherwise as 32-bit words in the platform's
>    *	natural endianess.
>    */
> -int t3_read_flash(struct adapter *adapter, unsigned int addr,
> -		  unsigned int nwords, u32 *data, int byte_oriented)
> +static int t3_read_flash(struct adapter *adapter, unsigned int addr,
> +			 unsigned int nwords, u32 *data, int byte_oriented)
>   {
>   	int ret;
>
> @@ -2111,7 +2113,7 @@ void t3_port_intr_disable(struct adapter
>    *	Clear port-specific (i.e., MAC and PHY) interrupts for the given
>    *	adapter port.
>    */
> -void t3_port_intr_clear(struct adapter *adapter, int idx)
> +static void t3_port_intr_clear(struct adapter *adapter, int idx)
>   {
>   	struct cphy *phy =&adap2pinfo(adapter, idx)->phy;
>
> @@ -2484,98 +2486,6 @@ int t3_sge_cqcntxt_op(struct adapter *ad
>   }
>
>   /**
> - * 	t3_sge_read_context - read an SGE context
> - * 	@type: the context type
> - * 	@adapter: the adapter
> - * 	@id: the context id
> - * 	@data: holds the retrieved context
> - *
> - * 	Read an SGE egress context.  The caller is responsible for ensuring
> - * 	only one context operation occurs at a time.
> - */
> -static int t3_sge_read_context(unsigned int type, struct adapter *adapter,
> -			       unsigned int id, u32 data[4])
> -{
> -	if (t3_read_reg(adapter, A_SG_CONTEXT_CMD)&  F_CONTEXT_CMD_BUSY)
> -		return -EBUSY;
> -
> -	t3_write_reg(adapter, A_SG_CONTEXT_CMD,
> -		     V_CONTEXT_CMD_OPCODE(0) | type | V_CONTEXT(id));
> -	if (t3_wait_op_done(adapter, A_SG_CONTEXT_CMD, F_CONTEXT_CMD_BUSY, 0,
> -			    SG_CONTEXT_CMD_ATTEMPTS, 1))
> -		return -EIO;
> -	data[0] = t3_read_reg(adapter, A_SG_CONTEXT_DATA0);
> -	data[1] = t3_read_reg(adapter, A_SG_CONTEXT_DATA1);
> -	data[2] = t3_read_reg(adapter, A_SG_CONTEXT_DATA2);
> -	data[3] = t3_read_reg(adapter, A_SG_CONTEXT_DATA3);
> -	return 0;
> -}
> -
> -/**
> - * 	t3_sge_read_ecntxt - read an SGE egress context
> - * 	@adapter: the adapter
> - * 	@id: the context id
> - * 	@data: holds the retrieved context
> - *
> - * 	Read an SGE egress context.  The caller is responsible for ensuring
> - * 	only one context operation occurs at a time.
> - */
> -int t3_sge_read_ecntxt(struct adapter *adapter, unsigned int id, u32 data[4])
> -{
> -	if (id>= 65536)
> -		return -EINVAL;
> -	return t3_sge_read_context(F_EGRESS, adapter, id, data);
> -}
> -
> -/**
> - * 	t3_sge_read_cq - read an SGE CQ context
> - * 	@adapter: the adapter
> - * 	@id: the context id
> - * 	@data: holds the retrieved context
> - *
> - * 	Read an SGE CQ context.  The caller is responsible for ensuring
> - * 	only one context operation occurs at a time.
> - */
> -int t3_sge_read_cq(struct adapter *adapter, unsigned int id, u32 data[4])
> -{
> -	if (id>= 65536)
> -		return -EINVAL;
> -	return t3_sge_read_context(F_CQ, adapter, id, data);
> -}
> -
> -/**
> - * 	t3_sge_read_fl - read an SGE free-list context
> - * 	@adapter: the adapter
> - * 	@id: the context id
> - * 	@data: holds the retrieved context
> - *
> - * 	Read an SGE free-list context.  The caller is responsible for ensuring
> - * 	only one context operation occurs at a time.
> - */
> -int t3_sge_read_fl(struct adapter *adapter, unsigned int id, u32 data[4])
> -{
> -	if (id>= SGE_QSETS * 2)
> -		return -EINVAL;
> -	return t3_sge_read_context(F_FREELIST, adapter, id, data);
> -}
> -
> -/**
> - * 	t3_sge_read_rspq - read an SGE response queue context
> - * 	@adapter: the adapter
> - * 	@id: the context id
> - * 	@data: holds the retrieved context
> - *
> - * 	Read an SGE response queue context.  The caller is responsible for
> - * 	ensuring only one context operation occurs at a time.
> - */
> -int t3_sge_read_rspq(struct adapter *adapter, unsigned int id, u32 data[4])
> -{
> -	if (id>= SGE_QSETS)
> -		return -EINVAL;
> -	return t3_sge_read_context(F_RESPONSEQ, adapter, id, data);
> -}
> -
> -/**
>    *	t3_config_rss - configure Rx packet steering
>    *	@adapter: the adapter
>    *	@rss_config: RSS settings (written to TP_RSS_CONFIG)
> @@ -2616,42 +2526,6 @@ void t3_config_rss(struct adapter *adapt
>   }
>
>   /**
> - *	t3_read_rss - read the contents of the RSS tables
> - *	@adapter: the adapter
> - *	@lkup: holds the contents of the RSS lookup table
> - *	@map: holds the contents of the RSS map table
> - *
> - *	Reads the contents of the receive packet steering tables.
> - */
> -int t3_read_rss(struct adapter *adapter, u8 * lkup, u16 *map)
> -{
> -	int i;
> -	u32 val;
> -
> -	if (lkup)
> -		for (i = 0; i<  RSS_TABLE_SIZE; ++i) {
> -			t3_write_reg(adapter, A_TP_RSS_LKP_TABLE,
> -				     0xffff0000 | i);
> -			val = t3_read_reg(adapter, A_TP_RSS_LKP_TABLE);
> -			if (!(val&  0x80000000))
> -				return -EAGAIN;
> -			*lkup++ = val;
> -			*lkup++ = (val>>  8);
> -		}
> -
> -	if (map)
> -		for (i = 0; i<  RSS_TABLE_SIZE; ++i) {
> -			t3_write_reg(adapter, A_TP_RSS_MAP_TABLE,
> -				     0xffff0000 | i);
> -			val = t3_read_reg(adapter, A_TP_RSS_MAP_TABLE);
> -			if (!(val&  0x80000000))
> -				return -EAGAIN;
> -			*map++ = val;
> -		}
> -	return 0;
> -}
> -
> -/**
>    *	t3_tp_set_offload_mode - put TP in NIC/offload mode
>    *	@adap: the adapter
>    *	@enable: 1 to select offload mode, 0 for regular NIC
> @@ -2868,7 +2742,8 @@ static void tp_set_timers(struct adapter
>    *
>    *	Set the receive coalescing size and PSH bit handling.
>    */
> -int t3_tp_set_coalescing_size(struct adapter *adap, unsigned int size, int psh)
> +static int t3_tp_set_coalescing_size(struct adapter *adap,
> +				     unsigned int size, int psh)
>   {
>   	u32 val;
>
> @@ -2898,7 +2773,7 @@ int t3_tp_set_coalescing_size(struct ada
>    *	Set TP's max receive size.  This is the limit that applies when
>    *	receive coalescing is disabled.
>    */
> -void t3_tp_set_max_rxsize(struct adapter *adap, unsigned int size)
> +static void t3_tp_set_max_rxsize(struct adapter *adap, unsigned int size)
>   {
>   	t3_write_reg(adap, A_TP_PARA_REG7,
>   		     V_PMMAXXFERLEN0(size) | V_PMMAXXFERLEN1(size));
> @@ -3018,48 +2893,6 @@ void t3_load_mtus(struct adapter *adap,
>   }
>
>   /**
> - *	t3_read_hw_mtus - returns the values in the HW MTU table
> - *	@adap: the adapter
> - *	@mtus: where to store the HW MTU values
> - *
> - *	Reads the HW MTU table.
> - */
> -void t3_read_hw_mtus(struct adapter *adap, unsigned short mtus[NMTUS])
> -{
> -	int i;
> -
> -	for (i = 0; i<  NMTUS; ++i) {
> -		unsigned int val;
> -
> -		t3_write_reg(adap, A_TP_MTU_TABLE, 0xff000000 | i);
> -		val = t3_read_reg(adap, A_TP_MTU_TABLE);
> -		mtus[i] = val&  0x3fff;
> -	}
> -}
> -
> -/**
> - *	t3_get_cong_cntl_tab - reads the congestion control table
> - *	@adap: the adapter
> - *	@incr: where to store the alpha values
> - *
> - *	Reads the additive increments programmed into the HW congestion
> - *	control table.
> - */
> -void t3_get_cong_cntl_tab(struct adapter *adap,
> -			  unsigned short incr[NMTUS][NCCTRL_WIN])
> -{
> -	unsigned int mtu, w;
> -
> -	for (mtu = 0; mtu<  NMTUS; ++mtu)
> -		for (w = 0; w<  NCCTRL_WIN; ++w) {
> -			t3_write_reg(adap, A_TP_CCTRL_TABLE,
> -				     0xffff0000 | (mtu<<  5) | w);
> -			incr[mtu][w] = t3_read_reg(adap, A_TP_CCTRL_TABLE)&
> -				       0x1fff;
> -		}
> -}
> -
> -/**
>    *	t3_tp_get_mib_stats - read TP's MIB counters
>    *	@adap: the adapter
>    *	@tps: holds the returned counter values
> @@ -3223,15 +3056,6 @@ static int tp_init(struct adapter *adap,
>   	return busy;
>   }
>
> -int t3_mps_set_active_ports(struct adapter *adap, unsigned int port_mask)
> -{
> -	if (port_mask&  ~((1<<  adap->params.nports) - 1))
> -		return -EINVAL;
> -	t3_set_reg_field(adap, A_MPS_CFG, F_PORT1ACTIVE | F_PORT0ACTIVE,
> -			 port_mask<<  S_PORT0ACTIVE);
> -	return 0;
> -}
> -
>   /*
>    * Perform the bits of HW initialization that are dependent on the Tx
>    * channels being used.
> @@ -3687,7 +3511,7 @@ static void mc7_prep(struct adapter *ada
>   	mc7->width = G_WIDTH(cfg);
>   }
>
> -void mac_prep(struct cmac *mac, struct adapter *adapter, int index)
> +static void mac_prep(struct cmac *mac, struct adapter *adapter, int index)
>   {
>   	u16 devid;
>
> @@ -3707,7 +3531,8 @@ void mac_prep(struct cmac *mac, struct a
>   	}
>   }
>
> -void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
> +static void early_hw_init(struct adapter *adapter,
> +			  const struct adapter_info *ai)
>   {
>   	u32 val = V_PORTSPEED(is_10G(adapter) ? 3 : 2);
>
> --- a/drivers/net/cxgb3/adapter.h	2010-10-15 11:29:31.428075569 -0700
> +++ b/drivers/net/cxgb3/adapter.h	2010-10-15 11:29:46.280619610 -0700
> @@ -336,9 +336,6 @@ int t3_sge_alloc_qset(struct adapter *ad
>   		      int irq_vec_idx, const struct qset_params *p,
>   		      int ntxq, struct net_device *dev,
>   		      struct netdev_queue *netdevq);
> -int t3_get_desc(const struct sge_qset *qs, unsigned int qnum, unsigned int idx,
> -		unsigned char *data);
> -irqreturn_t t3_sge_intr_msix(int irq, void *cookie);
>   extern struct workqueue_struct *cxgb3_wq;
>
>   int t3_get_edc_fw(struct cphy *phy, int edc_idx, int size);
> --- a/drivers/net/cxgb3/sge.c	2010-10-15 11:13:02.710128196 -0700
> +++ b/drivers/net/cxgb3/sge.c	2010-10-15 11:30:17.141751919 -0700
> @@ -2554,7 +2554,7 @@ static inline int handle_responses(struc
>    * The MSI-X interrupt handler for an SGE response queue for the non-NAPI case
>    * (i.e., response queue serviced in hard interrupt).
>    */
> -irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
> +static irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
>   {
>   	struct sge_qset *qs = cookie;
>   	struct adapter *adap = qs->adap;
> @@ -3320,40 +3320,3 @@ void t3_sge_prep(struct adapter *adap, s
>
>   	spin_lock_init(&adap->sge.reg_lock);
>   }
> -
> -/**
> - *	t3_get_desc - dump an SGE descriptor for debugging purposes
> - *	@qs: the queue set
> - *	@qnum: identifies the specific queue (0..2: Tx, 3:response, 4..5: Rx)
> - *	@idx: the descriptor index in the queue
> - *	@data: where to dump the descriptor contents
> - *
> - *	Dumps the contents of a HW descriptor of an SGE queue.  Returns the
> - *	size of the descriptor.
> - */
> -int t3_get_desc(const struct sge_qset *qs, unsigned int qnum, unsigned int idx,
> -		unsigned char *data)
> -{
> -	if (qnum>= 6)
> -		return -EINVAL;
> -
> -	if (qnum<  3) {
> -		if (!qs->txq[qnum].desc || idx>= qs->txq[qnum].size)
> -			return -EINVAL;
> -		memcpy(data,&qs->txq[qnum].desc[idx], sizeof(struct tx_desc));
> -		return sizeof(struct tx_desc);
> -	}
> -
> -	if (qnum == 3) {
> -		if (!qs->rspq.desc || idx>= qs->rspq.size)
> -			return -EINVAL;
> -		memcpy(data,&qs->rspq.desc[idx], sizeof(struct rsp_desc));
> -		return sizeof(struct rsp_desc);
> -	}
> -
> -	qnum -= 4;
> -	if (!qs->fl[qnum].desc || idx>= qs->fl[qnum].size)
> -		return -EINVAL;
> -	memcpy(data,&qs->fl[qnum].desc[idx], sizeof(struct rx_desc));
> -	return sizeof(struct rx_desc);
> -}
>
>
>

