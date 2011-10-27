From: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 1/4] SUNRPC: rpcbind clients internals virtualization
Date: Thu, 27 Oct 2011 02:43:36 -0400
Message-ID: <4EA8FD98.9040500@netapp.com>
References: <20111025135637.5286.89632.stgit@localhost6.localdomain6> <20111025135749.5286.57091.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111025135749.5286.57091.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/25/2011 10:57 AM, Stanislav Kinsbursky wrote:
> This patch moves static rpcbind internals to sunrpc part of network namespace

Rather than saying that this patch moves the static internals, could you say that it creates the new network namespace internals?  The next patch switches things over, so it's not really correct to say that this one moves everything.

Alternatively, could this patch be merged with the next one so that you create and switch over to the new internals all at once?

- Bryan

> context. This will allow to create rcpbind clients per network namespace.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  net/sunrpc/netns.h |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
> index d013bf2..83eede3 100644
> --- a/net/sunrpc/netns.h
> +++ b/net/sunrpc/netns.h
> @@ -9,6 +9,11 @@ struct cache_detail;
>  struct sunrpc_net {
>  	struct proc_dir_entry *proc_net_rpc;
>  	struct cache_detail *ip_map_cache;
> +
> +	struct rpc_clnt *rpcb_local_clnt;
> +	struct rpc_clnt *rpcb_local_clnt4;
> +	spinlock_t rpcb_clnt_lock;
> +	unsigned int rpcb_users;
>  };
>  
>  extern int sunrpc_net_id;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
