From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control
 commands
Date: Wed, 28 Jan 2009 12:02:21 -0700
Message-ID: <1233169341.7026.244.camel@lappy>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <200901271352.57887.rusty@rustcorp.com.au>
	 <1233028806.7148.63.camel@2710p.home>
	 <200901282335.13739.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200901282335.13739.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-28 at 23:35 +1030, Rusty Russell wrote:
> On Tuesday 27 January 2009 14:30:06 Alex Williamson wrote:
> > Hi Rusty,
> > 
> > On Tue, 2009-01-27 at 13:52 +1030, Rusty Russell wrote:
> > > On Saturday 17 January 2009 07:43:23 Alex Williamson wrote:
> > > > + return status ? -EFAULT : 0;
> > > 
> > > This is wrong. Currently this can't happen, right? But you put it in
> > > so someone in future may want some kind of return from the commands.
> > > In which case, they'll want to see the value.
> >
> > > If we're sure they never want to see the value, then we don't need to
> > > be synchronous at all: just spin if add_buf() fails.
> > 
> > In my qemu series of patches it can happen if the command isn't properly
> > defined
> 
> ie. guest bug.
> 
> > , something bad happens
> 
> ???  You're going to tell me to read the code, aren't you? :)

The only one of these that stands out is if the qemu_mallocz() for the
MAC filter table fails for a size we think is reasonable.

> > , or the command is unrecognized.
> 
> If we go for feature bits, this is also a guest bug.  And I think we
> should, since that's what feature bits are for.

One of the reasons I had avoided using a feature bit is that it's only a
32bit field, and we've already used up to bit 16 (though I'm not sure
what to do about the sparse-ness of it).  The virtqueue interface I've
designed supports up to 255 command classes, each with 255 commands.  We
can't add a feature bit for every one, or even much of a subset.  I'd be
happy to add a feature bit indicating the virtqueue command channel is
supported, but beyond that, I think we need to fall back to enable or
initialization commands failing on various classes.  We could also
define that command 0 for each class as a probe if we want to make it
more explicit.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

