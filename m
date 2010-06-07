From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: indicate oom when addbuf returns failure
Date: Mon, 7 Jun 2010 11:54:36 +0930
Message-ID: <201006071154.36948.rusty@rustcorp.com.au>
References: <201006041028.56798.rusty@rustcorp.com.au> <20100606201258.GA21196@redhat.com> <20100606222441.GA5992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, stable@kernel.org,
	Bruce Rogers <brogers@novell.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Shirley Ma <mashirle@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50245 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab0FGCYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jun 2010 22:24:38 -0400
In-Reply-To: <20100606222441.GA5992@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 07:54:41 am Herbert Xu wrote:
> On Sun, Jun 06, 2010 at 11:13:00PM +0300, Michael S. Tsirkin wrote:
> >
> > Actually this code looks strange:
> > Note that add_buf inicates out of memory
> > condition with a positive return value, and ring full
> > (which is not an error!) with -ENOSPC.
> 
> Indeed, this ultimately came from
> 
> commit 9ab86bbcf8be755256f0a5e994e0b38af6b4d399
> Author: Shirley Ma <mashirle@us.ibm.com>
> Date:   Fri Jan 29 03:20:04 2010 +0000
> 
>     virtio_net: Defer skb allocation in receive path Date: Wed, 13 Jan 2010 12:53:38 -0800
> 
> (Greg, please don't apply this even though I've just given you
> the upstream commit ID that you were asking for :)
> 
> where it confuses a memory allocation error with an add_buf failure.
> 
> > Possibly the right thing to do is to
> > 1. handle ENOMEM specially
> > 2. fix add_buf to return ENOMEM on error
> 
> I think we should make it so that only a memory allocation error
> is returned as before.  There is no need for returning the add_buf
> error unless add_buf is now doing an allocation itself that needs
> to be retried.

With indirect bufs, this is indeed the case.  The code works except
for the bigpackets !mergable case, but should be clarified anyway.

See my other mail...

Thanks,
Rusty.
