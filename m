From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 04/11] IB/cm: Expose DGID in SIDR request events
Date: Mon, 15 Jun 2015 21:32:53 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FF5A3F@ORSMSX109.amr.corp.intel.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
 <1434358036-15526-5-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-5-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>  drivers/infiniband/core/cm.c | 7 +++++++
>  include/rdma/ib_cm.h         | 2 ++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
> index c5f5f89e274a..46f99ec4080a 100644
> --- a/drivers/infiniband/core/cm.c
> +++ b/drivers/infiniband/core/cm.c
> @@ -2983,6 +2983,13 @@ static void cm_format_sidr_req_event(struct cm_work
> *work,
>  	param->pkey = __be16_to_cpu(sidr_req_msg->pkey);
>  	param->listen_id = listen_id;
>  	param->service_id = sidr_req_msg->service_id;
> +	if (work->mad_recv_wc->wc->wc_flags & IB_WC_GRH) {
> +		param->grh = 1;
> +		memcpy(&param->dgid, &work->mad_recv_wc->recv_buf.grh->dgid,
> +		       sizeof(param->dgid));
> +	} else {
> +		param->grh = 0;

What is the use case here?  Are you trying to sort by device?  How does the GID of the GMP relate to the listen?

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
