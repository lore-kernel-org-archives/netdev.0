From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Fri, 6 Apr 2012 18:06:31 +0100
Message-ID: <1333731991.3282.17.camel@deadeye>
References: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
		<4F7CD4BC.4000006@enea.com>
		<20120404165559.5223ab95@s6510.linuxnetplumber.net>
	 <20120404.202109.2046106039992811660.davem@davemloft.net>
	 <4F7F10FC.3020308@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <balferreira@googlemail.com>,
	<arvid.brodin@xdin.com>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36760 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756009Ab2DFRGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 13:06:37 -0400
In-Reply-To: <4F7F10FC.3020308@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-06 at 17:51 +0200, Arvid Brodin wrote:
> David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Wed, 4 Apr 2012 16:55:59 -0700
> > 
> >> That isn't so bad, doing a memcpy versus a structure copy.
> > 
> > GCC is going to inline the memcpy and thus we'll still do the
> > unaligned accesses.  This change therefore won't fix the problem.
> 
> Well, it does work for me, with gcc-4.2.2-compiled linux-2.6.37 running
> on an AVR32 board.
> 
> Just out of curiosity, what's the mechanism behind this inline
> assignment that turns the memcpy into an unaligned access? If gcc is 
> "smart" enough to detect a bunch of char * accesses and turn them 
> into unaligned 32-bit accesses, isn't that a bug in gcc?

If I remember correctly, casting a char* pointer to foo* where the
original pointer isn't properly aligned for type foo results in
undefined behaviour.  And that is what icmp_hdr() is doing, so there is
no requirement that the compiler does anything reasonable with the
result.  Removing that cast (using skb_transport_header() instead of
icmp_hdr()) should avoid that.

(We do generally assume, however, that if the processor can handle
unaligned accesses in a useful way then the compiler will be reasonable
and not break them.)

Ben.
 
> Or will this only happen on archs which __HAVE_ARCH_MEMCPY? (But looking
> at a couple of arch/xxx/lib/string.c, these too seem to take alignment
> into account.)
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
