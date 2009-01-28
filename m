From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control commands
Date: Wed, 28 Jan 2009 23:35:13 +1030
Message-ID: <200901282335.13739.rusty@rustcorp.com.au>
References: <20090116211312.22836.34331.stgit@debian.lart> <200901271352.57887.rusty@rustcorp.com.au> <1233028806.7148.63.camel@2710p.home>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1233028806.7148.63.camel@2710p.home>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 January 2009 14:30:06 Alex Williamson wrote:
> Hi Rusty,
> 
> On Tue, 2009-01-27 at 13:52 +1030, Rusty Russell wrote:
> > On Saturday 17 January 2009 07:43:23 Alex Williamson wrote:
> > > + return status ? -EFAULT : 0;
> > 
> > This is wrong. Currently this can't happen, right? But you put it in
> > so someone in future may want some kind of return from the commands.
> > In which case, they'll want to see the value.
> > 
> > If we're sure they never want to see the value, then we don't need to
> > be synchronous at all: just spin if add_buf() fails.
> 
> In my qemu series of patches it can happen if the command isn't properly
> defined

ie. guest bug.

> , something bad happens

???  You're going to tell me to read the code, aren't you? :)

> , or the command is unrecognized.

If we go for feature bits, this is also a guest bug.  And I think we should, since that's what feature bits are for.

> As I
> was hashing this out, I first had more errnos, but I wasn't sure how
> extensively to fill out the error returns, and eventually defaulted to
> ok/fail.  Should I expand on these some?  Suggestions for a reasonable
> small yet complete set?  Should we use Linux errno values and let other
> OS virtio-net implementations create a switch table?

Not error codes.  In future we may have a command where return codes are meaningful, but I'm pretty sure they'll be command specific so we don't know how to define them now anyway.  AFAICT that's the only real justification for defining this interface as sync.

So I think just defining 0 on success is fine.  Defining that to always happen to well-formed commands is even better :)

Thanks,
Rusty.
