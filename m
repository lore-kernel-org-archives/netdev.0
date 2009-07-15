From: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Wed, 15 Jul 2009 15:45:03 +0800
Message-ID: <20090715074503.GC6145@localhost>
References: <20090709.171355.09466097.davem@davemloft.net> <20090710080017.GA24168@localhost> <20090710080247.GA2693@gondor.apana.org.au> <20090714.090432.13343695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org" <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090714.090432.13343695.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2009 at 12:04:32AM +0800, David Miller wrote:
> From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Date: Fri, 10 Jul 2009 16:02:47 +0800
> 
> > On Fri, Jul 10, 2009 at 04:00:17PM +0800, Wu Fengguang wrote:
> >> 
> >> The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
> >> the networking code shall do it anyway, because sk_allocation defaults
> >> to GFP_KERNEL. It seems that currently the networking code simply uses
> >> a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?
> > 
> > Yep because they're done from softirq context.
> 
> Yes, this is the core issue.

Yes, that's general true. But..

> All of Wu's talk about how "GFP_ATOMIC will wake up kswapd and
> therefore can succeed just as well as GFP_KERNEL" is not relevant,
> because GFP_ATOMIC means sleeping is not allowed.

We are talking about tcp_send_fin() here, which can sleep.

Thanks,
Fengguang
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
