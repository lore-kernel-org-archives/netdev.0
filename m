From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Fri, 6 Apr 2012 11:19:12 -0700
Message-ID: <20120406111912.172bb1fb@nehalam.linuxnetplumber.net>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
	<4F7CD4BC.4000006@enea.com>
	<20120404165559.5223ab95@s6510.linuxnetplumber.net>
	<20120404.202109.2046106039992811660.davem@davemloft.net>
	<4F7F10FC.3020308@enea.com>
	<1333731991.3282.17.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <arvid.brodin@enea.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<balferreira@googlemail.com>, <arvid.brodin@xdin.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45653 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907Ab2DFSTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 14:19:15 -0400
In-Reply-To: <1333731991.3282.17.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Apr 2012 18:06:31 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Fri, 2012-04-06 at 17:51 +0200, Arvid Brodin wrote:
> > David Miller wrote:
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Wed, 4 Apr 2012 16:55:59 -0700
> > > 
> > >> That isn't so bad, doing a memcpy versus a structure copy.
> > > 
> > > GCC is going to inline the memcpy and thus we'll still do the
> > > unaligned accesses.  This change therefore won't fix the problem.
> > 
> > Well, it does work for me, with gcc-4.2.2-compiled linux-2.6.37 running
> > on an AVR32 board.
> > 
> > Just out of curiosity, what's the mechanism behind this inline
> > assignment that turns the memcpy into an unaligned access? If gcc is 
> > "smart" enough to detect a bunch of char * accesses and turn them 
> > into unaligned 32-bit accesses, isn't that a bug in gcc?
> 
> If I remember correctly, casting a char* pointer to foo* where the
> original pointer isn't properly aligned for type foo results in
> undefined behaviour.  And that is what icmp_hdr() is doing, so there is
> no requirement that the compiler does anything reasonable with the
> result.  Removing that cast (using skb_transport_header() instead of
> icmp_hdr()) should avoid that.
> 
> (We do generally assume, however, that if the processor can handle
> unaligned accesses in a useful way then the compiler will be reasonable
> and not break them.)
> 
> Ben.
>  
> > Or will this only happen on archs which __HAVE_ARCH_MEMCPY? (But looking
> > at a couple of arch/xxx/lib/string.c, these too seem to take alignment
> > into account.)
> > 
> 

Since icmp_hdr is 64 bits you might be able to use get_unaligned64
in some way.
