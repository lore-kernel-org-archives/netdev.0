From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 3/5] rds: ib: remove redundant ib_dealloc_fmr
Date: Thu, 9 Mar 2017 09:16:02 +0100
Message-ID: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c@suse.de>
References: <1489044405-26150-1-git-send-email-yanjun.zhu@oracle.com>
 <1489044405-26150-3-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39896 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752829AbdCIIRo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 03:17:44 -0500
In-Reply-To: <1489044405-26150-3-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 08:26 AM, Zhu Yanjun wrote:
> The function ib_dealloc_fmr will never be called. As such, it should
> be removed.
> 
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  net/rds/ib_fmr.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
> index 4fe8f4f..b807df6 100644
> --- a/net/rds/ib_fmr.c
> +++ b/net/rds/ib_fmr.c
> @@ -78,12 +78,10 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
>  	return ibmr;
>  
>  out_no_cigar:
> -	if (ibmr) {
> -		if (fmr->fmr)
> -			ib_dealloc_fmr(fmr->fmr);
> +	if (ibmr)
>  		kfree(ibmr);

kfree() already does a NULL check (see
http://lxr.free-electrons.com/source/mm/slab.c#L3811) so no need to do
it here.



-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
