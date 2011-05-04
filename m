From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V4 4/8]vhost: vhost TX zero-copy support
Date: Wed, 4 May 2011 18:56:24 +0300
Message-ID: <20110504155624.GB15648@redhat.com>
References: <1304496684.20660.84.camel@localhost.localdomain>
 <20110504095650.GA11592@redhat.com>
 <1304522284.7076.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304522284.7076.12.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2011 at 08:18:04AM -0700, Shirley Ma wrote:
> > > +void vhost_zerocopy_callback(struct sk_buff *skb)
> > > +{
> > > +     int idx = skb_shinfo(skb)->ubuf.desc;
> > > +     struct vhost_virtqueue *vq = skb_shinfo(skb)->ubuf.arg;
> > > +
> > > +     /* set len = 1 to mark this desc buffers done DMA */
> > > +     vq->heads[idx].len = 1;
> > > +}
> > 
> > So any kind of callback like that, that goes into the skb,
> > will be racy wrt module unloading because module can go away
> > after you mark dma done and before this function returns.
> > Solution is to have a core function that does the
> > final signalling (e.g. sock_wfree is in core).
> > Would be nice to fix, even though this race is
> > completely theoretical, I don't believe it will
> > trigger in practice.
> 
> I run lots of stress tests, and never hit this. 
> 
> But I can try to fix it.

Yes, it's a theoretical thing. Nice to have but not a must.
