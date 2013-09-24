From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 10:34:35 -0700
Message-ID: <1380044075.3165.108.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924160145.GB26769@order.stressinduktion.org>
	 <1380039299.3165.91.camel@edumazet-glaptop>
	 <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
	 <1380041185.3165.97.camel@edumazet-glaptop>
	 <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:64855 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab3IXReg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:34:36 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so4873768pdj.36
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 10:34:36 -0700 (PDT)
In-Reply-To: <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 10:03 -0700, Tom Herbert wrote:
> On Tue, Sep 24, 2013 at 9:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2013-09-24 at 09:35 -0700, Tom Herbert wrote:
> >
> >> We should really be using rxhash for that anyway, eliminate this
> >> ehashfn.  This would entail adding rxhash argument in the various
> >> udp_lookup functions.
> >
> > Nope : Some NICs provide UDP rxhash only using L3  (source IP,
> > destination IP), not L4 (adding source & destination ports)
> >
> Then the NIC won't set l4_rxhash and we'll rehash over 4-tuple when
> skb_get_rxhash is called.

Yes, but then in this case you add cpu cycles for no reason.

If you have multiqueue NIC, you do not use RPS/RFS, so skb->rxhash might
be 0

hash = inet_ehashfn(net, daddr, hnum, saddr, sport);

is faster than the whole flow dissection game.
