From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: your mail
Date: Thu, 18 Sep 2003 15:38:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918193842.GC9605@gtf.org>
References: <3F69FAF8.mail2M211N69M@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <3F69FAF8.mail2M211N69M@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2003 at 08:35:36PM +0200, Robert Olsson wrote:

This issue is already fixed in 2.4 and 2.5 :)


> --- include/linux/netdevice.h.orig	2003-09-08 21:50:31.000000000 +0200
> +++ include/linux/netdevice.h	2003-09-17 17:27:58.000000000 +0200
> @@ -830,9 +830,9 @@
>  	local_irq_restore(flags);
>  }
>  
> -static inline void netif_poll_disable(struct net_device *dev)
> +static inline void netif_poll_sync(struct net_device *dev)
>  {
> -	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
> +	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
>  		/* No hurry. */
>  		current->state = TASK_INTERRUPTIBLE;
>  		schedule_timeout(1);

This patch breaks tg3 build, and operation...
tg3 wants a different operation than net/core/dev.c.

	Jeff
