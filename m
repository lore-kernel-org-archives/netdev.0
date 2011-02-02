From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 2 Feb 2011 12:48:43 +0200
Message-ID: <20110202104843.GB8505@redhat.com>
References: <1296595955.26937.822.camel@localhost.localdomain>
 <20110201214211.GB31105@redhat.com>
 <1296597185.26937.829.camel@localhost.localdomain>
 <20110201215603.GA31348@redhat.com>
 <1296601197.26937.833.camel@localhost.localdomain>
 <20110202044002.GB3818@redhat.com>
 <1296626748.26937.852.camel@localhost.localdomain>
 <1296627549.26937.856.camel@localhost.localdomain>
 <20110202062950.GD3818@redhat.com>
 <1296630891.26937.870.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1296630891.26937.870.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2011 at 11:14:51PM -0800, Shirley Ma wrote:
> On Wed, 2011-02-02 at 08:29 +0200, Michael S. Tsirkin wrote:
> > On Tue, Feb 01, 2011 at 10:19:09PM -0800, Shirley Ma wrote:
> > > On Tue, 2011-02-01 at 22:05 -0800, Shirley Ma wrote:
> > > > 
> > > > The way I am changing is only when netif queue has stopped, then
> > we
> > > > start to count num_free descriptors to send the signal to wake
> > netif
> > > > queue. 
> > > 
> > > I forgot to mention, the code change I am making is in guest kernel,
> > in
> > > xmit call back only wake up the queue when it's stopped && num_free
> > >=
> > > 1/2 *vq->num, I add a new API in virtio_ring.
> > 
> > Interesting. Yes, I agree an API extension would be helpful. However,
> > wouldn't just the signaling reduction be enough, without guest
> > changes?
> 
> w/i guest change, I played around the parameters,for example: I could
> get 3.7Gb/s with 42% CPU BW increasing from 2.5Gb/s for 1K message size,
> w/i dropping packet, I was able to get up to 6.2Gb/s with similar CPU
> usage.

We need to consider them separately IMO.  What's the best we can get
without guest change?  And which parameters give it?
There will always be old guests, and as far as I can tell
it should work better from host.

> > > However vhost signaling reduction is needed as well. The patch I
> > > submitted a while ago showed both CPUs and BW improvement.
> > > 
> > > Thanks
> > > Shirley
> > 
> > Which patch was that? 
> 
> The patch was called "vhost: TX used buffer guest signal accumulation".
Yes, a somewhat similar idea.

> You suggested to split add_used_bufs and signal.
Exactly. And this is basically what this patch does.

> I am still thinking
> what's the best approach to cooperate guest (virtio_kick) and
> vhost(handle_tx), vhost(signaling) and guest (xmit callback) to reduce
> the overheads, so I haven't submit the new patch yet.
> 
> Thanks
> Shirley


-- 
MST
