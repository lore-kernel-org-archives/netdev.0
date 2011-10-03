From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Tue, 04 Oct 2011 10:21:10 +1030
Message-ID: <8762k5iqhd.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com> <20110819152335.GA19489@redhat.com> <1313771587.12243.16.camel@lappy> <20110820200043.GB5276@redhat.com> <871uvdryq2.fsf@rustcorp.com.au> <20110919060150.GB1569@redhat.com> <874o09x97m.fsf@rustcorp.com.au> <20111002090900.GA29706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, David Gibson <david@gibson.dropbear.id.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111002090900.GA29706@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Oct 2011 11:09:00 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Mon, Sep 19, 2011 at 05:19:49PM +0930, Rusty Russell wrote:
> > On Mon, 19 Sep 2011 09:01:50 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > On Mon, Sep 19, 2011 at 01:05:17PM +0930, Rusty Russell wrote:
> > > > On Sat, 20 Aug 2011 23:00:44 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > > > On Fri, Aug 19, 2011 at 07:33:07PM +0300, Sasha Levin wrote:
> > > > > > Maybe this is better solved by copying the way it was done in PCI itself
> > > > > > with capability linked list?
> > > > > 
> > > > > There are any number of ways to lay out the structure.  I went for what
> > > > > seemed a simplest one.  For MSI-X the train has left the station.  We
> > > > > can probably still tweak where the high 32 bit features
> > > > > for 64 bit features are.  No idea if it's worth it.
> > > > 
> > > > Sorry, this has been in the back of my mind.  I think it's a good idea;
> > > > can we use the capability linked list for pre-device specific stuff from
> > > > now on?
> > > > 
> > > > Thanks,
> > > > Rusty.
> > > 
> > > Do we even want capability bits then?
> > > We can give each capability an ack flag ...
> > 
> > We could have, and if I'd known PCI when I designed virtio I might have.
> > 
> > But it's not easy now to map structure offsets to that scheme, and we
> > can't really force such a change on the non-PCI users.  So I'd say we
> > should only do it for the non-device-specific options.  ie. we'll still
> > have the MSI-X case move the device-specific config, but we'll use a
> > linked list from now on, eg. for the next 32 features bits...
> > 
> > Thoughts?
> > Rusty.
> 
> So I thought about this some more. It probably makes sense to
> stop adding info in the io space, and start adding new stuff in
> memory space which is much less contrained.
> 
> As we need to keep compatibility, and also because memory access is
> much slower with kvm so we prefer io for datapath, we could have the
> first X bytes still mirrored in io space.
> 
> MSIX is there, and it's pointed to from config space,
> so we could just put our stuff at offset 0.
> 
> Or if we wanted a lot of flexibility, we could add pointers, in config
> space, to device specific and non device specific regions in memory
> space.
> 
> Makes sense?

I've cc'd David Gibson who has noted in the past that I/O space on PPC
is icky.

I think a linked list for future virtio-pci extensions makes sense (not
device-specific stuff, that's great as a simple structure).  I think
mirroring everything in mem space makes sense, too.

Thanks,
Rusty.
