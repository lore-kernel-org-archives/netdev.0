From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/5] nfnetlink_queue: Use rcu_barrier() on module
	unload.
Date: Mon, 8 Jun 2009 09:05:22 -0700
Message-ID: <20090608160522.GC6961@linux.vnet.ibm.com>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131133.10052.40836.stgit@localhost>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	vladislav.yasevich-VXdhtT5mjnY@public.gmane.org, sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090608131133.10052.40836.stgit@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 08, 2009 at 03:11:33PM +0200, Jesper Dangaard Brouer wrote:
> This module uses rcu_call() thus it should use rcu_barrier() on module unload.
> 
> Also fixed a trivial typo 'nfetlink' -> 'nfnetlink' in comment.

Assuming that netlink_unregister_notifier(), nfnetlink_subsys_unregister(),
and so on prevent any subsequent calls to call_rcu(), looks good!!!

Acked-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

> Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
> ---
> 
>  net/netfilter/nfnetlink_queue.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
> index 8c86011..71daa09 100644
> --- a/net/netfilter/nfnetlink_queue.c
> +++ b/net/netfilter/nfnetlink_queue.c
> @@ -1,6 +1,6 @@
>  /*
>   * This is a module which is used for queueing packets and communicating with
> - * userspace via nfetlink.
> + * userspace via nfnetlink.
>   *
>   * (C) 2005 by Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
>   * (C) 2007 by Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
> @@ -932,6 +932,8 @@ static void __exit nfnetlink_queue_fini(void)
>  #endif
>  	nfnetlink_subsys_unregister(&nfqnl_subsys);
>  	netlink_unregister_notifier(&nfqnl_rtnl_notifier);
> +
> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>  }
> 
>  MODULE_DESCRIPTION("netfilter packet queue handler");
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
