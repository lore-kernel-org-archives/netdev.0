From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
 usage
Date: Tue, 14 Jul 2009 09:04:32 -0700 (PDT)
Message-ID: <20090714.090432.13343695.davem@davemloft.net>
References: <20090709.171355.09466097.davem@davemloft.net>
	<20090710080017.GA24168@localhost>
	<20090710080247.GA2693@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090710080247.GA2693-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Fri, 10 Jul 2009 16:02:47 +0800

> On Fri, Jul 10, 2009 at 04:00:17PM +0800, Wu Fengguang wrote:
>> 
>> The (sk_allocation & ~__GFP_WAIT) cases should be rare, but I guess
>> the networking code shall do it anyway, because sk_allocation defaults
>> to GFP_KERNEL. It seems that currently the networking code simply uses
>> a lot of GFP_ATOMIC, do they really mean "I cannot sleep"?
> 
> Yep because they're done from softirq context.

Yes, this is the core issue.

All of Wu's talk about how "GFP_ATOMIC will wake up kswapd and
therefore can succeed just as well as GFP_KERNEL" is not relevant,
because GFP_ATOMIC means sleeping is not allowed.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
