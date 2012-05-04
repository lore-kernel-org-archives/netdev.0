From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] tilegx network driver: initial support
Date: Fri, 04 May 2012 02:42:16 -0400 (EDT)
Message-ID: <20120504.024216.1730395431103337434.davem@davemloft.net>
References: <201205011759.q41HxR21020043@farm-0012.internal.tilera.com>
	<20120503.014156.149171097979026872.davem@davemloft.net>
	<201205031936.q43Ja9Xb031644@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201205031936.q43Ja9Xb031644@lab-41.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 3 May 2012 12:41:56 -0400

> +/* First, "tile_net_init_module()" initializes each network cpu to
> + * handle incoming packets, and initializes all the network devices.
> + *
> + * Then, "ifconfig DEVICE up" calls "tile_net_open()", which will
> + * turn on packet processing, if needed.
> + *
> + * If "ifconfig DEVICE down" is called, it uses "tile_net_stop()" to
> + * stop egress, and possibly turn off packet processing.
> + *
> + * We start out with the ingress IRQ enabled on each CPU.  When it
> + * fires, it is automatically disabled, and we call "napi_schedule()".
> + * This will cause "tile_net_poll()" to be called, which will pull
> + * packets from the netio queue, filtering them out, or passing them
> + * to "netif_receive_skb()".  If our budget is exhausted, we will
> + * return, knowing we will be called again later.  Otherwise, we
> + * reenable the ingress IRQ, and call "napi_complete()".

This is not the place where you document how the generic networking
brings devices up and down, and what driver methods are called during
those actions.

Imagine if every driver writer decided to do this.

> +#define TILE_NET_MAX_COMPS 64
> +
> +

Please get rid of all of these more-than-one empty line sequences.

> +#define ROUND_UP(n, align) (((n) + (align) - 1) & -(align))

This is ALIGN() from linux/kernel.h, please us it.

At this rate I anticipate at least 20 rounds of review, this driver
still needs quite a bit of work.
