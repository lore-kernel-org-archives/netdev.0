From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 11:35:19 +0000
Message-ID: <20080723113519.GE4561@ff.dom.local>
References: <20080722.160409.216536011.davem@davemloft.net> <20080723062036.GA4561@ff.dom.local> <20080723.005921.113868915.davem@davemloft.net> <20080723085452.GB4561@ff.dom.local> <1216803786.7257.146.camel@twins> <20080723093459.GC4561@ff.dom.local> <1216806614.7257.152.camel@twins> <20080723101352.GD4561@ff.dom.local> <1216810696.7257.175.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1216810696.7257.175.camel@twins>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2008 at 12:58:16PM +0200, Peter Zijlstra wrote:
...
> Ah, right,...
> 
> that takes a whole bunch of locks at once..
> 
> Is that really needed? - when I grep for its usage its surprisingly few
> drivers using it and even less generic code.
> 
> When I look at the mac802.11 code in ieee80211_tx_pending() it looks
> like it can do with just one lock at a time, instead of all - but I
> might be missing some obvious details.
> 
> So I guess my question is, is netif_tx_lock() here to stay, or is the
> right fix to convert all those drivers to use __netif_tx_lock() which
> locks only a single queue?
> 

It's a new thing mainly for new hardware/drivers, and just after
conversion (older drivers effectively use __netif_tx_lock()), so it'll
probably stay for some time until something better is found. David,
will tell the rest, I hope.

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
