From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 15:23:53 -0700 (PDT)
Message-ID: <20060724.152353.31604681.davem@davemloft.net>
References: <1151708503.11835.8.camel@trinity.ogc.int>
	<200607011626.04539.ak@suse.de>
	<1152119382.20248.51.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49826
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932280AbWGXWXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:23:43 -0400
To: tom@opengridcomputing.com
In-Reply-To: <1152119382.20248.51.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Tucker <tom@opengridcomputing.com>
Date: Wed, 05 Jul 2006 12:09:42 -0500

> "A TOE net stack is closed source firmware. Linux engineers have no way
> to fix security issues that arise. As a result, only non-TOE users will
> receive security updates, leaving random windows of vulnerability for
> each TOE NIC's users."
> 
> - A Linux security update may or may not be relevant to a vendors
> implementation. 
> 
> - If a vendor's implementation has a security issue then the customer
> must rely on the vendor to fix it. This is no less true for iWARP than
> for any adapter.

This isn't how things actually work.

Users have a computer, and they can rightly expect the community
to help them solve problems that occur in the upstream kernel.

When a bug is found and the person is using NIC X, we don't
necessarily forward the bug report to the vendor of NIC X.
Instead we try to fix the bug.  Many chip drivers are maintained
by people who do not work for the company that makes the chip,
and this works just fine.

If only the chip vendor can fix a security problem, this makes Linux
less agile to fix.  Even aspect of a problem on a Linux system that
cannot be fixed entirely by the community is a net negative for Linux.

> - iWARP needs to do protocol processing in order to validate and
> evaluate TCP payload in advance of direct data placement. This
> requirement is independent of CPU speed. 

Yet, RDMA itself is just an optimization meant to deal with
limitations of cpu and memory speed.  You can rephrase the
situation in whatever way suits your argument, but it does not
make the core issue go away :)

> - I suspect that connection rates for RDMA adapters fall well-below the
> rates attainable with a dumb device. That said, all of the RDMA
> applications that I know of are not connection intensive. Even for TOE,
> the later HTTP versions makes connection rates less of an issue.

This is a very naive evaluation of the situation.  Yes, newer
versions of protocols such as HTTP make the per-client connection
burdon lower, but the number of clients will increase in time to
more than makeup for whatever gains are seen due to this.

And then you have protocols which by design are connection heavy,
and rightly so, such as bittorrent.

Being able to handle enormous numbers of connections, with extreme
scalability and low latency, is an absolute requirement of any modern
day serious TCP stack.  And this requirement is not going away.
Wishing this requirement away due to HTTP persistent connections is
very unrealistic, at best.

> - This is the problem we're trying to solve...incrementally and
> responsibly.

You can't.  See my email to Roland about why even VJ net channels
are found to be impractical.  To support netfilter properly, you
must traverse the whole netfilter stack, because NAT can rewrite
packets, yet still make them destined for the local system, and
thus they will have a different identity for connection demux
by the time the TCP stack sees the packet.

All of these tranformations occur between normal packet receive
and the TCP stack.  You would therefore need to put your card
between netfilter and TCP in the packet input path, and at that
point why bother with the stateful card at all?

The fact is that stateless approaches will always be better than
stateful things because you cannot replicate the functionality we
have in the Linux stack without replicating 10 years of work into
your chip's firmware.  At that point you should just run Linux
on your NIC since that is what you are effectively doing :)

In conversations such as these, it helps us a lot if you can be frank
and honest about the true absolute limitations of your technology.  I
can see that your viewpoint is tainted when I hear things such as HTTP
persistent connections being used as a reason why high TCP connection
rates won't matter in the future.  Such assertions are understood to
be patently false by anyone who understands TCP and how it is used in
the real world.
