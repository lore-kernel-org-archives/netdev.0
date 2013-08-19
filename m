From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 14:08:47 -0700
Message-ID: <1376946527.4226.80.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	  <1376839467.21329.36.camel@edumazet-glaptop>
	  <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	  <1376870425.4226.25.camel@edumazet-glaptop>
	  <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
	  <1376918657.4226.59.camel@edumazet-glaptop>
	  <20130819134919.GF3583@cpaasch-mac>
	 <1376920685.4226.61.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308192207130.27869@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34381 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab3HSVIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 17:08:49 -0400
In-Reply-To: <alpine.DEB.2.00.1308192207130.27869@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-19 at 22:13 +0200, Jozsef Kadlecsik wrote:
> On Mon, 19 Aug 2013, Eric Dumazet wrote:
> 
> > On Mon, 2013-08-19 at 15:49 +0200, Christoph Paasch wrote:
> >
> > > It's a TCP-patch, that interprets duplicate-acks with invalid SACK-blocks as
> > > duplicate acks in tcp_sock->sacked_out.
> > 
> > Yeah, but here, this is conntrack who is blocking the thing.
> > 
> > TCP receiver has no chance to 'fix' it.
> > 
> > See conntrack is one of those buggy middle box as well.
> > 
> > So if you want to properly handle this mess, you'll also have to fix
> > conntrack.
> 
> I beg you pardon: why conntrack should be relaxed, when it is expected
> to do more strict TCP checkings (RFC5961, Section 5.).
> 
> Also, it's clearly a broken middle box. Don't shoot the messenger.

Frames are dropped by conntrack, before TCP receiver can even have a
choice.

So Christoph patch would be of no use for Corey.

I do not think I shot anyone, only stated the truth.

We have workarounds in our stack to 'fix' bugs from others, there
is no shame in this.

Glad to see you are interested in RFC 5961 support, as conntrack is
known to break the ACK challenges in response to RST messages (section
3)
