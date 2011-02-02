From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 23:14:51 -0800
Message-ID: <1296630891.26937.870.camel@localhost.localdomain>
References: <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <20110202062950.GD3818@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110202062950.GD3818@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-02 at 08:29 +0200, Michael S. Tsirkin wrote:
> On Tue, Feb 01, 2011 at 10:19:09PM -0800, Shirley Ma wrote:
> > On Tue, 2011-02-01 at 22:05 -0800, Shirley Ma wrote:
> > > 
> > > The way I am changing is only when netif queue has stopped, then
> we
> > > start to count num_free descriptors to send the signal to wake
> netif
> > > queue. 
> > 
> > I forgot to mention, the code change I am making is in guest kernel,
> in
> > xmit call back only wake up the queue when it's stopped && num_free
> >=
> > 1/2 *vq->num, I add a new API in virtio_ring.
> 
> Interesting. Yes, I agree an API extension would be helpful. However,
> wouldn't just the signaling reduction be enough, without guest
> changes?

w/i guest change, I played around the parameters,for example: I could
get 3.7Gb/s with 42% CPU BW increasing from 2.5Gb/s for 1K message size,
w/i dropping packet, I was able to get up to 6.2Gb/s with similar CPU
usage.

> > However vhost signaling reduction is needed as well. The patch I
> > submitted a while ago showed both CPUs and BW improvement.
> > 
> > Thanks
> > Shirley
> 
> Which patch was that? 

The patch was called "vhost: TX used buffer guest signal accumulation".
You suggested to split add_used_bufs and signal. I am still thinking
what's the best approach to cooperate guest (virtio_kick) and
vhost(handle_tx), vhost(signaling) and guest (xmit callback) to reduce
the overheads, so I haven't submit the new patch yet.

Thanks
Shirley

