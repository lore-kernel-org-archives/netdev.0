From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control commands
Date: Thu, 29 Jan 2009 12:05:10 +1030
Message-ID: <200901291205.11023.rusty@rustcorp.com.au>
References: <20090116211312.22836.34331.stgit@debian.lart> <200901282335.13739.rusty@rustcorp.com.au> <1233169341.7026.244.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>,
	Anthony Liguori <aliguori@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1233169341.7026.244.camel@lappy>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 January 2009 05:32:21 Alex Williamson wrote:
> On Wed, 2009-01-28 at 23:35 +1030, Rusty Russell wrote:
> > On Tuesday 27 January 2009 14:30:06 Alex Williamson wrote:
> > > On Tue, 2009-01-27 at 13:52 +1030, Rusty Russell wrote:
> > > > If we're sure they never want to see the value, then we don't need to
> > > > be synchronous at all: just spin if add_buf() fails.
...
> The only one of these that stands out is if the qemu_mallocz() for the
> MAC filter table fails for a size we think is reasonable.

Yes, that seems fair.  Of course it's quite probable that the malloc will "succeed" then we'll segv later on if we're really low on mem.

> > > , or the command is unrecognized.
> > 
> > If we go for feature bits, this is also a guest bug.  And I think we
> > should, since that's what feature bits are for.
> 
> One of the reasons I had avoided using a feature bit is that it's only a
> 32bit field, and we've already used up to bit 16 (though I'm not sure
> what to do about the sparse-ness of it).  The virtqueue interface I've
> designed supports up to 255 command classes, each with 255 commands.  We
> can't add a feature bit for every one, or even much of a subset.

We will need to figure out how to figure out how to expand the feature bits for virtio_pci anyway.  I think the plan is to use feature bit 31 to mean "look here for more feature bits".  Anthony would know more...

s390 and lguest didn't fall into this trap; we have infinite feature bits.

> I'd be
> happy to add a feature bit indicating the virtqueue command channel is
> supported

We probably should, for good measure.  If someone added another virtqueue for some other purpose in future and didn't want to support the command channel it would get icky.

If we have 255 features, the problem is that we have 255 features, not that it's a lot of bits :)

Thanks,
Rusty.
