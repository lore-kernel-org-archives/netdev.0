From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access uc list
Date: Sun, 24 Jan 2010 23:02:51 -0800 (PST)
Message-ID: <20100124.230251.177086043.davem@davemloft.net>
References: <20100124104239.GA21371@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41549
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751125Ab0AYHCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 02:02:40 -0500
In-Reply-To: <20100124104239.GA21371@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 24 Jan 2010 11:42:45 +0100

> +#define netdev_uc_count(dev) ((dev)->uc.count)
> +
> +#define netdev_get_list_by_addr(a) \
> +	(container_of((void *) a, struct netdev_hw_addr, addr)->list)
> +
> +#define netdev_get_addr_by_list(l) \
> +	(list_entry(l, struct netdev_hw_addr, list)->addr)
> +
> +#define netdev_for_each_addr(a, head)					\
> +	for (a = netdev_get_addr_by_list((head)->next);			\
> +	     prefetch(netdev_get_list_by_addr(a).next),			\
> +	     &netdev_get_list_by_addr(a) != (head);			\
> +	     a = netdev_get_addr_by_list(netdev_get_list_by_addr(a).next))
> +
> +#define netdev_for_each_uc_addr(a, dev)	\
> +	netdev_for_each_addr(a, &dev->uc.list)
> +

I should have mentioned this the other day, but I don't like
having "unsigned char *" being the type of the element iterator.

Sure it allows you, I guess, to eliminate one local variable
in the places the iterate, but it definitely is at the cost
of aestetics.

Please use some normal iterating object for the iterator, such as
"struct list_head *" or "struct netdev_hw_addr *".  Probably the
latter would work best.

