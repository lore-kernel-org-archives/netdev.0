From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 02:13:38 +0200
Message-ID: <20061011001338.GA30093@mellanox.co.il>
References: <20061010104315.61540986@freekitty>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, openib-general@openib.org,
	Roland Dreier <rolandd@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dev.mellanox.co.il ([194.90.237.44]:63361 "EHLO
	dev.mellanox.co.il") by vger.kernel.org with ESMTP id S1030719AbWJKAOJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 20:14:09 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061010104315.61540986@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Stephen Hemminger <shemminger@osdl.org>:
> > > > I'm trying to build a network device driver supporting a very large MTU
> > > > (around 64K) on top of an infiniband connection, and I've hit a couple
> > > > of issues I'd appreciate some feedback on:
> > > > 
> > > > 1. On the send side,
> > > >    I've set NETIF_F_SG, but hardware does not support checksum
> > > >    offloading, and I see "dropping NETIF_F_SG since no checksum feature"
> > > >    warning, and I seem to be getting large packets all in one chunk.
> > > >    The reason I've set NETIF_F_SG, is because I'm concerned that under
> > > >    real life stress Linux won't be able to allocate 64K of continuous
> > > >    memory.
> > > > 
> > > >    Is this concern of mine valid? I saw in-tree drivers allocating at
> > > >    least 8K.  What's the best way to enable S/G on send side?  Is
> > > >    checksum offloading really required for S/G?
> > > 
> > > Yes, in the current implementation, Linux needs checksum offload. But
> > > there is no reason, your driver can't compute the checksum in software.
> > >
> > I'm worried whether an extra pass over data won't eat up all of
> > the performance gains I get from the large MTU ...
> 
> Yup, the cost is in touching the data, not in the copy.

Maybe I can patch linux to allow SG without checksum?
Dave, maybe you could drop a hint or two on whether this is worthwhile
and what are the issues that need addressing to make this work?

I imagine it's not just the matter of changing net/core/dev.c :).

-- 
MST
