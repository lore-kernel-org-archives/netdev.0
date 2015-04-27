From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v7] Add support of Cavium Liquidio ethernet
 adapters
Date: Mon, 27 Apr 2015 17:04:35 +0000
Message-ID: <BY1PR0701MB1706783543EEC1BED49CEE84FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
References: <1429922056-14124-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<20150426.160407.2043024228389437605.davem@davemloft.net>
	<BY1PR0701MB1706BF510E830F151F5E1BC5FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
 <20150427.122731.2291810668949579803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0077.outbound.protection.outlook.com ([157.56.110.77]:26496
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932925AbbD0REi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:04:38 -0400
In-Reply-To: <20150427.122731.2291810668949579803.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >>
> >> It is extremely disappointing that you've defined your own debug
> >> logging macros, which use generic dev_*() printks, instead of using
> >> the proper netdev_*() printk logging interfaces to do this.
> >
> > We can make this change. I'm not sure why it was missed since we
> > have netif_level support. Please note, we will still need to use the
> > dev_ macros for those places in the driver where we don't have a
> > netdev yet.
> 
> Of course.
> 
> But there is no reason to go through a special locally defined
> macros to do this stuff.  Just invoke dev_* and netdev_* directly.

I think the main reason we're doing this is because we're passing around
struct octeon_device (which has a pcI_dev pointer and a netdev pointer)
through some parts of the code and felt the consistency in the printk
interface was better than having extra pointer dereferences (like
&oct->pci_dev->dev) inline in the code.  Do you mind if we keep wrappers
for those pieces? The other places where netdev is immediately available
can easily be changed.
