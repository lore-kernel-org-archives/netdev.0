From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix data corruption with OOM
Date: Mon, 26 Oct 2009 21:34:17 +0200
Message-ID: <20091026193417.GA26552@redhat.com>
References: <20091025170340.GA22099@redhat.com> <200910261211.52148.rusty@rustcorp.com.au> <20091026184243.GA26473@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091026184243.GA26473@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 26, 2009 at 08:42:43PM +0200, Michael S. Tsirkin wrote:
> On Mon, Oct 26, 2009 at 12:11:51PM +1030, Rusty Russell wrote:
> > On Mon, 26 Oct 2009 03:33:40 am Michael S. Tsirkin wrote:
> > > virtio net used to unlink skbs from send queues on error,
> > > but ever since 48925e372f04f5e35fec6269127c62b2c71ab794
> > > we do not do this. This causes guest data corruption and crashes
> > > with vhost since net core can requeue the skb or free it without
> > > it being taken off the list.
> > > 
> > > This patch fixes this by queueing the skb after successfull
> > > transmit.
> > 
> > I originally thought that this was racy: as soon as we do add_buf, we need to
> > make sure we're ready for the callback (for virtio_pci, it's ->kick, but we
> > shouldn't rely on that).
> 
> Modified the guest slightly, and I am getting crashes again.
> I didn't have time to debug this, but based on previous experience,
> I reverted 48925e372f04f5e35fec6269127c62b2c71ab794,
> and the crash went away.
> Rusty, what do you say we just revert 48925e372f04f5e35fec6269127c62b2c71ab794
> for now?

Hmm. Can't reproduce the crash anymore.
There is a small chance that the problem was my error,
so I guess I should try to reproduce and debug this,
after all.
