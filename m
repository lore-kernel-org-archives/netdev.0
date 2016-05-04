From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] tcp: fix lockdep splat in tcp_snd_una_update()
Date: Wed, 04 May 2016 00:54:43 -0400 (EDT)
Message-ID: <20160504.005443.219521798076710212.davem@davemloft.net>
References: <20160503223149.GA19739@electric-eye.fr.zoreil.com>
	<1462314901.5535.316.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org, festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462319763.5535.329.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 03 May 2016 16:56:03 -0700

> From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> tcp_snd_una_update() and tcp_rcv_nxt_update() call
> u64_stats_update_begin() either from process context or BH handler.
> 
> This triggers a lockdep splat on 32bit & SMP builds.
> 
> We could add u64_stats_update_begin_bh() variant but this would
> slow down 32bit builds with useless local_disable_bh() and
> local_enable_bh() pairs, since we own the socket lock at this point.
> 
> I add sock_owned_by_me() helper to have proper lockdep support
> even on 64bit builds, and new u64_stats_update_begin_raw()
> and u64_stats_update_end_raw methods.
> 
> Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> Reported-by: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Diagnosed-by: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
