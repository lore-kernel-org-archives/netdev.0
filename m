From: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Subject: Re: [PATCH] xprtsock.c: make bc_{malloc/free} static
Date: Thu, 14 Jan 2010 17:42:36 -0500
Message-ID: <1263508956.2724.1.camel@localhost>
References: <201001141538.31496.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201001141538.31496.hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-14 at 15:38 -0700, H Hartley Sweeten wrote: 
> xprtsock.c: make bc_{malloc/free} static
> 
> The server backchannel buf_alloc and buf_free methods should
> be static since they are not used outside this file.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
> Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> 
> ---
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 3d739e5..721bafd 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2100,7 +2100,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>   * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
>   * to use the server side send routines.
>   */
> -void *bc_malloc(struct rpc_task *task, size_t size)
> +static void *bc_malloc(struct rpc_task *task, size_t size)
>  {
>  	struct page *page;
>  	struct rpc_buffer *buf;
> @@ -2120,7 +2120,7 @@ void *bc_malloc(struct rpc_task *task, size_t size)
>  /*
>   * Free the space allocated in the bc_alloc routine
>   */
> -void bc_free(void *buffer)
> +static void bc_free(void *buffer)
>  {
>  	struct rpc_buffer *buf;
>  

Thanks! I'll put this in the sunrpc-for-next branch.

Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
