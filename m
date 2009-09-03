From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH][RESEND] tcp: replace hard coded GFP_KERNEL with
 sk_allocation
Date: Wed, 02 Sep 2009 23:10:17 -0700 (PDT)
Message-ID: <20090902.231017.31926895.davem@davemloft.net>
References: <20090903040407.GA20094@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090903040407.GA20094@localhost>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Thu, 3 Sep 2009 12:04:07 +0800

> This fixed a lockdep warning which appeared when doing stress
> memory tests over NFS:
> 
> 	inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> 
> 	page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> 
> 	mount_root => nfs_root_data => tcp_close => lock sk_lock =>
> 			tcp_send_fin => alloc_skb_fclone => page reclaim
> 
> David raised a concern that if the allocation fails in tcp_send_fin(), and it's
> GFP_ATOMIC, we are going to yield() (which sleeps) and loop endlessly waiting
> for the allocation to succeed.
> 
> But fact is, the original GFP_KERNEL also sleeps. GFP_ATOMIC+yield() looks
> weird, but it is no worse the implicit sleep inside GFP_KERNEL. Both could
> loop endlessly under memory pressure.
> 
> CC: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
> CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> CC: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Signed-off-by: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Applied to net-next-2.6, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
