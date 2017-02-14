From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 1/2] qed: Add support for hardware
 offloaded FCoE.
Date: Tue, 14 Feb 2017 13:14:19 -0500 (EST)
Message-ID: <20170214.131419.1326744868549008726.davem@davemloft.net>
References: <1487013421-27006-1-git-send-email-chad.dupuis@cavium.com>
        <1487013421-27006-2-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.petersen@oracle.com, linux-scsi@vger.kernel.org,
        fcoe-devel@open-fcoe.org, netdev@vger.kernel.org,
        yuval.mintz@cavium.com, QLogic-Storage-Upstream@cavium.com
To: chad.dupuis@cavium.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1487013421-27006-2-git-send-email-chad.dupuis@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dupuis, Chad" <chad.dupuis@cavium.com>
Date: Mon, 13 Feb 2017 11:17:00 -0800

> @@ -255,6 +259,10 @@ struct qed_hw_info {
>  	u32				part_num[4];
>  
>  	unsigned char			hw_mac_addr[ETH_ALEN];
> +	u64				node_wwn;
> +	u64				port_wwn;
> +
> +	u16 num_fcoe_conns;

This new num_fcoe_conns member should be indented just like the rest of them.

> +static int
> +qed_sp_fcoe_func_start(struct qed_hwfn *p_hwfn,
> +		       enum spq_mode comp_mode,
> +		       struct qed_spq_comp_cb *p_comp_addr)
> +{
> +	struct qed_fcoe_pf_params *fcoe_pf_params = NULL;
> +	struct fcoe_init_ramrod_params *p_ramrod = NULL;
> +	struct fcoe_conn_context *p_cxt = NULL;
> +	struct qed_spq_entry *p_ent = NULL;
> +	struct fcoe_init_func_ramrod_data *p_data;
> +	int rc = 0;
> +	struct qed_sp_init_data init_data;
> +	struct qed_cxt_info cxt_info;
> +	u32 dummy_cid;
> +	u16 tmp;
> +	u8 i;

Please order local variable declarations from larget the smallest line.

> +#else /* CONFIG_QED_FCOE */
> +static inline struct qed_fcoe_info *
> +qed_fcoe_alloc(struct qed_hwfn *p_hwfn) { return NULL; }
> +static inline void
> +qed_fcoe_setup(struct qed_hwfn *p_hwfn, struct qed_fcoe_info *p_fcoe_info) {}
> +static inline void
> +qed_fcoe_free(struct qed_hwfn *p_hwfn, struct qed_fcoe_info *p_fcoe_info) {}
> +static inline void
> +qed_get_protocol_stats_fcoe(struct qed_dev *cdev,
> +			    struct qed_mcp_fcoe_stats *stats) {}

Please do not format these functions so compactly, they are very difficult to
read.  Format them just like normal functions.
