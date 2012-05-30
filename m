From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
Date: Wed, 30 May 2012 13:14:32 +0200
Message-ID: <201205301324.01548.hans.schillstrom@ericsson.com>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <201205301013.10797.hans.schillstrom@ericsson.com> <1338366288.2760.115.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:43676 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797Ab2E3LYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 07:24:07 -0400
In-Reply-To: <1338366288.2760.115.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 May 2012 10:24:48 Eric Dumazet wrote:
> On Wed, 2012-05-30 at 10:03 +0200, Hans Schillstrom wrote:
> 
> > We have this option running right now, and it gave slightly higher values.
> > The upside is only one core is running at 100% load.
> > 
> > To be able to process more SYN an attempt was made to spread them with RPS to 
> > 2 other cores gave 60% more SYN:s per sec
> > i.e. syn filter in NIC sending all irq:s to one core gave ~ 52k syn. pkts/sec
> > adding RPS and sending syn to two other core:s gave ~80k  syn. pkts/sec
> > Adding more cores than two didn't help that much.
> 
> When you say 52.000 pkt/s, is that for fully established sockets, or
> SYNFLOOD ?

SYN Flood with hping3  random source ip, dest port 5060
and there is a listener on that port.
(kernel 3.0.13)

> 19.23 us to handle _one_ SYN message seems pretty wrong to me, if there
> is no contention on listener socket.
> 

BTW. 
I also see a strange behavior during SYN flood.
The client starts data sending directly in the ack, 
and that first packet is more or less always retransmitted once.

I'll dig into that later, or do anyone have an idea of the reason ?
