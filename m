From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
 usage
Date: Thu, 09 Jul 2009 17:13:55 -0700 (PDT)
Message-ID: <20090709.171355.09466097.davem@davemloft.net>
References: <20090608023757.GA6244@localhost>
	<20090706105216.GA19124@gondor.apana.org.au>
	<20090709131746.GA27965@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090709131746.GA27965@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Thu, 9 Jul 2009 21:17:46 +0800

> @@ -2100,7 +2100,8 @@ void tcp_send_fin(struct sock *sk)
>  	} else {
>  		/* Socket is locked, keep trying until memory is available. */
>  		for (;;) {
> -			skb = alloc_skb_fclone(MAX_TCP_HEADER, GFP_KERNEL);
> +			skb = alloc_skb_fclone(MAX_TCP_HEADER,
> +					       sk->sk_allocation);
>  			if (skb)
>  				break;
>  			yield();

I think this specific case needs more thinking.

If the allocation fails, and it's GFP_ATOMIC, we are going to yield()
(which sleeps) and loop endlessly waiting for the allocation to
succeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
