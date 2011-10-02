From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Sun, 2 Oct 2011 11:11:38 +0200
Message-ID: <20111002091137.GB29706@redhat.com>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
 <20110819152335.GA19489@redhat.com>
 <1313771587.12243.16.camel@lappy>
 <20110820200043.GB5276@redhat.com>
 <871uvdryq2.fsf@rustcorp.com.au>
 <20110919060150.GB1569@redhat.com>
 <874o09x97m.fsf@rustcorp.com.au>
 <1317234651.11915.6.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1317234651.11915.6.camel@lappy>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2011 at 09:30:51PM +0300, Sasha Levin wrote:
> On Mon, 2011-09-19 at 17:19 +0930, Rusty Russell wrote:
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
> What if we create a capability list but place it in the virtio-pci
> config space instead of the PCI space?

Pls note that virtio-pci config space is io so it is very constrained,
we do need to pack it densely.  If we want to add a lot of stuff there
we probably should move it to memory space. It's slower than io
on kvm, but most uses of it aren't on data path.

> It'll work fine with non-PCI users and would leave MSI-X as the only
> thing that changes offsets (and we could probably deprecate and remove
> it at some point in the future).
> 
> -- 
> 
> Sasha.
