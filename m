From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Sat, 5 May 2007 10:16:24 +0100
Message-ID: <20070505091624.GA8890@infradead.org>
References: <20070504232051.411946839@goop.org> <20070504232121.492190579@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40457 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423178AbXEEJQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 05:16:51 -0400
Content-Disposition: inline
In-Reply-To: <20070504232121.492190579@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 04:21:16PM -0700, Jeremy Fitzhardinge wrote:
> +/*
> + * Mutually-exclusive module options to select receive data path:
> + *  rx_copy : Packets are copied by network backend into local memory
> + *  rx_flip : Page containing packet data is transferred to our ownership
> + * For fully-virtualised guests there is no option - copying must be used.
> + * For paravirtualised guests, flipping is the default.
> + */
> +static enum {
> +	RX_COPY = 0,
> +	RX_FLIP = 1,
> +} rx_mode = RX_FLIP;
> +MODULE_PARM_DESC(rx_mode, "How to get packets from card: 0->copy, 1->flip");

There only seems to be a module description but no actual paramter for
this.  I wish people would have listened to me back then and made the
description part of the modular_param statement..

> +
> +#define RX_COPY_THRESHOLD 256
> +
> +#define GRANT_INVALID_REF	0
> +
> +#define NET_TX_RING_SIZE __RING_SIZE((struct xen_netif_tx_sring *)0, PAGE_SIZE)
> +#define NET_RX_RING_SIZE __RING_SIZE((struct xen_netif_rx_sring *)0, PAGE_SIZE)

__RING_SIZE is not in my tree, so it seems to be some kind of Xen
addition.  Can you make that clear in the name and give it a less
awkware calling convention, e.g. only pass in the type, not a null
pointer of the given type?


> +/*
> + * Implement our own carrier flag: the network stack's version causes delays
> + * when the carrier is re-enabled (in particular, dev_activate() may not
> + * immediately be called, which can cause packet loss).
> + */
> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
> +#define netfront_carrier_ok(netif)	((netif)->carrier)

This doesn't implement my review suggestion despite you ACKing
them.  Didn't you like it in the end or did you simply forget
about it?

> +/*
> + * Access macros for acquiring freeing slots in tx_skbs[].
> + */
> +
> +static void add_id_to_freelist(unsigned *head, union skb_entry *list, unsigned short id)


no lines longer than 80 chars please.

