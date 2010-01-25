From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] net: use helpers to access uc list
Date: Mon, 25 Jan 2010 09:34:52 +0100
Message-ID: <20100125083450.GA2902@psychotron.redhat.com>
References: <20100124104239.GA21371@psychotron.redhat.com>
 <20100124.230251.177086043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab0AYIez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 03:34:55 -0500
Content-Disposition: inline
In-Reply-To: <20100124.230251.177086043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 25, 2010 at 08:02:51AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Sun, 24 Jan 2010 11:42:45 +0100
>
>> +#define netdev_uc_count(dev) ((dev)->uc.count)
>> +
>> +#define netdev_get_list_by_addr(a) \
>> +	(container_of((void *) a, struct netdev_hw_addr, addr)->list)
>> +
>> +#define netdev_get_addr_by_list(l) \
>> +	(list_entry(l, struct netdev_hw_addr, list)->addr)
>> +
>> +#define netdev_for_each_addr(a, head)					\
>> +	for (a = netdev_get_addr_by_list((head)->next);			\
>> +	     prefetch(netdev_get_list_by_addr(a).next),			\
>> +	     &netdev_get_list_by_addr(a) != (head);			\
>> +	     a = netdev_get_addr_by_list(netdev_get_list_by_addr(a).next))
>> +
>> +#define netdev_for_each_uc_addr(a, dev)	\
>> +	netdev_for_each_addr(a, &dev->uc.list)
>> +
>
>I should have mentioned this the other day, but I don't like
>having "unsigned char *" being the type of the element iterator.
>
>Sure it allows you, I guess, to eliminate one local variable
>in the places the iterate, but it definitely is at the cost
>of aestetics.
>
>Please use some normal iterating object for the iterator, such as
>"struct list_head *" or "struct netdev_hw_addr *".  Probably the
>latter would work best.

Well I use "unsigned char *" as iterator because it would allow smooth thansition
to list_head in case of mc_list. Currently "struct dev_addr_list" is used to
store address in the list but in the end "struct netdev_hw_addr *" will be used.
To use "struct list_head *" or "struct netdev_hw_addr *" as an iterator it would
be needed to convert all drivers at once and that's not doable. Therefore I see
"unsigned char *" cursor as the best option.

Jirka
>
