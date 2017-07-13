From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][net-next] svcrdma: fix an incorrect check on -E2BIG and -EINVAL
Date: Thu, 13 Jul 2017 13:53:10 -0400
Message-ID: <1D2A804A-9BEC-4D34-AF01-960F35E297E7@oracle.com>
References: <20170713175115.9044-1-colin.king@canonical.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170713175115.9044-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> On Jul 13, 2017, at 1:51 PM, Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> 
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> The current check will always be true and will always jump to
> err1, this looks dubious to me. I believe && should be used
> instead of ||.
> 
> Detected by CoverityScan, CID#1450120 ("Logically Dead Code")
> 
> Fixes: 107c1d0a991a ("svcrdma: Avoid Send Queue overflow")
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Reviewed-by: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Dan reported this today, and I have a similar patch in my
"pending for-rc" series. This one works too.


> ---
> net/sunrpc/xprtrdma/svc_rdma_sendto.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 19fd01e4b690..7c3a211e0e9a 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -684,7 +684,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
> 	return 0;
> 
>  err2:
> -	if (ret != -E2BIG || ret != -EINVAL)
> +	if (ret != -E2BIG && ret != -EINVAL)
> 		goto err1;
> 
> 	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
> -- 
> 2.11.0
> 

--
Chuck Lever



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
