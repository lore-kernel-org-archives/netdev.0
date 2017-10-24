From: =?utf-8?Q?H=C3=A5kon_Bugge?= <haakon.bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] rds: Fix uninitialized variable
Date: Tue, 24 Oct 2017 18:16:23 +0200
Message-ID: <A88A3E1A-A919-48E2-9464-210AB7DB3E67@oracle.com>
References: <20171024160719.17726-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        OFED mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171024160719.17726-1-Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ignore this, sent the old one.

Håkon

> On 24 Oct 2017, at 18:07, Håkon Bugge <Haakon.Bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> 
> send_flags needs to be initialized before calling
> rds_ib_set_wr_signal_state().
> 
> Signed-off-by: Håkon Bugge <haakon.bugge-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> net/rds/ib_send.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
> index 6ab39db..8f46755 100644
> --- a/net/rds/ib_send.c
> +++ b/net/rds/ib_send.c
> @@ -792,6 +792,7 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
> 		send->s_atomic_wr.compare_add_mask = op->op_m_fadd.nocarry_mask;
> 		send->s_atomic_wr.swap_mask = 0;
> 	}
> +	send->s_wr.send_flags = 0;
> 	nr_sig = rds_ib_set_wr_signal_state(ic, send, op->op_notify);
> 	send->s_atomic_wr.wr.num_sge = 1;
> 	send->s_atomic_wr.wr.next = NULL;
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
