From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCHv2 3/5] rds: ib: remove redundant ib_dealloc_fmr
Date: Thu, 9 Mar 2017 14:09:27 +0200
Message-ID: <20170309120927.GL3307@yuval-lap>
References: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c@suse.de>
 <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jthumshirn@suse.de, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30284 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdCIMMB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 07:12:01 -0500
Content-Disposition: inline
In-Reply-To: <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 04:20:43AM -0500, Zhu Yanjun wrote:
> The function ib_dealloc_fmr will never be called. As such, it should
> be removed.
> 
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
> Change from v1 to v2:
>   remove ibmr NULL test.
> 
>  net/rds/ib_fmr.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
> index 4fe8f4f..249ae1c 100644
> --- a/net/rds/ib_fmr.c
> +++ b/net/rds/ib_fmr.c
> @@ -78,12 +78,9 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
>  	return ibmr;
>  
>  out_no_cigar:
> -	if (ibmr) {
> -		if (fmr->fmr)
> -			ib_dealloc_fmr(fmr->fmr);
> -		kfree(ibmr);
> -	}
> +	kfree(ibmr);
>  	atomic_dec(&pool->item_count);
> +

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

>  	return ERR_PTR(err);
>  }
>  
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
