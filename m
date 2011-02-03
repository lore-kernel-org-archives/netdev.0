From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 02 Feb 2011 22:09:14 -0800
Message-ID: <1296713354.25430.143.camel@localhost.localdomain>
References: <20110202154706.GA12738@redhat.com>
	 <1296666635.25430.35.camel@localhost.localdomain>
	 <20110202173213.GA13907@redhat.com>
	 <1296670311.25430.49.camel@localhost.localdomain>
	 <20110202182720.GB14257@redhat.com>
	 <1296674975.25430.59.camel@localhost.localdomain>
	 <20110202201731.GB15150@redhat.com>
	 <1296680585.25430.98.camel@localhost.localdomain>
	 <20110202212047.GD15150@redhat.com>
	 <1296682893.25430.112.camel@localhost.localdomain>
	 <20110203055926.GB22230@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110203055926.GB22230@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-02-03 at 07:59 +0200, Michael S. Tsirkin wrote:
> > Let's look at the sequence here:
> > 
> > guest start_xmit()
> >       xmit_skb()
> >       if ring is full,
> >               enable_cb()
> > 
> > guest skb_xmit_done()
> >       disable_cb,
> >         printk free_old_xmit_skbs <-- it was between more than 1/2
> to
> > full ring size
> >       printk vq->num_free 
> > 
> > vhost handle_tx()
> >       if (guest interrupt is enabled)
> >               signal guest to free xmit buffers
> > 
> > So between guest queue full/stopped queue/enable call back to guest
> > receives the callback from host to free_old_xmit_skbs, there were
> about
> > 1/2 to full ring size descriptors available. I thought there were
> only a
> > few. (I disabled your vhost patch for this test.)
> 
> 
> The expected number is vq->num - max skb frags - 2. 

It was various (up to the ring size 256). This is using indirection
buffers, it returned how many freed descriptors, not number of buffers.

Why do you think it is vq->num - max skb frags - 2 here?

Shirley

