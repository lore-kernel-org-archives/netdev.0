From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 2/2] net: make net and forcedeth to use kmalloc_node
Date: Wed, 4 Jul 2007 10:00:29 -0700
Message-ID: <86802c440707041000m1378823dwff25ace3e93e54fe@mail.gmail.com>
References: <200706291330.37070.yinghai.lu@sun.com>
	 <20070703115840.e05a0f47.akpm@linux-foundation.org>
	 <20070704084938.GA19515@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Christoph Hellwig" <hch@infradead.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Yinghai Lu" <Yinghai.Lu@sun.com>, "Andi Kleen" <ak@suse.de>,
	"Greg KH" <greg@kroah.com>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:53324 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbXGDRAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 13:00:30 -0400
Received: by wa-out-1112.google.com with SMTP id v27so3309124wah
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 10:00:30 -0700 (PDT)
In-Reply-To: <20070704084938.GA19515@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/4/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Jul 03, 2007 at 11:58:40AM -0700, Andrew Morton wrote:
> > >
> > >     while (np->put_rx.orig != less_rx) {
> > > -           struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
> > > +           struct sk_buff *skb = dev_alloc_skb_node(np->rx_buf_sz + NV_RX_ALLOC_PAD, dev_to_node(&dev->dev));
> >
> > If we're going to do this then it would probably make sense to change
> > dev_alloc_skb_node() so that it takes a `struct net_device *' rather than a
> > bare node-id.  That's a call which the net guys will need to make, which is
> > why we cc them on our emails.
>
> That thing is called netdev_alloc_skb and already exists.  And it's indeed
> what they should be using in the rx path.
>
> -
please check
http://lkml.org/lkml/2007/7/3/418

[PATCH 3/4] net: make forcedeth to use kmalloc_node and
__netdev_alloc_skb for skb allocation

but need to replace __netdev_alloc_skb to netdev_alloc_skb.

YH
