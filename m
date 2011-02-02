From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 11:29:35 -0800
Message-ID: <1296674975.25430.59.camel@localhost.localdomain>
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
	 <20110202182720.GB14257@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57054 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab1BBT3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 14:29:43 -0500
In-Reply-To: <20110202182720.GB14257@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-02 at 20:27 +0200, Michael S. Tsirkin wrote:
> On Wed, Feb 02, 2011 at 10:11:51AM -0800, Shirley Ma wrote:
> > On Wed, 2011-02-02 at 19:32 +0200, Michael S. Tsirkin wrote:
> > > OK, but this should have no effect with a vhost patch
> > > which should ensure that we don't get an interrupt
> > > until the queue is at least half empty.
> > > Right?
> > 
> > There should be some coordination between guest and vhost.
> 
> What kind of coordination? With a patched vhost, and a full ring.
> you should get an interrupt per 100 packets.
> Is this what you see? And if yes, isn't the guest patch
> doing nothing then?

vhost_signal won't be able send any TX interrupts to guest when guest TX
interrupt is disabled. Guest TX interrupt is only enabled when running
out of descriptors.

> > We shouldn't
> > count the TX packets when netif queue is enabled since next guest TX
> > xmit will free any used buffers in vhost. We need to be careful here
> in
> > case we miss the interrupts when netif queue has stopped.
> > 
> > However we can't change old guest so we can test the patches
> separately
> > for guest only, vhost only, and the combination.
> > 
> > > > > 
> > > > > Yes, it seems unrelated to tx interrupts. 
> > > > 
> > > > The issue is more likely related to latency.
> > > 
> > > Could be. Why do you think so?
> > 
> > Since I played with latency hack, I can see performance difference
> for
> > different latency.
> 
> Which hack was that? 

I tried to accumulate multiple guest to host notifications for TX xmits,
it did help multiple streams TCP_RR results; I also forced vhost
handle_tx to handle more packets; both hack seemed help.

Thanks
Shirley

