From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 09:51:28 +0400
Message-ID: <20060725055127.GA5103@2ka.mipt.ru>
References: <1151708503.11835.8.camel@trinity.ogc.int> <200607011626.04539.ak@suse.de> <adasllh9kj0.fsf@cisco.com> <20060724.150613.54186472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: rdreier@cisco.com, ak@suse.de, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30409 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751041AbWGYFzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 01:55:21 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060724.150613.54186472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 24, 2006 at 03:06:13PM -0700, David Miller (davem@davemloft.net) wrote:
> Don't get too excited about VJ netchannels, more and more roadblocks
> to their practicality are being found every day.
> 
> For example, my idea to allow ESTABLISHED TCP socket demux to be done
> before netfilter is flawed.  Connection tracking and NAT can change
> the packet ID and loop it back to us to hit exactly an ESTABLISHED TCP
> socket, therefore we must always hit netfilter first.

There is no problem with netfilter and process context processing - when
skb is removed from hardware list/array and is being processed by
netfilter in netchannel (or in process context in general), 
there is no problems if changed skb will be rerouted into different 
queue and state.

> All the original costs of route, netfilter, TCP socket lookup all
> reappear as we make VJ netchannels fit all the rules of real practical
> systems, eliminating their gains entirely.  I will also note in
> passing that papers on related ideas, such as the Exokernel stuff, are
> very careful to not address the issue of how practical 1) their demux
> engine is and 2) the negative side effects of userspace TCP
> implementations.  For an example of the latter, if you have some 1GB
> JAVA process you do not want to wake that monster up just to do some
> ACK processing or TCP window updates, yet if you don't you violate
> TCP's rules and risk spurious unnecessary retransmits.

I still plan to continue userspace implementation.

If gigantic-java-monster (tm) is going to read some data - it has been
awakened already, thus it is in the memeory (with linked tcp lib), so
there is zero overhead.

> Furthermore, the VJ netchannel gains can be partially obtained from
> generic stateless facilities that we are going to get anyways.
> Networking chips supporting multiple MSI-X vectors, choosen by hashing
> the flow ID, can move TCP processing to "end nodes" which are cpu
> threads in this case, by having each such MSI-X vector target a
> different cpu thread.

And if that CPU is very busy?
Linux should somehow tell NIC that some CPUs are valid and some are not
right now, but not in a second, so scheduler must be tightly bound with
network internals.

Just my 2 coins.

-- 
	Evgeniy Polyakov
