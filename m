From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] Add support of Cavium Liquidio ethernet
 adapters
Date: Mon, 27 Apr 2015 13:22:42 -0400 (EDT)
Message-ID: <20150427.132242.1898729531212160949.davem@davemloft.net>
References: <BY1PR0701MB1706BF510E830F151F5E1BC5FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
	<20150427.122731.2291810668949579803.davem@davemloft.net>
	<BY1PR0701MB1706783543EEC1BED49CEE84FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Raghu.Vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	Satananda.Burla@caviumnetworks.com,
	Felix.Manlunas@caviumnetworks.com
To: Derek.Chickles@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbbD0RWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:22:44 -0400
In-Reply-To: <BY1PR0701MB1706783543EEC1BED49CEE84FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Date: Mon, 27 Apr 2015 17:04:35 +0000

> 
>> >>
>> >> It is extremely disappointing that you've defined your own debug
>> >> logging macros, which use generic dev_*() printks, instead of using
>> >> the proper netdev_*() printk logging interfaces to do this.
>> >
>> > We can make this change. I'm not sure why it was missed since we
>> > have netif_level support. Please note, we will still need to use the
>> > dev_ macros for those places in the driver where we don't have a
>> > netdev yet.
>> 
>> Of course.
>> 
>> But there is no reason to go through a special locally defined
>> macros to do this stuff.  Just invoke dev_* and netdev_* directly.
> 
> I think the main reason we're doing this is because we're passing around
> struct octeon_device (which has a pcI_dev pointer and a netdev pointer)
> through some parts of the code and felt the consistency in the printk
> interface was better than having extra pointer dereferences (like
> &oct->pci_dev->dev) inline in the code.  Do you mind if we keep wrappers
> for those pieces? The other places where netdev is immediately available
> can easily be changed.

I don't think this is reasonable.

You can always get to the octeon_device object from the netdev pointer,
so pass that everywhere.
