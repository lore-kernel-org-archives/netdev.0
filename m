From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 9 Feb 2011 03:55:06 +0200
Message-ID: <20110209015506.GA13289@redhat.com>
References: <20110127.130240.104065182.davem@davemloft.net>
 <201102091107.20270.rusty@rustcorp.com.au>
 <20110209005345.GA12055@redhat.com>
 <201102091209.36546.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	Shirley Ma <mashirle@us.ibm.com>, netdev@vger.kernel.org,
	steved@us.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201102091209.36546.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 09, 2011 at 12:09:35PM +1030, Rusty Russell wrote:
> On Wed, 9 Feb 2011 11:23:45 am Michael S. Tsirkin wrote:
> > On Wed, Feb 09, 2011 at 11:07:20AM +1030, Rusty Russell wrote:
> > > On Wed, 2 Feb 2011 03:12:22 pm Michael S. Tsirkin wrote:
> > > > On Wed, Feb 02, 2011 at 10:09:18AM +0530, Krishna Kumar2 wrote:
> > > > > > "Michael S. Tsirkin" <mst@redhat.com> 02/02/2011 03:11 AM
> > > > > >
> > > > > > On Tue, Feb 01, 2011 at 01:28:45PM -0800, Shirley Ma wrote:
> > > > > > > On Tue, 2011-02-01 at 23:21 +0200, Michael S. Tsirkin wrote:
> > > > > > > > Confused. We compare capacity to skb frags, no?
> > > > > > > > That's sg I think ...
> > > > > > >
> > > > > > > Current guest kernel use indirect buffers, num_free returns how many
> > > > > > > available descriptors not skb frags. So it's wrong here.
> > > > > > >
> > > > > > > Shirley
> > > > > >
> > > > > > I see. Good point. In other words when we complete the buffer
> > > > > > it was indirect, but when we add a new one we
> > > > > > can not allocate indirect so we consume.
> > > > > > And then we start the queue and add will fail.
> > > > > > I guess we need some kind of API to figure out
> > > > > > whether the buf we complete was indirect?
> > > 
> > > I've finally read this thread... I think we need to get more serious
> > > with our stats gathering to diagnose these kind of performance issues.
> > > 
> > > This is a start; it should tell us what is actually happening to the
> > > virtio ring(s) without significant performance impact...
> > > 
> > > Subject: virtio: CONFIG_VIRTIO_STATS
> > > 
> > > For performance problems we'd like to know exactly what the ring looks
> > > like.  This patch adds stats indexed by how-full-ring-is; we could extend
> > > it to also record them by how-used-ring-is if we need.
> > > 
> > > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> > 
> > Not sure whether the intent is to merge this. If yes -
> > would it make sense to use tracing for this instead?
> > That's what kvm does.
> 
> Intent wasn't; I've not used tracepoints before, but maybe we should
> consider a longer-term monitoring solution?
> 
> Patch welcome!
> 
> Cheers,
> Rusty.

Sure, I'll look into this.

-- 
MST
