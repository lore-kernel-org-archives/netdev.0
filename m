From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH 2/3] cxgb4i_v3: main driver files
Date: Thu, 27 May 2010 02:38:27 -0500
Message-ID: <4BFE2173.4050306@cs.wisc.edu>
References: <1273944249-311-1-git-send-email-rakesh@chelsio.com> <1273944249-311-2-git-send-email-rakesh@chelsio.com> <1273944249-311-3-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, NETDEVML <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        SCSIDEVML <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Rakesh Ranjan <rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCLPJla3WGRCYwvjfBBoEQTB-tQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1273944249-311-3-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 05/15/2010 12:24 PM, Rakesh Ranjan wrote:
> From: Rakesh Ranjan<rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>
>
> Signed-off-by: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> ---
>   drivers/scsi/cxgb4i/cxgb4i.h         |  101 ++
>   drivers/scsi/cxgb4i/cxgb4i_ddp.c     |  678 +++++++++++++
>   drivers/scsi/cxgb4i/cxgb4i_ddp.h     |  118 +++
>   drivers/scsi/cxgb4i/cxgb4i_offload.c | 1846 ++++++++++++++++++++++++++++++++++
>   drivers/scsi/cxgb4i/cxgb4i_offload.h |   91 ++
>   drivers/scsi/cxgb4i/cxgb4i_snic.c    |  260 +++++
>   6 files changed, 3094 insertions(+), 0 deletions(-)
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i.h
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_ddp.c
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_ddp.h
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_offload.c
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_offload.h
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_snic.c



Got some whitespace errors when applying.

warning: squelched 1 whitespace error
warning: 6 lines add whitespace errors.



> +#define	CXGB4I_SCSI_HOST_QDEPTH	1024
> +#define	CXGB4I_MAX_TARGET	CXGB4I_MAX_CONN
> +#define	CXGB4I_MAX_LUN		512

Is the max lun right? It seems kinda small for modern drivers.



> +
> +static inline void cxgb4i_ddp_ulp_mem_io_set_hdr(struct ulp_mem_io *req,


If you build cxgb3i and cxgb4i in the kernel at the same time, will you 
get problems if each driver has structs that are named the same?


> +
> +static inline int cxgb4i_ddp_find_unused_entries(struct cxgb4i_ddp_info *ddp,
> +					unsigned int start, unsigned int max,
> +					unsigned int count,
> +					struct cxgbi_gather_list *gl)
> +{
> +	unsigned int i, j, k;
> +
> +	/*  not enough entries */
> +	if ((max - start)<  count)
> +		return -EBUSY;
> +
> +	max -= count;
> +	spin_lock(&ddp->map_lock);
> +	for (i = start; i<  max;) {
> +		for (j = 0, k = i; j<  count; j++, k++) {
> +			if (ddp->gl_map[k])
> +				break;
> +		}
> +		if (j == count) {
> +			for (j = 0, k = i; j<  count; j++, k++)
> +				ddp->gl_map[k] = gl;
> +			spin_unlock(&ddp->map_lock);
> +			return i;
> +		}


Is there a more efficient bitmap or some sort of common map operation 
for this (I thought we found something when doing cxgb3i but forgot to 
add it or were testing a patch)?



> +		i += j + 1;
> +	}
> +	spin_unlock(&ddp->map_lock);
> +	return -EBUSY;
> +}
> +
> +static inline void cxgb4i_ddp_unmark_entries(struct cxgb4i_ddp_info *ddp,
> +							int start, int count)
> +{
> +	spin_lock(&ddp->map_lock);
> +	memset(&ddp->gl_map[start], 0,
> +			count * sizeof(struct cxgbi_gather_list *));

extra tab.



> +static void __cxgb4i_ddp_init(struct cxgb4i_snic *snic)
> +{
> +	struct cxgb4i_ddp_info *ddp = snic->ddp;
> +	unsigned int ppmax, bits, tagmask, pgsz_factor[4];
> +	int i;
> +
> +	if (ddp) {
> +		kref_get(&ddp->refcnt);
> +		cxgbi_log_warn("snic 0x%p, ddp 0x%p already set up\n",
> +				snic, snic->ddp);
> +		return;
> +	}
> +
> +	sw_tag_idx_bits = (__ilog2_u32(ISCSI_ITT_MASK)) + 1;
> +	sw_tag_age_bits = (__ilog2_u32(ISCSI_AGE_MASK)) + 1;
> +	snic->cdev.tag_format.sw_bits = sw_tag_idx_bits + sw_tag_age_bits;
> +
> +	cxgbi_log_info("tag itt 0x%x, %u bits, age 0x%x, %u bits\n",
> +			ISCSI_ITT_MASK, sw_tag_idx_bits,
> +			ISCSI_AGE_MASK, sw_tag_age_bits);
> +
> +	ppmax = (snic->lldi.vr->iscsi.size>>  PPOD_SIZE_SHIFT);
> +	bits = __ilog2_u32(ppmax) + 1;
> +	if (bits>  PPOD_IDX_MAX_SIZE)
> +		bits = PPOD_IDX_MAX_SIZE;
> +	ppmax = (1<<  (bits - 1)) - 1;
> +
> +	ddp = cxgbi_alloc_big_mem(sizeof(struct cxgb4i_ddp_info) +
> +			ppmax * (sizeof(struct cxgbi_gather_list *) +
> +				sizeof(struct sk_buff *)),
> +				GFP_KERNEL);
> +	if (!ddp) {
> +		cxgbi_log_warn("snic 0x%p unable to alloc ddp 0x%d, "
> +			       "ddp disabled\n", snic, ppmax);
> +		return;
> +	}
> +
> +	ddp->gl_map = (struct cxgbi_gather_list **)(ddp + 1);
> +	spin_lock_init(&ddp->map_lock);
> +	kref_init(&ddp->refcnt);
> +
> +	ddp->snic = snic;
> +	ddp->pdev = snic->lldi.pdev;
> +	ddp->max_txsz = min_t(unsigned int,
> +				snic->lldi.iscsi_iolen,
> +				ULP2_MAX_PKT_SIZE);
> +	ddp->max_rxsz = min_t(unsigned int,
> +				snic->lldi.iscsi_iolen,
> +				ULP2_MAX_PKT_SIZE);
> +	ddp->llimit = snic->lldi.vr->iscsi.start;
> +	ddp->ulimit = ddp->llimit + snic->lldi.vr->iscsi.size;
> +	ddp->nppods = ppmax;
> +	ddp->idx_last = ppmax;
> +	ddp->idx_bits = bits;
> +	ddp->idx_mask = (1<<  bits) - 1;
> +	ddp->rsvd_tag_mask = (1<<  (bits + PPOD_IDX_SHIFT)) - 1;
> +
> +	tagmask = ddp->idx_mask<<  PPOD_IDX_SHIFT;
> +	for (i = 0; i<  DDP_PGIDX_MAX; i++)
> +		pgsz_factor[i] = ddp_page_order[i];
> +
> +	cxgb4_iscsi_init(snic->lldi.ports[0], tagmask, pgsz_factor);
> +	snic->ddp = ddp;
> +
> +	snic->cdev.tag_format.rsvd_bits = ddp->idx_bits;
> +	snic->cdev.tag_format.rsvd_shift = PPOD_IDX_SHIFT;
> +	snic->cdev.tag_format.rsvd_mask =
> +		((1<<  snic->cdev.tag_format.rsvd_bits) - 1);
> +
> +	cxgbi_log_info("tag format: sw %u, rsvd %u,%u, mask 0x%x.\n",
> +			snic->cdev.tag_format.sw_bits,
> +			snic->cdev.tag_format.rsvd_bits,
> +			snic->cdev.tag_format.rsvd_shift,
> +			snic->cdev.tag_format.rsvd_mask);
> +
> +	snic->tx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
> +				ddp->max_txsz - ISCSI_PDU_NONPAYLOAD_LEN);
> +	snic->rx_max_size = min_t(unsigned int, ULP2_MAX_PDU_PAYLOAD,
> +				ddp->max_rxsz - ISCSI_PDU_NONPAYLOAD_LEN);
> +
> +	cxgbi_log_info("max payload size: %u/%u, %u/%u.\n",
> +			snic->tx_max_size, ddp->max_txsz,
> +			snic->rx_max_size, ddp->max_rxsz);
> +
> +	cxgbi_log_info("snic 0x%p, nppods %u, bits %u, mask 0x%x,0x%x "
> +			"pkt %u/%u, %u/%u\n",
> +			snic, ppmax, ddp->idx_bits, ddp->idx_mask,
> +			ddp->rsvd_tag_mask, ddp->max_txsz,
> +			snic->lldi.iscsi_iolen,
> +			ddp->max_rxsz, snic->lldi.iscsi_iolen);
> +
> +	return;


Don't need "return".





> +static void cxgbi_conn_pdu_ready(struct cxgbi_sock *csk)
> +{


Were you going to put this in the libcxgbi but later decide it was a 
little too different? If you are leaving it here could you add a cxgb4i 
prefix so the naming is consistent and avoid confusion with your lib 
functions?



cxgb4i_find_best_mtu looks like it could go in your lib. Looks like 
find_best_mtu from cxgb3i_offload.c. Same with select_mss and compute_wscale


> +	struct sk_buff *skb;
> +	unsigned int read = 0;
> +	struct iscsi_conn *conn = csk->user_data;
> +	int err = 0;
> +
> +	cxgbi_rx_debug("csk 0x%p.\n", csk);
> +
> +	read_lock(&csk->callback_lock);
> +	if (unlikely(!conn || conn->suspend_rx)) {
> +		cxgbi_rx_debug("conn 0x%p, id %d, suspend_rx %lu!\n",
> +				conn, conn ? conn->id : 0xFF,
> +				conn ? conn->suspend_rx : 0xFF);
> +		read_unlock(&csk->callback_lock);
> +		return;
> +	}
> +	skb = skb_peek(&csk->receive_queue);
> +	while (!err&&  skb) {
> +		__skb_unlink(skb,&csk->receive_queue);
> +		read += cxgb4i_skb_rx_pdulen(skb);
> +		cxgbi_rx_debug("conn 0x%p, csk 0x%p, rx skb 0x%p, pdulen %u\n",
> +				conn, csk, skb, cxgb4i_skb_rx_pdulen(skb));
> +		if (cxgb4i_skb_flags(skb)&  CXGB4I_SKCB_FLAG_HDR_RCVD)
> +			err = cxgbi_conn_read_bhs_pdu_skb(conn, skb);
> +		else if (cxgb4i_skb_flags(skb) == CXGB4I_SKCB_FLAG_DATA_RCVD)
> +			err = cxgbi_conn_read_data_pdu_skb(conn, skb);
> +		__kfree_skb(skb);
> +		skb = skb_peek(&csk->receive_queue);
> +	}
> +	read_unlock(&csk->callback_lock);
> +	csk->copied_seq += read;
> +	cxgb4i_sock_rx_credits(csk, read);
> +	conn->rxdata_octets += read;
> +
> +	if (err) {
> +		cxgbi_log_info("conn 0x%p rx failed err %d.\n", conn, err);
> +		iscsi_conn_failure(conn, ISCSI_ERR_CONN_FAILED);
> +	}
> +}





> +
> +static inline void cxgb4i_sock_free_wr_skb(struct sk_buff *skb)
> +{
> +	kfree_skb(skb);
> +}


I think adding wrappers around skb functions in a net driver is not so 
useful.


> +
> +static inline struct sk_buff *cxgb4i_sock_dequeue_wr(struct cxgbi_sock *csk)
> +{
> +	struct sk_buff *skb = csk->wr_pending_head;
> +
> +	if (likely(skb)) {
> +		csk->wr_pending_head = cxgb4i_skb_tx_wr_next(skb);
> +		cxgb4i_skb_tx_wr_next(skb) = NULL;
> +	}
> +	return skb;
> +}
> +
> +static void cxgb4i_sock_purge_wr_queue(struct cxgbi_sock *csk)
> +{
> +	struct sk_buff *skb;
> +
> +	while ((skb = cxgb4i_sock_dequeue_wr(csk)) != NULL)
> +		cxgb4i_sock_free_wr_skb(skb);
> +}
> +
> +/*

I think this is supposed to be

/**


> +static int cxgb4i_sock_push_tx_frames(struct cxgbi_sock *csk,
> +						int req_completion)
> +{
> +	int total_size = 0;
> +	struct sk_buff *skb;
> +	struct cxgb4i_snic *snic;
> +
> +	if (unlikely(csk->state == CXGBI_CSK_ST_CONNECTING ||
> +				csk->state == CXGBI_CSK_ST_CLOSE_WAIT_1 ||
> +				csk->state>= CXGBI_CSK_ST_ABORTING)) {
> +		cxgbi_tx_debug("csk 0x%p, in closing state %u.\n",
> +				csk, csk->state);
> +		return 0;
> +	}
> +
> +	snic = cxgb4i_get_snic(csk->cdev);
> +
> +	while (csk->wr_cred
> +			&&  (skb = skb_peek(&csk->write_queue)) != NULL) {


The && should be on the right

while (csk->wr_cred &&

> +
> +static int cxgb4i_cpl_act_open_rpl(struct cxgb4i_snic *snic,
> +						struct sk_buff *skb)
> +{
> +	struct cxgbi_sock *csk;
> +	struct cpl_act_open_rpl *rpl = cplhdr(skb);
> +	unsigned int atid =
> +		GET_TID_TID(GET_AOPEN_ATID(be32_to_cpu(rpl->atid_status)));
> +	struct tid_info *t = snic->lldi.tids;
> +	unsigned int status = GET_AOPEN_STATUS(be32_to_cpu(rpl->atid_status));
> +
> +	csk = lookup_atid(t, atid);
> +
> +	if (unlikely(!csk)) {
> +		cxgbi_log_error("can't find connection for tid %u\n", atid);
> +		return CPL_RET_UNKNOWN_TID;
> +	}
> +
> +	cxgbi_sock_hold(csk);
> +	spin_lock_bh(&csk->lock);
> +
> +	cxgbi_conn_debug("rcv, status 0x%x, csk 0x%p, csk->state %u, "
> +			"csk->flag 0x%lx, csk->atid %u.\n",
> +			status, csk, csk->state, csk->flags, csk->hwtid);
> +
> +	if (status&  act_open_has_tid(status))
> +		cxgb4_remove_tid(snic->lldi.tids, csk->port_id, GET_TID(rpl));
> +
> +	if (status == CPL_ERR_CONN_EXIST&&
> +			csk->retry_timer.function !=
> +			cxgb4i_sock_act_open_retry_timer) {


I do not mean to nit pick on silly coding style stuff. I think it is 
easier to read lines like this:

if (status == CPL_ERR_CONN_EXIST&&
     csk->retry_timer.function != cxgb4i_sock_act_open_retry_timer) {


> +		csk->retry_timer.function = cxgb4i_sock_act_open_retry_timer;
> +		if (!mod_timer(&csk->retry_timer, jiffies + HZ / 2))
> +			cxgbi_sock_hold(csk);


There is no del_timer/del_timer_sync + cxgbi_sock_put for this timer. If 
something cleans this csk up, what makes sure the timer gets stopped ok.

> +
> +static int cxgb4i_alloc_cpl_skbs(struct cxgbi_sock *csk)
> +{
> +	csk->cpl_close = alloc_skb(sizeof(struct cpl_close_con_req),
> +					GFP_KERNEL);
> +	if (!csk->cpl_close)
> +		return -ENOMEM;
> +	skb_put(csk->cpl_close, sizeof(struct cpl_close_con_req));
> +
> +	csk->cpl_abort_req = alloc_skb(sizeof(struct cpl_abort_req),
> +					GFP_KERNEL);
> +	if (!csk->cpl_abort_req)
> +		goto free_cpl_skbs;
> +	skb_put(csk->cpl_abort_req, sizeof(struct cpl_abort_req));
> +
> +	csk->cpl_abort_rpl = alloc_skb(sizeof(struct cpl_abort_rpl),
> +					GFP_KERNEL);


These should be GFP_NOIO in case we call them to relogin on a disk that 
has data that would have been needed to be written out to free up mem.

> +
> +struct cxgbi_sock *cxgb4i_sock_create(struct cxgb4i_snic *snic)
> +{
> +	struct cxgbi_sock *csk = NULL;
> +
> +	csk = kzalloc(sizeof(*csk), GFP_KERNEL);

Same as above.

> +
> +static int is_cxgb4_dev(struct net_device *dev, struct cxgb4i_snic *snic)
> +{
> +	struct net_device *ndev = dev;
> +	int i;
> +
> +	if (dev->priv_flags&  IFF_802_1Q_VLAN)
> +		ndev = vlan_dev_real_dev(dev);
> +
> +	for (i = 0; i<  snic->lldi.nports; i++) {
> +		if (ndev == snic->lldi.ports[i])
> +			return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +static struct net_device *cxgb4i_find_egress_dev(struct net_device *root_dev,
> +						struct cxgb4i_snic *snic)
> +{
> +	while (root_dev) {
> +		if (root_dev->priv_flags&  IFF_802_1Q_VLAN)
> +			root_dev = vlan_dev_real_dev(root_dev);
> +		else if (is_cxgb4_dev(root_dev, snic))
> +			return root_dev;
> +		else
> +			return NULL;
> +	}
> +
> +	return NULL;
> +}
> +
> +static struct rtable *find_route(struct net_device *dev,
> +				__be32 saddr, __be32 daddr,
> +				__be16 sport, __be16 dport,
> +				u8 tos)
> +{
> +	struct rtable *rt;
> +	struct flowi fl = {
> +		.oif = dev ? dev->ifindex : 0,
> +		.nl_u = {
> +			.ip4_u = {
> +				.daddr = daddr,
> +				.saddr = saddr,
> +				.tos = tos }
> +			},
> +		.proto = IPPROTO_TCP,
> +		.uli_u = {
> +			.ports = {
> +				.sport = sport,
> +				.dport = dport }
> +			}
> +	};
> +
> +	if (ip_route_output_flow(dev ? dev_net(dev) :&init_net,
> +					&rt,&fl, NULL, 0))
> +		return NULL;
> +
> +	return rt;
> +}
> +


Those functions above look like the cxgb3i ones. Could they be in your lib?



> +static int cxgb4i_init_act_open(struct cxgbi_sock *csk,
> +					struct net_device *dev)
> +{
> +	struct dst_entry *dst = csk->dst;
> +	struct sk_buff *skb;
> +	struct port_info *pi = netdev_priv(dev);
> +
> +	cxgbi_conn_debug("csk 0x%p, state %u, flags 0x%lx\n",
> +			csk, csk->state, csk->flags);
> +
> +	csk->atid = cxgb4_alloc_atid(cxgb4i_get_snic(csk->cdev)->lldi.tids,
> +					csk);
> +	if (csk->atid == -1) {
> +		cxgbi_log_error("cannot alloc atid\n");
> +		goto out_err;
> +	}
> +
> +	csk->l2t = cxgb4_l2t_get(cxgb4i_get_snic(csk->cdev)->lldi.l2t,
> +				csk->dst->neighbour, dev, 0);
> +	if (!csk->l2t) {
> +		cxgbi_log_error("cannot alloc l2t\n");
> +		goto free_atid;
> +	}
> +
> +	skb = alloc_skb(sizeof(struct cpl_act_open_req), GFP_KERNEL);
> +	if (!skb)


Should be NOIO too.

> +		goto free_l2t;
> +
> +	skb->sk = (struct sock *)csk;
> +	t4_set_arp_err_handler(skb, csk, cxgb4i_act_open_req_arp_failure);
> +
> +	cxgbi_sock_hold(csk);
> +
> +	csk->wr_max_cred = csk->wr_cred =
> +		cxgb4i_get_snic(csk->cdev)->lldi.wr_cred;
> +	csk->port_id = pi->port_id;
> +	csk->rss_qid = cxgb4i_get_snic(csk->cdev)->lldi.rxq_ids[csk->port_id];
> +	csk->tx_chan = pi->tx_chan;
> +	csk->smac_idx = csk->tx_chan<<  1;
> +	csk->wr_una_cred = 0;
> +	csk->mss_idx = cxgb4i_select_mss(csk, dst_mtu(dst));
> +	csk->err = 0;
> +
> +	cxgb4i_sock_reset_wr_list(csk);
> +
> +	cxgb4i_sock_make_act_open_req(csk, skb,
> +					((csk->rss_qid<<  14) |
> +					 (csk->atid)), csk->l2t);
> +	cxgb4_l2t_send(cxgb4i_get_snic(csk->cdev)->lldi.ports[csk->port_id],
> +					skb, csk->l2t);
> +	return 0;
> +
> +free_l2t:
> +	cxgb4_l2t_release(csk->l2t);
> +
> +free_atid:
> +	cxgb4_free_atid(cxgb4i_get_snic(csk->cdev)->lldi.tids, csk->atid);
> +
> +out_err:
> +
> +	return -EINVAL;;
> +}
> +
> +static struct net_device *cxgb4i_find_dev(struct net_device *dev,
> +							__be32 ipaddr)
> +{
> +	struct flowi fl;
> +	struct rtable *rt;
> +	int err;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	fl.nl_u.ip4_u.daddr = ipaddr;
> +
> +	err = ip_route_output_key(dev ? dev_net(dev) :&init_net,&rt,&fl);
> +	if (!err)
> +		return (&rt->u.dst)->dev;
> +
> +	return NULL;
> +}
> +


Looks like cxgb3i one.


> +int cxgb4i_sock_connect(struct net_device *dev, struct cxgbi_sock *csk,
> +						struct sockaddr_in *sin)
> +{
> +	struct rtable *rt;
> +	__be32 sipv4 = 0;
> +	struct net_device *dstdev;
> +	struct cxgbi_hba *chba = NULL;
> +	int err;
> +
> +	cxgbi_conn_debug("csk 0x%p, dev 0x%p\n", csk, dev);
> +
> +	if (sin->sin_family != AF_INET)
> +		return -EAFNOSUPPORT;
> +
> +	csk->daddr.sin_port = sin->sin_port;
> +	csk->daddr.sin_addr.s_addr = sin->sin_addr.s_addr;
> +
> +	dstdev = cxgb4i_find_dev(dev, sin->sin_addr.s_addr);
> +	if (!dstdev || !is_cxgb4_dev(dstdev, cxgb4i_get_snic(csk->cdev)))
> +		return -ENETUNREACH;
> +
> +	if (dstdev->priv_flags&  IFF_802_1Q_VLAN)
> +		dev = dstdev;
> +
> +	rt = find_route(dev, csk->saddr.sin_addr.s_addr,
> +			csk->daddr.sin_addr.s_addr,
> +			csk->saddr.sin_port,
> +			csk->daddr.sin_port,
> +			0);
> +	if (rt == NULL) {
> +		cxgbi_conn_debug("no route to %pI4, port %u, dev %s, "
> +					"snic 0x%p\n",
> +					&csk->daddr.sin_addr.s_addr,
> +					ntohs(csk->daddr.sin_port),
> +					dev ? dev->name : "any",
> +					csk->snic);
> +		return -ENETUNREACH;
> +	}
> +
> +	if (rt->rt_flags&  (RTCF_MULTICAST | RTCF_BROADCAST)) {
> +		cxgbi_conn_debug("multi-cast route to %pI4, port %u, "
> +					"dev %s, snic 0x%p\n",
> +					&csk->daddr.sin_addr.s_addr,
> +					ntohs(csk->daddr.sin_port),
> +					dev ? dev->name : "any",
> +					csk->snic);
> +		ip_rt_put(rt);
> +		return -ENETUNREACH;
> +	}
> +
> +	if (!csk->saddr.sin_addr.s_addr)
> +		csk->saddr.sin_addr.s_addr = rt->rt_src;
> +
> +	csk->dst =&rt->u.dst;
> +
> +	dev = cxgb4i_find_egress_dev(csk->dst->dev,
> +					cxgb4i_get_snic(csk->cdev));
> +	if (dev == NULL) {
> +		cxgbi_conn_debug("csk: 0x%p, egress dev NULL\n", csk);
> +		return -ENETUNREACH;
> +	}
> +
> +	err = cxgbi_sock_get_port(csk);
> +	if (err)
> +		return err;
> +
> +	cxgbi_conn_debug("csk: 0x%p get port: %u\n",
> +			csk, ntohs(csk->saddr.sin_port));
> +
> +	chba = cxgb4i_hba_find_by_netdev(csk->dst->dev);
> +
> +	sipv4 = cxgb4i_get_iscsi_ipv4(chba);
> +	if (!sipv4) {
> +		cxgbi_conn_debug("csk: 0x%p, iscsi is not configured\n", csk);
> +		sipv4 = csk->saddr.sin_addr.s_addr;
> +		cxgb4i_set_iscsi_ipv4(chba, sipv4);
> +	} else
> +		csk->saddr.sin_addr.s_addr = sipv4;
> +
> +	cxgbi_conn_debug("csk: 0x%p, %pI4:[%u], %pI4:[%u] SYN_SENT\n",
> +				csk,
> +				&csk->saddr.sin_addr.s_addr,
> +				ntohs(csk->saddr.sin_port),
> +				&csk->daddr.sin_addr.s_addr,
> +				ntohs(csk->daddr.sin_port));
> +
> +	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CONNECTING);
> +
> +	if (!cxgb4i_init_act_open(csk, dev))
> +		return 0;
> +
> +	err = -ENOTSUPP;
> +
> +	cxgbi_conn_debug("csk 0x%p ->  closed\n", csk);
> +	cxgbi_sock_set_state(csk, CXGBI_CSK_ST_CLOSED);
> +	ip_rt_put(rt);
> +	cxgbi_sock_put_port(csk);
> +
> +	return err;
> +}
> +
> +void cxgb4i_sock_rx_credits(struct cxgbi_sock *csk, int copied)
> +{
> +	int must_send;
> +	u32 credits;
> +
> +	if (csk->state != CXGBI_CSK_ST_ESTABLISHED)
> +		return;
> +
> +	credits = csk->copied_seq - csk->rcv_wup;
> +	if (unlikely(!credits))
> +		return;
> +
> +	if (unlikely(cxgb4i_rx_credit_thres == 0))
> +		return;
> +
> +	must_send = credits + 16384>= cxgb4i_rcv_win;
> +
> +	if (must_send || credits>= cxgb4i_rx_credit_thres)
> +		csk->rcv_wup += cxgb4i_csk_send_rx_credits(csk, credits);
> +}
> +
> +int cxgb4i_sock_send_pdus(struct cxgbi_sock *csk, struct sk_buff *skb)
> +{
> +	struct sk_buff *next;
> +	int err, copied = 0;
> +
> +	spin_lock_bh(&csk->lock);
> +
> +	if (csk->state != CXGBI_CSK_ST_ESTABLISHED) {
> +		cxgbi_tx_debug("csk 0x%p, not in est. state %u.\n",
> +			      csk, csk->state);
> +		err = -EAGAIN;
> +		goto out_err;
> +	}
> +
> +	if (csk->err) {
> +		cxgbi_tx_debug("csk 0x%p, err %d.\n", csk, csk->err);
> +		err = -EPIPE;
> +		goto out_err;
> +	}
> +
> +	if (csk->write_seq - csk->snd_una>= cxgb4i_snd_win) {
> +		cxgbi_tx_debug("csk 0x%p, snd %u - %u>  %u.\n",
> +				csk, csk->write_seq, csk->snd_una,
> +				cxgb4i_snd_win);
> +		err = -ENOBUFS;
> +		goto out_err;
> +	}
> +
> +	while (skb) {
> +		int frags = skb_shinfo(skb)->nr_frags +
> +				(skb->len != skb->data_len);
> +
> +		if (unlikely(skb_headroom(skb)<  CXGB4I_TX_HEADER_LEN)) {
> +			cxgbi_tx_debug("csk 0x%p, skb head.\n", csk);
> +			err = -EINVAL;
> +			goto out_err;
> +		}
> +
> +		if (frags>= SKB_WR_LIST_SIZE) {
> +			cxgbi_log_error("csk 0x%p, tx frags %d, len %u,%u.\n",
> +					 csk, skb_shinfo(skb)->nr_frags,
> +					 skb->len, skb->data_len);
> +			err = -EINVAL;
> +			goto out_err;
> +		}
> +
> +		next = skb->next;
> +		skb->next = NULL;
> +		cxgb4i_sock_skb_entail(csk, skb,
> +				CXGB4I_SKCB_FLAG_NO_APPEND |
> +				CXGB4I_SKCB_FLAG_NEED_HDR);
> +		copied += skb->len;
> +		csk->write_seq += skb->len + ulp_extra_len(skb);
> +		skb = next;
> +	}
> +done:
> +	if (likely(skb_queue_len(&csk->write_queue)))
> +		cxgb4i_sock_push_tx_frames(csk, 1);
> +	spin_unlock_bh(&csk->lock);
> +	return copied;
> +
> +out_err:
> +	if (copied == 0&&  err == -EPIPE)
> +		copied = csk->err ? csk->err : -EPIPE;
> +	else
> +		copied = err;
> +	goto done;
> +}

Looks similar to cxgb3i one.


> +
> +static void cxgbi_sock_conn_closing(struct cxgbi_sock *csk)
> +{

Was this going to the lib? Looks like the cxgb3i one. If not then rename 
it to avoid confusion.


> +
> +struct cxgbi_hba *cxgb4i_hba_find_by_netdev(struct net_device *dev)
> +{
> +	int i;
> +	struct cxgb4i_snic *snic = NULL;;
> +
> +	if (dev->priv_flags&  IFF_802_1Q_VLAN)
> +		dev = vlan_dev_real_dev(dev);
> +
> +	mutex_lock(&snic_rwlock);
> +	list_for_each_entry(snic,&snic_list, list_head) {
> +		for (i = 0; i<  snic->hba_cnt; i++) {
> +			if (snic->hba[i]->ndev == dev) {
> +				mutex_unlock(&snic_rwlock);
> +				return snic->hba[i];
> +			}
> +		}
> +	}
> +	mutex_unlock(&snic_rwlock);
> +	return NULL;


Looks like cxgb3i_hba_find_by_netdev.

> +}
> +
> +struct cxgb4i_snic *cxgb4i_find_snic(struct net_device *dev, __be32 ipaddr)
> +{
> +	struct flowi fl;
> +	struct rtable *rt;
> +	struct net_device *sdev = NULL;
> +	struct cxgb4i_snic *snic = NULL, *tmp;
> +	int err, i;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	fl.nl_u.ip4_u.daddr = ipaddr;
> +
> +	err = ip_route_output_key(dev ? dev_net(dev) :&init_net,&rt,&fl);
> +	if (err)
> +		goto out;
> +
> +	sdev = (&rt->u.dst)->dev;
> +	mutex_lock(&snic_rwlock);
> +	list_for_each_entry_safe(snic, tmp,&snic_list, list_head) {
> +		if (snic) {
> +			for (i = 0; i<  snic->lldi.nports; i++) {
> +				if (sdev == snic->lldi.ports[i]) {
> +					mutex_unlock(&snic_rwlock);
> +					return snic;
> +				}
> +			}
> +		}
> +	}
> +	mutex_unlock(&snic_rwlock);
> +
> +out:
> +	snic = NULL;
> +	return snic;


you can just do return NULL


> +}
> +
> +void cxgb4i_snic_add(struct list_head *list_head)
> +{
> +	mutex_lock(&snic_rwlock);
> +	list_add_tail(list_head,&snic_list);
> +	mutex_unlock(&snic_rwlock);
> +}
> +
> +struct cxgb4i_snic *cxgb4i_snic_init(const struct cxgb4_lld_info *linfo)
> +{
> +	struct cxgb4i_snic *snic;
> +	int i;
> +
> +	snic = kzalloc(sizeof(*snic), GFP_KERNEL);
> +	if (snic) {
> +

extra newline

> +		spin_lock_init(&snic->lock);
> +		snic->lldi = *linfo;
> +		snic->hba_cnt = snic->lldi.nports;
> +		snic->cdev.dd_data = snic;
> +		snic->cdev.pdev = snic->lldi.pdev;
> +		snic->cdev.skb_tx_headroom = SKB_MAX_HEAD(CXGB4I_TX_HEADER_LEN);
> +
> +		cxgb4i_iscsi_init();
> +		cxgbi_pdu_init(&snic->cdev);
> +		cxgb4i_ddp_init(snic);
> +		cxgb4i_ofld_init(snic);
> +
> +		for (i = 0; i<  snic->hba_cnt; i++) {
> +			snic->hba[i] = cxgb4i_hba_add(snic,
> +						snic->lldi.ports[i]);
> +			if (!snic->hba[i]) {
> +				kfree(snic);
> +				snic = ERR_PTR(-ENOMEM);
> +				goto out;
> +			}
> +		}
> +		cxgb4i_snic_add(&snic->list_head);
> +	} else
> +out :
> +	snic = ERR_PTR(-ENOMEM);
> +
> +	return snic;


I think xgb4i_uld_add is not checking for PTR_ERR/IS_ERR.


> +}
> +
> +void cxgb4i_snic_cleanup(void)
> +{
> +	struct cxgb4i_snic *snic, *tmp;
> +	int i;
> +
> +	mutex_lock(&snic_rwlock);
> +	list_for_each_entry_safe(snic, tmp,&snic_list, list_head) {
> +		list_del(&snic->list_head);
> +
> +		for (i = 0; i<  snic->hba_cnt; i++) {
> +			if (snic->hba[i]) {
> +				cxgb4i_hba_remove(snic->hba[i]);
> +				snic->hba[i] = NULL;
> +			}
> +		}
> +		cxgb4i_ofld_cleanup(snic);
> +		cxgb4i_ddp_cleanup(snic);
> +		cxgbi_pdu_cleanup(&snic->cdev);
> +		cxgbi_log_info("snic 0x%p, %u scsi hosts removed.\n",
> +				snic, snic->hba_cnt);
> +
> +		kfree(snic);
> +	}
> +	mutex_unlock(&snic_rwlock);
> +	cxgb4i_iscsi_cleanup();
> +}
> +
> +static void *cxgb4i_uld_add(const struct cxgb4_lld_info *linfo)
> +{
> +	struct cxgb4i_snic *snic;
> +
> +	cxgbi_log_info("%s", version);
> +
> +	snic = cxgb4i_snic_init(linfo);

you can just do

return cxgb4i_snic_init(linfo);

and then delete everything below.



> +	if (!snic)
> +		goto out;
> +out:
> +	return snic;
> +}
> +
> +static int cxgb4i_uld_rx_handler(void *handle, const __be64 *rsp,
> +				const struct pkt_gl *pgl)
> +{
> +	struct cxgb4i_snic *snic = handle;
> +	struct sk_buff *skb;
> +	const struct cpl_act_establish *rpl;
> +	unsigned int opcode;
> +
> +	if (pgl == NULL) {
> +		unsigned int len = 64 - sizeof(struct rsp_ctrl) - 8;
> +
> +		skb = alloc_skb(256, GFP_ATOMIC);
> +		if (!skb)
> +			goto nomem;
> +		__skb_put(skb, len);
> +		skb_copy_to_linear_data(skb,&rsp[1], len);
> +
> +	} else if (pgl == CXGB4_MSG_AN) {
> +

don't need extra {} and newlines.

> +		return 0;
> +
> +	} else {
> +

extra newline

> +		skb = cxgb4_pktgl_to_skb(pgl, 256, 256);
> +		if (unlikely(!skb))
> +			goto nomem;
> +	}
> +
> +	rpl = cplhdr(skb);
> +	opcode = rpl->ot.opcode;
> +
> +	cxgbi_api_debug("snic %p, opcode 0x%x, skb %p\n",
> +			 snic, opcode, skb);
> +
> +	BUG_ON(!snic->handlers[opcode]);
> +
> +	if (snic->handlers[opcode]) {

extra brackets

> +		snic->handlers[opcode](snic, skb);
> +	} else
> +		cxgbi_log_error("No handler for opcode 0x%x\n",
> +				opcode);
> +
> +	return 0;
> +
> +nomem:
> +	cxgbi_api_debug("OOM bailing out\n");
> +	return 1;
> +}
> +
> +static int cxgb4i_uld_state_change(void *handle, enum cxgb4_state state)
> +{
> +	return 0;
> +}
> +
> +static int __init cxgb4i_init_module(void)
> +{
> +	cxgb4_register_uld(CXGB4_ULD_ISCSI,&cxgb4i_uld_info);
> +

extra newline

> +	return 0;
> +}
> +
> +static void __exit cxgb4i_exit_module(void)
> +{
> +

extra newline


> +	cxgb4_unregister_uld(CXGB4_ULD_ISCSI);
> +	cxgb4i_snic_cleanup();
> +}
> +
> +module_init(cxgb4i_init_module);
> +module_exit(cxgb4i_exit_module);
> +

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
