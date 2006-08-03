From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 3 Aug 2006 19:53:26 -0400
Message-ID: <20060803235326.GC7894@thunk.org>
References: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au> <1154630207.3117.17.camel@rh4> <20060803201741.GA7894@thunk.org> <20060803.144845.66061203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:21644 "EHLO thunker.thunk.org")
	by vger.kernel.org with ESMTP id S1751403AbWHCXxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 19:53:35 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060803.144845.66061203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 02:48:45PM -0700, David Miller wrote:
> > eth0: Tigon3 [partno(BCM95704s) rev 2100 PHY(serdes)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:14:5e:86:44:24
> 
> The 5704 chip will set TG3_FLAG_TAGGED_STATUS, and therefore
> doesn't need the periodic poking done by tg3_timer().

Hmm.... all I can say is that I could reliably knock the box off the
network by running a four processes that tied up all CPU's at high
real-time priorities, and after I applied the horrible hack that
guaranteed that tg3_timer() was run every 0.128 seconds, the system
stayed on the network.  I'm not sure why, but it did fix the problem.  

Any suggestions on how I could figure out what was really going on and
what would be a better fix would be greatly appreciated.

					- Ted
