From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next] qed: Set error code for allocation failures
Date: Fri, 27 Oct 2017 17:32:42 +0800
Message-ID: <9ae1759e-18a1-18fb-ec93-8edf947b1cc6@huawei.com>
References: <20171027064020.aq52ue4kfp5htrb5@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <everest-linux-l2@cavium.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027064020.aq52ue4kfp5htrb5@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Dan

On 2017/10/27 14:40, Dan Carpenter wrote:
> There are several places where we accidentally return success when
> kcalloc() fails.
> 
> Fixes: fcb39f6c10b2 ("qed: Add mpa buffer descriptors for storing and processing mpa fpdus")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
> index 409041eab189..6366f2ef82b7 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
> @@ -2585,7 +2585,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>  	struct qed_ll2_cbs cbs;
>  	u32 mpa_buff_size;
>  	u16 n_ooo_bufs;
> -	int rc = 0;
> +	int rc;
>  	int i;
>  
>  	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
> @@ -2696,6 +2696,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>  	if (rc)
>  		goto err;
>  
> +	rc = -ENOMEM;
>  	iwarp_info->partial_fpdus = kcalloc((u16)p_hwfn->p_rdma_info->num_qps,
>  					    sizeof(*iwarp_info->partial_fpdus),
>  					    GFP_KERNEL);

Does the memory allocated here need to be freed when error happens below?


> @@ -2724,7 +2725,7 @@ qed_iwarp_ll2_start(struct qed_hwfn *p_hwfn,
>  	for (i = 0; i < data.input.rx_num_desc; i++)
>  		list_add_tail(&iwarp_info->mpa_bufs[i].list_entry,
>  			      &iwarp_info->mpa_buf_list);
> -	return rc;
> +	return 0;
>  err:
>  	qed_iwarp_ll2_stop(p_hwfn, p_ptt);
>  
> 
> .
> 
