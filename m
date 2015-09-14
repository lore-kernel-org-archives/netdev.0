From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 14/39] SUNRPC: drop null test before destroy functions
Date: Mon, 14 Sep 2015 12:07:10 -0400
Message-ID: <20150914160710.GB5338@fieldses.org>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
 <1442146532-9100-15-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1442146532-9100-15-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ACK, but assuming Trond takes this one.--b.

On Sun, Sep 13, 2015 at 02:15:07PM +0200, Julia Lawall wrote:
> Remove unneeded NULL test.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@ expression x; @@
> -if (x != NULL)
>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
> 
> ---
>  net/sunrpc/sched.c |   12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index b140c09..425ca2f 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -1092,14 +1092,10 @@ void
>  rpc_destroy_mempool(void)
>  {
>  	rpciod_stop();
> -	if (rpc_buffer_mempool)
> -		mempool_destroy(rpc_buffer_mempool);
> -	if (rpc_task_mempool)
> -		mempool_destroy(rpc_task_mempool);
> -	if (rpc_task_slabp)
> -		kmem_cache_destroy(rpc_task_slabp);
> -	if (rpc_buffer_slabp)
> -		kmem_cache_destroy(rpc_buffer_slabp);
> +	mempool_destroy(rpc_buffer_mempool);
> +	mempool_destroy(rpc_task_mempool);
> +	kmem_cache_destroy(rpc_task_slabp);
> +	kmem_cache_destroy(rpc_buffer_slabp);
>  	rpc_destroy_wait_queue(&delay_queue);
>  }
>  
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
