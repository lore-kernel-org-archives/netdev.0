From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCHv2 3/5] rds: ib: remove redundant ib_dealloc_fmr
Date: Thu, 9 Mar 2017 08:51:59 -0800
Message-ID: <d64b4593-7ada-88a0-6151-65e87ba43ec6@oracle.com>
References: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c@suse.de>
 <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, jthumshirn@suse.de,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:30756 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754776AbdCIQya (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 11:54:30 -0500
In-Reply-To: <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/9/2017 1:20 AM, Zhu Yanjun wrote:
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
While posting updates, please post entire series and also
give some time between two posts.


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
No need of the extra line here.

>  	return ERR_PTR(err);
>  }
>
>
