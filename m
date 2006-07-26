From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] remove CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
Date: Wed, 26 Jul 2006 09:58:25 +0200
Message-ID: <20060726075825.GB28526@lst.de>
References: <20060707091008.GB2543@lst.de> <20060724.153044.10246226.davem@davemloft.net> <ada4px6ipxc.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hch@lst.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:59802 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S964790AbWGZH7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 03:59:45 -0400
To: Roland Dreier <rdreier@cisco.com>
Content-Disposition: inline
In-Reply-To: <ada4px6ipxc.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 24, 2006 at 03:44:15PM -0700, Roland Dreier wrote:
> > skbuff.h has an #ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB to allow
> > architectures to reimplement __dev_alloc_skb.  It's not set on any
> > architecture and now that we have an architecture-overrideable
> > NET_SKB_PAD there is not point at all to have one either.
> 
> I missed this when hch first posted it, sorry.
> 
> But my impression was that the intent of the config option was to let
> Xen hook __dev_alloc_skb() to allocate special receive skbs to handle
> their page-flipping virtual network device.  Which goes beyond
> NET_SKB_PAD.
> 
> So the real question is about Xen hooks I guess -- and given where the
> rest of Xen is, it probably does make sense to go ahead and strip this
> out.

If xen wants to use something else then dev_alloc_skb in their virtual
network driver that's totall fine.  No need to override the definiton of
dev_alloc_skb for that, though.  They can add their own xen_alloc_skb or
opencode the operation they want for it.

Note that overriding dev_alloc_skb is not just utterly pointless but would
even be harmfull in the case they'd finally add pci support for non-dom0
domains and used normaly NIC drivers in there.
