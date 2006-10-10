From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 16:43:30 +0200
Message-ID: <20061010144330.GA28175@mellanox.co.il>
References: <20061009095051.38ed9f22@freekitty>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, openib-general@openib.org,
	Roland Dreier <rolandd@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:58753 "EHLO
	dev.mellanox.co.il") by vger.kernel.org with ESMTP id S932130AbWJJOn6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 10:43:58 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061009095051.38ed9f22@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Stephen Hemminger <shemminger@osdl.org>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
> On Mon, 9 Oct 2006 19:47:05 +0200
> "Michael S. Tsirkin" <mst@mellanox.co.il> wrote:
> 
> > Hi!
> > I'm trying to build a network device driver supporting a very large MTU (around 64K)
> > on top of an infiniband connection, and I've hit a couple of issues I'd
> > appreciate some feedback on:
> > 
> > 1. On the send side,
> >    I've set NETIF_F_SG, but hardware does not support checksum offloading,
> >    and I see "dropping NETIF_F_SG since no checksum feature" warning,
> >    and I seem to be getting large packets all in one chunk.
> >    The reason I've set NETIF_F_SG, is because I'm concerned that under real life
> >    stress Linux won't be able to allocate 64K of continuous memory.
> > 
> >    Is this concern of mine valid? I saw in-tree drivers allocating at least 8K.
> >    What's the best way to enable S/G on send side?
> >    Is checksum offloading really required for S/G?
> 
> Yes, in the current implementation, Linux needs checksum offload. But there
> is no reason, your driver can't compute the checksum in software.

Are there drivers that do this already? Couldn't find any such beast ...

I'm worried whether an extra pass over data won't eat up all of
the performance gains I get from the large MTU ...

> >    What are the helpers legal for fragmented skb?

BTW, I found skb_put_frags in sky2 which seems generic enough - I even wander
why isn't this in net/core.

Thanks!

-- 
MST
