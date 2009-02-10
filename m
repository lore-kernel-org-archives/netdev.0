From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Tue, 10 Feb 2009 15:21:43 -0800 (PST)
Message-ID: <20090210.152143.176850113.davem@davemloft.net>
References: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	<m3vdrja6oe.fsf@intrepid.localdomain>
	<46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: risto.suominen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754749AbZBJXVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 18:21:49 -0500
In-Reply-To: <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Risto Suominen <risto.suominen@gmail.com>
Date: Mon, 9 Feb 2009 21:22:03 +0200

> 2009/2/9 Krzysztof Halasa <khc@pm.waw.pl>:
> > Potentially any driver is affected by such coherency problem, this can't
> > be specific to 21040.
> >
> I agree. That talks for the config solution.

I think the pci_alloc_consistent() implementation for your particular
platform should be fixed instead :-)

It should be using uncacheable cpu mappings of the returned memory if
the cpu lacks cache coherency with DMA.

Peppering all kinds of drivers with this kind of change being proposed
here is not the way to handle this problem.  It makes the creation of
the abstractions we created with pci_alloc_consistent() and friends
totally useless.

Drivers have to be able to say "what I write to this memory the device
will see, and what the device writes the cpu will see" and they have
to be able to say this regardless of details like cache alignment and
other things that they should have no business knowing about.
