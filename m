From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 2 Feb 2011 20:27:20 +0200
Message-ID: <20110202182720.GB14257@redhat.com>
References: <20110202044002.GB3818@redhat.com>
 <1296626748.26937.852.camel@localhost.localdomain>
 <1296627549.26937.856.camel@localhost.localdomain>
 <OFF5778D3C.84F46700-ON6525782B.00230A94-6525782B.00240890@in.ibm.com>
 <20110202104832.GA8505@redhat.com>
 <1296661185.25430.10.camel@localhost.localdomain>
 <20110202154706.GA12738@redhat.com>
 <1296666635.25430.35.camel@localhost.localdomain>
 <20110202173213.GA13907@redhat.com>
 <1296670311.25430.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754834Ab1BBS1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 13:27:48 -0500
Content-Disposition: inline
In-Reply-To: <1296670311.25430.49.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 02, 2011 at 10:11:51AM -0800, Shirley Ma wrote:
> On Wed, 2011-02-02 at 19:32 +0200, Michael S. Tsirkin wrote:
> > OK, but this should have no effect with a vhost patch
> > which should ensure that we don't get an interrupt
> > until the queue is at least half empty.
> > Right?
> 
> There should be some coordination between guest and vhost.

What kind of coordination? With a patched vhost, and a full ring.
you should get an interrupt per 100 packets.
Is this what you see? And if yes, isn't the guest patch
doing nothing then?

> We shouldn't
> count the TX packets when netif queue is enabled since next guest TX
> xmit will free any used buffers in vhost. We need to be careful here in
> case we miss the interrupts when netif queue has stopped.
> 
> However we can't change old guest so we can test the patches separately
> for guest only, vhost only, and the combination.
> 
> > > > 
> > > > Yes, it seems unrelated to tx interrupts. 
> > > 
> > > The issue is more likely related to latency.
> > 
> > Could be. Why do you think so?
> 
> Since I played with latency hack, I can see performance difference for
> different latency.

Which hack was that?

> > > Do you have anything in
> > > mind on how to reduce vhost latency?
> > > 
> > > Thanks
> > > Shirley
> > 
> > Hmm, bypassing the bridge might help a bit.
> > Are you using tap+bridge or macvtap? 
> 
> I am using tap+bridge for TCP_RR test, I think Steven tested macvtap
> before. He might have some data from his workload performance
> measurement.
> 
> Shirley
