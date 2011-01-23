From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Sun, 23 Jan 2011 23:53:16 +1000
Message-ID: <20110123135316.GB2105@verge.net.au>
References: <20110114065415.GA30300@redhat.com>
 <20110116223728.GA6279@verge.net.au>
 <20110117102655.GH23479@redhat.com>
 <4D35ECE2.4040901@hp.com>
 <20110120083727.GA1807@verge.net.au>
 <20110121095929.GE26070@redhat.com>
 <20110121231149.GI2195@verge.net.au>
 <20110122215742.GC5617@redhat.com>
 <20110123063849.GB2673@verge.net.au>
 <20110123103902.GA28585@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Jesse Gross <jesse@nicira.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43352 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab1AWNxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 08:53:18 -0500
Content-Disposition: inline
In-Reply-To: <20110123103902.GA28585@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 23, 2011 at 12:39:02PM +0200, Michael S. Tsirkin wrote:
> On Sun, Jan 23, 2011 at 05:38:49PM +1100, Simon Horman wrote:
> > On Sat, Jan 22, 2011 at 11:57:42PM +0200, Michael S. Tsirkin wrote:
> > > On Sat, Jan 22, 2011 at 10:11:52AM +1100, Simon Horman wrote:
> > > > On Fri, Jan 21, 2011 at 11:59:30AM +0200, Michael S. Tsirkin wrote:

[snip]

> > > > > Hmm, what is this supposed to measure?  Basically each time you run an
> > > > > un-paced UDP_STREAM you get some random load on the network.
> > > > > You can't tell what it was exactly, only that it was between
> > > > > the send and receive throughput.
> > > > 
> > > > Rick mentioned in another email that I messed up my test parameters a bit,
> > > > so I will re-run the tests, incorporating his suggestions.
> > > > 
> > > > What I was attempting to measure was the effect of an unpaced UDP_STREAM
> > > > on the latency of more moderated traffic. Because I am interested in
> > > > what effect an abusive guest has on other guests and how that my be
> > > > mitigated.
> > > > 
> > > > Could you suggest some tests that you feel are more appropriate?
> > > 
> > > Yes. To refraze my concern in these terms, besides the malicious guest
> > > you have another software in host (netperf) that interferes with
> > > the traffic, and it cooperates with the malicious guest.
> > > Right?
> > 
> > Yes, that is the scenario in this test.
> 
> Yes but I think that you want to put some controlled load on host.
> Let's assume that we impove the speed somehow and now you can push more
> bytes per second without loss.  Result might be a regression in your
> test because you let the guest push "as much as it can" and suddenly it
> can push more data through.  OTOH with packet loss the load on host is
> anywhere in between send and receive throughput: there's no easy way to
> measure it from netperf: the earlier some buffers overrun, the earlier
> the packets get dropped and the less the load on host.
> 
> This is why I say that to get a specific
> load on host you want to limit the sender
> to a specific BW and then either
> - make sure packet loss % is close to 0.
> - make sure packet loss % is close to 100%.

Thanks, and sorry for being a bit slow.  I now see what you have
been getting at with regards to limiting the tests.
I will see about getting some numbers based on your suggestions.

