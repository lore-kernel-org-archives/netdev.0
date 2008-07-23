From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 08:54:52 +0000
Message-ID: <20080723085452.GB4561@ff.dom.local>
References: <20080722.160409.216536011.davem@davemloft.net> <20080723062036.GA4561@ff.dom.local> <20080723.005921.113868915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080723.005921.113868915.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2008 at 12:59:21AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 23 Jul 2008 06:20:36 +0000
> 
> > PS: if there is nothing new in lockdep the classical method would
> > be to change this static array:
> > 
> > static struct lock_class_key
> > netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
> > 
> > to
> > 
> > static struct lock_class_key
> > netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)][MAX_NUM_TX_QUEUES];
> > 
> > and set lockdep classes per queue as well. (If we are sure we don't
> > need lockdep subclasses anywhere this could be optimized by using
> > one lock_class_key per 8 queues and spin_lock_nested()).
> 
> Unfortunately MAX_NUM_TX_QUEUES is USHORT_MAX, so this isn't really
> a feasible approach.

Is it used by real devices already? Maybe for the beginning we could
start with something less?

> spin_lock_nested() isn't all that viable either, as the subclass
> limit is something like 8.

This method would need to do some additional counting: depending of
a queue number each 8 subsequent queues share (are set to) the same
class and their number mod 8 gives the subqueue number for
spin_lock_nested().

I'll try to find if there is something new around this in lockdep.
(lockdep people added to CC.)

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
