From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 13:32:02 +0400
Message-ID: <20060816093159.GA31882@2ka.mipt.ru>
References: <20060816053545.GB22921@2ka.mipt.ru> <20060816084808.GA7366@infradead.org> <20060816090028.GA25476@2ka.mipt.ru> <20060816.020503.74744144.davem@davemloft.net> <20060816091029.GA6375@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38118 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751055AbWHPJcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 05:32:50 -0400
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060816091029.GA6375@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 10:10:29AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> On Wed, Aug 16, 2006 at 02:05:03AM -0700, David Miller wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Wed, 16 Aug 2006 13:00:31 +0400
> > 
> > > So I would like to know how to determine which node should be used for
> > > allocation. Changes of __get_user_pages() to alloc_pages_node() are
> > > trivial.
> > 
> > netdev_alloc_skb() knows the netdevice, and therefore you can
> > obtain the "struct device;" referenced inside of the netdev,
> > and therefore you can determine the node using the struct
> > device.
> 
> It's not that easy unfortunately.  I did what you describe above in my
> first prototype but then found out the hard way that the struct device
> in the netdevice can be a non-pci one, e.g. for pcmcia.  Im that case
> the kernel will crash on you becuase you can only get the node infortmation
> for pci devices.  My current patchkit adds an "int node" member to struct
> net_device instead.  I can repost the patchkit ontop of -mm (which is
> the required slab memory leak tracking changes) if anyone cares.

Can we check device->bus_type or device->driver->bus against
&pci_bus_type for that?

-- 
	Evgeniy Polyakov
