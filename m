From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 21:34:16 +0200
Message-ID: <20080725193416.GB3107@ami.dom.local>
References: <1216806614.7257.152.camel@twins> <1216810696.7257.175.camel@twins> <20080723.131441.200166513.davem@davemloft.net> <200807251904.37302.netdev@axxeo.de> <20080725183622.GA3107@ami.dom.local> <1217013384.4758.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Oeser <netdev-BkyiQQGWkgE@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1217013384.4758.5.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2008 at 09:16:24PM +0200, Johannes Berg wrote:
> On Fri, 2008-07-25 at 20:36 +0200, Jarek Poplawski wrote:
> > On Fri, Jul 25, 2008 at 07:04:36PM +0200, Ingo Oeser wrote:
> > ...
> > > I'm sure as hell, I miss sth. but can't it be done by this pseudo-code:
> > 
> > ...And I really doubt it can't be done like this.
> 
> Umm, of course it cannot, because then we'd have to take the mutex in
> the TX path, which we cannot. We cannot have another lock in the TX
> path, what's so hard to understand about? We need to be able to lock all
> queues to lock out multiple tx paths at once in some (really) slow paths
> but not have any extra lock overhead for the tx path, especially not a
> single lock.

But this mutex doesn't have to be mutex. And it's not for the tx path,
only for "service" just like netif_tx_lock(). The fast path needs only
queue->tx_lock.

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
