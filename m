From: Shamir Rabinovitch <shamir.rabinovitch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net] rds: Reintroduce statistics counting
Date: Tue, 8 Aug 2017 09:20:02 -0400
Message-ID: <20170808132002.GA9848@shamir-net-srv.us.oracle.com>
References: <20170808091332.5413-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, knut.omang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        wei.lin-guay-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: =?iso-8859-1?Q?H=E5kon?= Bugge <Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170808091332.5413-1-Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2017 at 11:13:32AM +0200, Håkon Bugge wrote:
> In commit 7e3f2952eeb1 ("rds: don't let RDS shutdown a connection
> while senders are present"), refilling the receive queue was removed
> from rds_ib_recv(), along with the increment of
> s_ib_rx_refill_from_thread.
> 
> Commit 73ce4317bf98 ("RDS: make sure we post recv buffers")
> re-introduces filling the receive queue from rds_ib_recv(), but does
> not add the statistics counter. rds_ib_recv() was later renamed to
> rds_ib_recv_path().
> 
> This commit reintroduces the statistics counting of
> s_ib_rx_refill_from_thread and s_ib_rx_refill_from_cq.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Knut Omang <knut.omang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Wei Lin Guay <wei.lin.guay-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  net/rds/ib_recv.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
> index e10624a..9722bf8 100644
> --- a/net/rds/ib_recv.c
> +++ b/net/rds/ib_recv.c
> @@ -1015,8 +1015,10 @@ void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic,
>  	if (rds_ib_ring_empty(&ic->i_recv_ring))
>  		rds_ib_stats_inc(s_ib_rx_ring_empty);
>  
> -	if (rds_ib_ring_low(&ic->i_recv_ring))
> +	if (rds_ib_ring_low(&ic->i_recv_ring)) {
>  		rds_ib_recv_refill(conn, 0, GFP_NOWAIT);
> +		rds_ib_stats_inc(s_ib_rx_refill_from_cq);
> +	}
>  }
>  
>  int rds_ib_recv_path(struct rds_conn_path *cp)
> @@ -1029,6 +1031,7 @@ int rds_ib_recv_path(struct rds_conn_path *cp)
>  	if (rds_conn_up(conn)) {
>  		rds_ib_attempt_ack(ic);
>  		rds_ib_recv_refill(conn, 0, GFP_KERNEL);
> +		rds_ib_stats_inc(s_ib_rx_refill_from_thread);
>  	}
>  
>  	return ret;
> -- 
> 2.9.3
> 

Reviewed-by: Shamir Rabinovitch <shamir.rabinovitch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
