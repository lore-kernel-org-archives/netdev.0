From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: indicate oom when addbuf returns failure
Date: Mon, 7 Jun 2010 11:47:21 +0930
Message-ID: <201006071147.22102.rusty@rustcorp.com.au>
References: <201006041028.56798.rusty@rustcorp.com.au> <20100606201258.GA21196@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, Bruce Rogers <brogers@novell.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40255 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755273Ab0FGCR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 22:17:27 -0400
In-Reply-To: <20100606201258.GA21196@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 05:43:00 am Michael S. Tsirkin wrote:
> On Fri, Jun 04, 2010 at 10:28:56AM +0930, Rusty Russell wrote:
> > This patch is a subset of an already upstream patch, but this portion
> > is useful in earlier releases.
> > 
> > Please consider for the 2.6.32 and 2.6.33 stable trees.
> > 
> > If the add_buf operation fails, indicate failure to the caller.
> > 
> > Signed-off-by: Bruce Rogers <brogers@novell.com>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Actually this code looks strange:
> Note that add_buf inicates out of memory
> condition with a positive return value, and ring full
> (which is not an error!) with -ENOSPC.
> 
> So it seems that this patch (and upstream code) will fill
> the ring and then end up setting oom = true and rescheduling the work
> forever.  And I suspect I actually saw this at some point
> on one of my systems: observed BW would drop
> with high CPU usage until reboot.
> Can't reproduce it now anymore ..

I thought that at first too, but it's subtler than that.

When the ring is exactly filled, err = 0.  With mergeable bufs and small
bufs that's the.  With big buffers, it's probably not, and the code will
indeed respond as if always out of memory, always trying to refill.

Our current code has the same error.  Probably a combination of noone using
big buffers, and noone noticing one timer every 1/2 second.

Want to fix that properly?  And comment it? :)

Thanks,
Rusty.
