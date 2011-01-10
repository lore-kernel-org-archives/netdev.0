From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Mon, 10 Jan 2011 18:31:55 +0900
Message-ID: <20110110093155.GB13420@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
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
In-Reply-To: <20110107012356.GA1257@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wrote:
> On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrote:
> 
> [ snip ]
> > 
> > I know that everyone likes a nice netperf result but I agree with
> > Michael that this probably isn't the right question to be asking.  I
> > don't think that socket buffers are a real solution to the flow
> > control problem: they happen to provide that functionality but it's
> > more of a side effect than anything.  It's just that the amount of
> > memory consumed by packets in the queue(s) doesn't really have any
> > implicit meaning for flow control (think multiple physical adapters,
> > all with the same speed instead of a virtual device and a physical
> > device with wildly different speeds).  The analog in the physical
> > world that you're looking for would be Ethernet flow control.
> > Obviously, if the question is limiting CPU or memory consumption then
> > that's a different story.
> 
> Point taken. I will see if I can control CPU (and thus memory) consumption
> using cgroups and/or tc.

I have found that I can successfully control the throughput using
the following techniques

1) Place a tc egress filter on dummy0

2) Use ovs-ofctl to add a flow that sends skbs to dummy0 and then eth1,
   this is effectively the same as one of my hacks to the datapath
   that I mentioned in an earlier mail. The result is that eth1
   "paces" the connection.

3) 2) + place a tc egress filter on eth1

Which mostly makes sense to me although I am a little confused about
why 1) needs a filter on dummy0 (a filter on eth1 has no effect)
but 3) needs a filter on eth1 (a filter on dummy0 has no effect,
even if the skb is sent to dummy0 last.

I also had some limited success using CPU cgroups, though obviously
that targets CPU usage and thus the effect on throughput is fairly course.
In short, its a useful technique but not one that bares further
discussion here.

