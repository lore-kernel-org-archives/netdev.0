From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 04:30:38 +0200
Message-ID: <20130924023038.GA22393@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46699 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab3IXCak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 22:30:40 -0400
Content-Disposition: inline
In-Reply-To: <1379980991.3165.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 05:03:11PM -0700, Eric Dumazet wrote:
> On Mon, 2013-09-23 at 15:41 -0700, Tom Herbert wrote:
> 
> > +#ifdef CONFIG_NET_TOEPLITZ
> > +	toeplitz_net = toeplitz_alloc();
> > +	if (!toeplitz_net)
> > +		goto out;
> > +
> > +	toeplitz_init(toeplitz_net, NULL);
> > +#endif
> > +
> 
> Hmm
> 
> 1) Security alert here.
> 
> Many devices (lets say Android phones) have no entropy at this point,
> all devices will have same toeplitz key.
> 
> Check build_ehash_secret() for a possible point for the feeding of the
> key. (and commit 08dcdbf6a7b9d14c2302c5bd0c5390ddf122f664 )
> 
> If hardware toeplitz is ever used, we want to make sure every host uses
> a private and hidden Toeplitz key.

I just had a look at it myself and have one question:

ipv6/af_inet6.c:
112         if (sock->type != SOCK_RAW &&
113             sock->type != SOCK_DGRAM &&
114             !inet_ehash_secret)
115                 build_ehash_secret();

ipv4/af_inet.c:
289         if (unlikely(!inet_ehash_secret))
290                 if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
291                         build_ehash_secret();


Why do we care about the sock->type?

build_ehash_secret builds up the data which seeds fragmentation ids, ephermal
port randomization etc. Could we drop the check of sock->type? I guess the
idea was that in-kernel sockets of type raw/udp do not seed the keys when no
entropy is available?

Thanks,

  Hannes
