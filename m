From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] svcrdma: delete double assignment
Date: Tue, 29 Jul 2014 15:50:50 -0700 (PDT)
Message-ID: <20140729.155050.311148635959938226.davem@davemloft.net>
References: <20140728152938.GA3040@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, julia.lawall-L2FTfq7BK8M@public.gmane.org
To: himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140728152938.GA3040@himangi-Dell>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 28 Jul 2014 20:59:38 +0530

> Delete successive assignments to the same location.
> 
> A simplified version of Coccinelle semantic match that finds this problem is as
> follows:
> 
> // <smpl>
> @@
> expression i;
> @@
> 
> *i = ...;
>  i = ...;
> // </smpl>
> 
> Signed-off-by: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I am not so sure about this change either.

> @@ -956,7 +956,6 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>  			dprintk("svcrdma: failed to create QP, ret=%d\n", ret);
>  			goto errout;
>  		}
> -		newxprt->sc_max_sge = qp_attr.cap.max_send_sge;
>  		newxprt->sc_max_sge = qp_attr.cap.max_recv_sge;
>  		newxprt->sc_sq_depth = qp_attr.cap.max_send_wr;
>  		newxprt->sc_max_requests = qp_attr.cap.max_recv_wr;

->sc_max_sge is used to limit the number of segments used during sends,
currently in this code.  Grep for where it is used.

Therefore, if anything, the correct thing to do would be to retain the
first line rather than the second line.

Someone who actually works on this code and understands it should
really take a close look at this before anyone even thinks about
applying this patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
