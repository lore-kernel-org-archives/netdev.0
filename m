From: Jonathan Toppins <jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 10/22] bnxt_re: Support for CQ verbs
Date: Mon, 12 Dec 2016 16:03:27 -0500
Message-ID: <d9b40373-e638-7d1b-0ce2-d303b49c9644@redhat.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <1481266096-23331-11-git-send-email-selvin.xavier@broadcom.com>
Reply-To: jtoppins-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-11-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/09/2016 01:48 AM, Selvin Xavier wrote:
> This patch implements support for create_cq, destroy_cq and req_notify_cq
> verbs.
> 
> Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c    | 183 ++++++++++++++++++++++++
>  drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h    |  47 ++++++
>  drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 154 ++++++++++++++++++++
>  drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |  19 +++
>  drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |   4 +
>  include/uapi/rdma/bnxt_re_uverbs_abi.h          |  11 ++
>  6 files changed, 418 insertions(+)

Something I just realized is this patch series does not modify the
MAINTAINERS file. Whom from Broadcom will be maintaining this driver?
Probably want to include this info in the v3 series

[...]

> diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
> index 3417829..f316598 100644
> --- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
> +++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
> @@ -60,6 +60,16 @@
>  #include "bnxt_re_ib_verbs.h"
>  #include <rdma/bnxt_re_uverbs_abi.h>
>  
> +static int bnxt_re_copy_to_udata(struct bnxt_re_dev *rdev, void *data, int len,
> +				 struct ib_udata *udata)
> +{
> +	int rc;
> +
> +	rc = ib_copy_to_udata(udata, data, len);
> +
> +	return rc ? -EFAULT : 0;
> +}

This function seems to provide no value by wrapping ib_copy_to_udata,
any reason to keep it? From the two call sites for this function it
appears it can be replaced with a direct call to ib_copy_to_udata.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
