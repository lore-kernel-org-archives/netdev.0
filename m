From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 7 Jan 2011 10:23:58 +0900
Message-ID: <20110107012356.GA1257@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrote:

[ snip ]
> 
> I know that everyone likes a nice netperf result but I agree with
> Michael that this probably isn't the right question to be asking.  I
> don't think that socket buffers are a real solution to the flow
> control problem: they happen to provide that functionality but it's
> more of a side effect than anything.  It's just that the amount of
> memory consumed by packets in the queue(s) doesn't really have any
> implicit meaning for flow control (think multiple physical adapters,
> all with the same speed instead of a virtual device and a physical
> device with wildly different speeds).  The analog in the physical
> world that you're looking for would be Ethernet flow control.
> Obviously, if the question is limiting CPU or memory consumption then
> that's a different story.

Point taken. I will see if I can control CPU (and thus memory) consumption
using cgroups and/or tc.

> This patch also double counts memory, since the full size of the
> packet will be accounted for by each clone, even though they share the
> actual packet data.  Probably not too significant here but it might be
> when flooding/mirroring to many interfaces.  This is at least fixable
> (the Xen-style accounting through page tracking deals with it, though
> it has its own problems).

Agreed on all counts.


