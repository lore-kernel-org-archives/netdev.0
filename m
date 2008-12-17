From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Re: Bonding gigabit and fast?
Date: Wed, 17 Dec 2008 07:51:42 +0000
Message-ID: <200812170751.42387.tvrtko@ursulin.net>
References: <200812161939.30033.tvrtko@ursulin.net> <200812162255.47731.tvrtko@ursulin.net> <20484.1229489335@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-5-a-2.mail.uk.tiscali.com ([212.74.114.4]:6163
	"EHLO mk-outboundfilter-5-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759247AbYLQHvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 02:51:46 -0500
In-Reply-To: <20484.1229489335@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 December 2008 04:48:55 Jay Vosburgh wrote:
> Tvrtko A. Ursulin <tvrtko@ursulin.net> wrote:
> [...]
>
> >I was using balance-rr, alb flavour does not seem to like 8139too.
>
> 	The choice of balance-rr may be half of your problem.  Try
> balance-xor with xmit_hash_policy=layer3+4, it may behave better.  That
> mode doesn't know about dissimilar speed slaves, so it simply balances
> by math, but that still may behave better than balance-rr because it
> won't stripe single connections across slaves.
>
> 	The balance-alb mode would likely be better (it's smarter about
> balancing across slaves of differing speeds), but requires that the
> slaves be able to change MAC address while up, which not every device is
> capable of doing.
>
> 	To elaborate a bit on balance-rr, it will usually cause out of
> order delivery to varying degrees, which in turn causes TCP's congestion
> control and/or fast retransmits to kick in.  The effect can be mitigated
> to some degree (but not eliminated) by raising the value of the
> net.ipv4.tcp_reordering sysctl.  If memory serves, values more than
> about 125 don't make much additional difference.

Yes, makes sense and is in line from what is written in the bonding HOWTO. My 
problem is that I actually wanted to stripe single connections in order to 
work around really slow gigabit (slower than fast ethernet) performance. 
There is a single GbE link on the receiver side so maybe there shouldn't be 
that much out of order traffic, although something is causing aggregated 
bandwith to be around 50% less than hypothetical sum of two (9+9 alone vs 12 
bonded). And without stripping I couldn't measure aggregated bandwith with a 
single client.

Subject I put for this thread is actually misleading..

Thanks,

Tvrtko
