From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control
 commands
Date: Mon, 26 Jan 2009 21:00:06 -0700
Message-ID: <1233028806.7148.63.camel@2710p.home>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211323.22836.40477.stgit@debian.lart>
	 <200901271352.57887.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:2266 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbZA0EAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 23:00:13 -0500
In-Reply-To: <200901271352.57887.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Tue, 2009-01-27 at 13:52 +1030, Rusty Russell wrote:
> On Saturday 17 January 2009 07:43:23 Alex Williamson wrote:
> > + return status ? -EFAULT : 0;
> 
> This is wrong. Currently this can't happen, right? But you put it in
> so someone in future may want some kind of return from the commands.
> In which case, they'll want to see the value.
> 
> If we're sure they never want to see the value, then we don't need to
> be synchronous at all: just spin if add_buf() fails.

In my qemu series of patches it can happen if the command isn't properly
defined, something bad happens, or the command is unrecognized.  As I
was hashing this out, I first had more errnos, but I wasn't sure how
extensively to fill out the error returns, and eventually defaulted to
ok/fail.  Should I expand on these some?  Suggestions for a reasonable
small yet complete set?  Should we use Linux errno values and let other
OS virtio-net implementations create a switch table?

I would like to keep this interface synchronous, particularly I'm
wondering if there's anything we might want to do for ethtool like
statistics.  In that case, the backend might fill a buffer of data along
with returning a status code.  I could imagine other similar uses as
well.

> 
> > +struct virtio_net_ctrl_hdr {
> 
> > + __u8 class;
> 
> > + __u8 cmd;
> 
> > +};
> 
> This would need to be __attribute__((packed)). On ARM, that struct
> would be 4 bytes long.

Thanks, I'll fix that.

> > +
> 
> > +typedef __u8 virtio_net_ctrl_ack;
> 
> > +
> 
> > +#define VIRTIO_NET_OK 0
> 
> > +#define VIRTIO_NET_ERR 1
> 
> Hmm, we define it and don't use it. And we never expect it to actually
> error (did your qemu implementation ever actually return non-zero?).

Yup, good point.  These are mainly here to stay in sync with the qemu
backend, which does make use of them.  Should I remove them here, or
should we make a more worthwhile set of return values?  I have tried
manually returning non-zero status from qemu to verify it's reflected in
the response.  Thanks for the comments,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

