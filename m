From: "ira.weiny" <ira.weiny@intel.com>
Subject: Re: [PATCH v2 11/11] IB/ucm: Add partial support for network namespaces
Date: Mon, 20 Apr 2015 19:46:29 -0400
Message-ID: <20150420234629.GD1409@phlsvsds.ph.intel.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com> <1429520622-10303-12-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21186 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908AbbDTXqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 19:46:33 -0400
Content-Disposition: inline
In-Reply-To: <1429520622-10303-12-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2015 at 12:03:42PM +0300, Haggai Eran wrote:
> From: Shachar Raindel <raindel@mellanox.com>
> 
> It is impossible to completely support network namespaces for UCM, as
> we cannot identify the target IPoIB device.
>

As Jasons said it seems like the use of namespaces should be limited to the
RDMA CM layer.  If so I _think_ this patch would not be needed?

Ira


>
> However, we add support
> which will work if the user is following the IB-Spec Annex 11 (RDMA IP
> CM Services) with the service ID and private data formatting.
> 
> Signed-off-by: Haggai Eran <haggaie@mellanox.com>
> Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> Signed-off-by: Guy Shapiro <guysh@mellanox.com>
> ---
>  drivers/infiniband/core/ucm.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
> index 9604ab068984..424421091dae 100644
> --- a/drivers/infiniband/core/ucm.c
> +++ b/drivers/infiniband/core/ucm.c
> @@ -45,6 +45,7 @@
>  #include <linux/idr.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
> +#include <linux/nsproxy.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -490,7 +491,7 @@ static ssize_t ib_ucm_create_id(struct ib_ucm_file *file,
>  	ctx->uid = cmd.uid;
>  	ctx->cm_id = ib_create_cm_id(file->device->ib_dev,
>  				     ib_ucm_event_handler, ctx,
> -				     &init_net);
> +				     current->nsproxy->net_ns);
>  	if (IS_ERR(ctx->cm_id)) {
>  		result = PTR_ERR(ctx->cm_id);
>  		goto err1;
> -- 
> 1.7.11.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
