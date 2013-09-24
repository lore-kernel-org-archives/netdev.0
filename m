From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 18:02:23 +0100
Message-ID: <1380042143.2736.48.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924160145.GB26769@order.stressinduktion.org>
	 <1380039299.3165.91.camel@edumazet-glaptop>
	 <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
	 <1380041185.3165.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47352 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab3IXRC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:02:27 -0400
In-Reply-To: <1380041185.3165.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 09:46 -0700, Eric Dumazet wrote:
> On Tue, 2013-09-24 at 09:35 -0700, Tom Herbert wrote:
> 
> > We should really be using rxhash for that anyway, eliminate this
> > ehashfn.  This would entail adding rxhash argument in the various
> > udp_lookup functions.
> 
> Nope : Some NICs provide UDP rxhash only using L3  (source IP,
> destination IP), not L4 (adding source & destination ports)

Indeed the Microsoft RSS spec doesn't define an L4 hash for UDP/IP,
since it can't work with fragmented datagrams (which TCP avoids).  Using
the TCP/IP hash function for UDP is a non-standard option - presumably
useful where no fragmentation is expected.

Ben.

> This is again a case where we want our own hashing.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
