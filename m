From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 20:36:22 +0200
Message-ID: <20080725183622.GA3107@ami.dom.local>
References: <1216806614.7257.152.camel@twins> <1216810696.7257.175.camel@twins> <20080723.131441.200166513.davem@davemloft.net> <200807251904.37302.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Ingo Oeser <netdev-BkyiQQGWkgE@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200807251904.37302.netdev-BkyiQQGWkgE@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2008 at 07:04:36PM +0200, Ingo Oeser wrote:
...
> I'm sure as hell, I miss sth. but can't it be done by this pseudo-code:

...And I really doubt it can't be done like this.

Jarek P.

> 
> netif_tx_lock(device)
> {
> 	mutex_lock(device->queue_entry_mutex);
> 	foreach_queue_entries(queue, device->queues)
> 	{
> 		spin_lock(queue->tx_lock);
> 		set_noop_tx_handler(queue);
> 		spin_unlock(queue->tx_lock);
> 	}
> 	mutex_unlock(device->queue_entry_mutex);
> }
> 
> netif_tx_unlock(device)
> {
> 	mutex_lock(device->queue_entry_mutex);
> 	foreach_queue_entries(queue, device->queues)
> 	{
> 		spin_lock(queue->tx_lock);
> 		set_useful_tx_handler(queue);
> 		spin_unlock(queue->tx_lock);
> 	}
> 	mutex_unlock(device->queue_entry_mutex);
> }
> 
> Then protect use of the queues by queue->tx_lock in transmit path.
> The first setup of the queue doesn't need to be protected, since no-one
> knows the device. The final cleanup of the device doesn't need to be
> protected either, because netif_tx_lock() and netif_tx_unlock() should
> not be called after entering the final cleanup.
> 
> Some VM locking works this way...
> 
> 
> Best Regards
> 
> Ingo Oeser
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
