From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 15:46:12 +1000
Message-ID: <1153979173.6904.100.camel@localhost.localdomain>
References: <20060718081625.GA13830@2ka.mipt.ru>
	 <20060718230121.GA31474@ms2.inr.ac.ru>
	 <1153966671.6904.71.camel@localhost.localdomain>
	 <20060726.221708.123400049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:60642 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751797AbWG0FqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 01:46:15 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.221708.123400049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-26 at 22:17 -0700, David Miller wrote:
> I read this as "we will be able to get around the problems" but
> no specific answer as to "how".  I am an optimist too but I want
> to start seeing concrete discussion about the way in which the
> problems will be dealt with.
> 
> Alexey has some ideas, such as running the netfilter path from the
> netchannel consumer socket context.  That is the kind of thing
> we need to be talking about.

Yes, my first thought back in January was how netfilter would interact
with this in a sane way.  One answer is "don't": once someone registers
on any hook we go into slow path.  Another is to run the hooks in socket
context, which is better, but precludes having the consumer in
userspace, which still appeals to me 8)

So I don't like either.  The mistake (?) with netfilter was that we are
completely general: you will see all packets, do what you want.  If,
instead, we had forced all rules to be of form "show me all packets
matching this tuple" we would be in a combine it in a single lookup with
routing etc.

What would the tuple look like?  Off the top of my head:
SRCIP/DSTIP/PROTO/SPT/DPT/IN/OUT (where IN and OUT are boolean values
indicating whether the src/dest is local).

Of course, it means rewriting all the userspace tools, documentation,
and creating a complete new infrastructure for connection tracking and
NAT, but if that's what's required, then so be it.

Rusty.
-- 
Help! Save Australia from the worst of the DMCA: http://linux.org.au/law

