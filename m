From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC] tcp demux used to signal ip_route_input_noref to not cache dst
Date: Wed, 27 Jun 2012 15:25:58 +0200
Message-ID: <201206271526.16502.hans.schillstrom@ericsson.com>
References: <1340781553.10893.414.camel@edumazet-glaptop> <1340783533.26242.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:63826 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328Ab2F0N0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 09:26:22 -0400
In-Reply-To: <1340783533.26242.2.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 June 2012 09:52:13 Eric Dumazet wrote:
> On Wed, 2012-06-27 at 09:19 +0200, Eric Dumazet wrote:
> > In case tcp_v{4|6}_early_demux() doesnt find an ESTABLISHED socket, and
> > SYN flag is set, and an "atomic_t listener_under_synflood" counter is
> > not 0, we could :
> > 
> > - instruct make ip_rcv_finish() to not cache the input dst into route
> > cache (if dst is not found in the hash table)
> > 
> > This would make synflood attacks having minimal impact on route cache
> > 
> > (We did this for the output dst of SYN-cookie-ACK messages)
> > 
> > 
> 
> I'll test the following patch in a moment.
> 
> For the moment, set nocache to true for all frames not associated to an
> ESTABLISHED socket. Not sure we want to test SYN flag after all.

Nice work, 
I have been runing the patch for almost 4 hours now 
not a single message about the routing cache !

BTW 
I also use the "tcp: avoid tx starvation by SYNACK packets" patch
and jhash patch for syn cookies.
Not a packet single packet is dropped now.

I even works nice in a KVM I have never been close to this results with KVM.
