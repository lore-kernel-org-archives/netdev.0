From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
Date: Wed, 4 Jul 2007 09:54:00 -0700
Message-ID: <86802c440707040954w409c50b5qf9016db7f567479e@mail.gmail.com>
References: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
	 <200707031730.51677.yinghai.lu@sun.com>
	 <20070704085120.GB19515@infradead.org>
	 <20070704.033530.105423846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, ak@suse.de, greg@kroah.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.232]:6038 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbXGDQyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 12:54:03 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1615411nze
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 09:54:00 -0700 (PDT)
In-Reply-To: <20070704.033530.105423846.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/4/07, David Miller <davem@davemloft.net> wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 4 Jul 2007 09:51:20 +0100
>
> > On Tue, Jul 03, 2007 at 05:30:51PM -0700, Yinghai Lu wrote:
> > > [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
> > >
> > > Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index 27cfe5f..005cc1c 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -217,7 +217,7 @@ nodata:
> > >  struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> > >             unsigned int length, gfp_t gfp_mask)
> > >  {
> > > -   int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> > > +   int node = dev_to_node(&dev->dev);
> >
> > This looks wrong to me unless the device model has once again changed
> > silently.  When I wrote this code &dev->dev was a device allocated
> > as part of the netdevice and the parent is the pci (or whatever) device
> > that has the node information.
>
> Correct, this change is completely bogus.
> -

please check that with

http://lkml.org/lkml/2007/7/3/419

[PATCH 1/4] try parent numa_node at first before using default

YH
