From: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 21:06:51 +1000
Message-ID: <200807242106.52672.nickpiggin@yahoo.com.au>
References: <1216890648.7257.258.camel@twins> <200807242038.36693.nickpiggin@yahoo.com.au> <E1KLyUI-0006ZS-Cg@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1KLyUI-0006ZS-Cg-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 24 July 2008 20:55, Miklos Szeredi wrote:
> On Thu, 24 Jul 2008, Nick Piggin wrote:
> > Hey, something kind of cool (and OT) I've just thought of that we can
> > do with ticket locks is to take tickets for 2 (or 64K) nested locks,
> > and then wait for them both (all), so the cost is N*lock + longest spin,
> > rather than N*lock + N*avg spin.
>
> Isn't this deadlocky?
>
> E.g. one task takes ticket x=1, then other task comes in and takes x=2
> and y=1, then first task takes y=2.  Then neither can actually
> complete both locks.

Oh duh of course you still need mutual exclusion from the first lock
to order the subsequent :P

So yeah it only works for N > 2 locks, and you have to spin_lock the
first one... so unsuitable for scheduler.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
