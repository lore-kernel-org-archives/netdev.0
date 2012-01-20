From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RFC] SUNPRC: remove marking service temporary sockets
 with XPT_CHNGBUF
Date: Fri, 20 Jan 2012 16:46:48 -0500
Message-ID: <20120120214648.GB17859@fieldses.org>
References: <20120120125243.7733.81374.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120120125243.7733.81374.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2012 at 04:55:39PM +0400, Stanislav Kinsbursky wrote:
> This is a cleanup patch.
> Service temporary sockets can be TCP or RDMA only. But XPT_CHNGBUF service
> socket flag is checked only for UDP sockets on receive.
> Thus (if I don't miss something non-obvious) this bit raising for temporary
> sockets can be removed.

Yes, I believe that's correct, it's leftover cleanup from
9660439861aa8dbd5e2b8087f33e20760c2c9afc "svcrpc: take advantage of tcp
autotuning".

I'll ignore the "RFC" marking and apply unless you tell me otherwise....

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  net/sunrpc/svcsock.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index e8af0c9..2867249 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1381,8 +1381,6 @@ void svc_sock_update_bufs(struct svc_serv *serv)
>  	spin_lock_bh(&serv->sv_lock);
>  	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list)
>  		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
> -	list_for_each_entry(svsk, &serv->sv_tempsocks, sk_xprt.xpt_list)
> -		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>  	spin_unlock_bh(&serv->sv_lock);
>  }
>  EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
