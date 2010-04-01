From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Thu, 1 Apr 2010 02:55:39 +0200
Message-ID: <20100401005539.GZ20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <1270078984.2389.33.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Andi Kleen <andi@firstfloor.org>,
	netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59759 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757179Ab0DAAzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:55:44 -0400
Content-Disposition: inline
In-Reply-To: <1270078984.2389.33.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 10:13:04AM +1030, Glen Turner wrote:
> On Mon, 2010-03-29 at 10:01 -0700, Rick Jones wrote:
> 
> > But which of the last N datagrams sent by the application should be retained for 
> > retransmission?  It could be scores if not hundreds of datagrams depending on 
> > the behaviour of the application and the latency to the narrow part of the network.
> 
> We don't need that sort of exotica from the kernel.  The applications
> have to be prepared to retransmit lost packets in any case.
> 
> What we need is an API for an instant notification that a ICMP Packet
> Too Big message has arrived concerning the socket.

That already exists of course: IP_RECVERR

> As for David Miller's rant, the applications currently have no choice
> but to "do it stupidly" as the kernel doesn't pass enough information
> for user space to do it intelligently.  If the kernel passed user space
> the same indication as TCP gets, then we could -- and would -- do it
> right.

That's wrong. Linux has supported UDP/RAW pmtu discovery since many many
years.

I have a really old presentation on it (from 2000 or so):

http://halobates.de/net-topics/text33.htm
http://halobates.de/net-topics/text34.htm
http://halobates.de/net-topics/text35.htm
http://halobates.de/net-topics/text36.htm

It's also in the manpages.

However I suspect it's too much work to change a lot of applications
to that, so I suspect the IPV6_MIN_MTU workaround is still needed.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
