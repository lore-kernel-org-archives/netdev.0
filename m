From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 14 Oct 2010 10:17:23 +0200
Message-ID: <20101014081723.GC11095@redhat.com>
References: <cover.1286372004.git.mst@redhat.com>
 <OF6C412DBC.EA03FC24-ON652577B9.00228DCA-652577B9.0028232D@in.ibm.com>
 <20101012170907.GA30613@redhat.com>
 <OFA7630B83.BFDFF71D-ON652577BC.0026D199-652577BC.002B9158@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OFA7630B83.BFDFF71D-ON652577BC.0026D199-652577BC.002B9158@in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 14, 2010 at 01:28:58PM +0530, Krishna Kumar2 wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 10/12/2010 10:39:07 PM:
> 
> > > Sorry for the delay, I was sick last couple of days. The results
> > > with your patch are (%'s over original code):
> > >
> > > Code               BW%       CPU%       RemoteCPU
> > > MQ     (#txq=16)   31.4%     38.42%     6.41%
> > > MQ+MST (#txq=16)   28.3%     18.9%      -10.77%
> > >
> > > The patch helps CPU utilization but didn't help single stream
> > > drop.
> > >
> > > Thanks,
> >
> > What other shared TX/RX locks are there?  In your setup, is the same
> > macvtap socket structure used for RX and TX?  If yes this will create
> > cacheline bounces as sk_wmem_alloc/sk_rmem_alloc share a cache line,
> > there might also be contention on the lock in sk_sleep waitqueue.
> > Anything else?
> 
> The patch is not introducing any locking (both vhost and virtio-net).
> The single stream drop is due to different vhost threads handling the
> RX/TX traffic.
> 
> I added a heuristic (fuzzy) to determine if more than one flow
> is being used on the device, and if not, use vhost[0] for both
> tx and rx (vhost_poll_queue figures this out before waking up
> the suitable vhost thread).  Testing shows that single stream
> performance is as good as the original code.

...

> This approach works nicely for both single and multiple stream.
> Does this look good?
> 
> Thanks,
> 
> - KK

Yes, but I guess it depends on the heuristic :) What's the logic?

-- 
MST
