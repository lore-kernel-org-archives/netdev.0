From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Sat, 13 Jun 2009 22:00:37 +0930
Message-ID: <200906132200.38034.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906031247.05591.rusty@rustcorp.com.au> <20090608052247.GA19826@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54098 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756117AbZFMMar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 08:30:47 -0400
In-Reply-To: <20090608052247.GA19826@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2009 02:52:47 pm Herbert Xu wrote:
> No you've misunderstood my complaint.  I'm not trying to get you
> to replace NETDEV_TX_BUSY by the equally abhorrent queue in the
> driver, I'm saying that you should stop the queue before you get
> a packet that overflows by looking at the amount of free queue
> space after transmitting each packet.
>
> For most drivers this is easy to do.  What's so different about
> virtio-net that makes this impossible?

If we assume the worst case; ie. that the next packet will use max frags, we 
get close (make add_buf take a "unsigned int *descs_left" arg).  Obviously, 
this is suboptimal use of the ring.  We can still get kmalloc failures w/ 
indirect descriptors, but dropping a packet then isn't a huge deal IMHO.

But re your comment that the 67 drivers using TX_BUSY are doing it because of 
driver bugs, that's hard to believe.  It either hardly ever happens (in which 
case just drop the packet), or it happens (in which case we should handle it 
correctly).

TX_BUSY makes me queasy:  you haven't convinced me it shouldn't be killed or 
fixed.

Did you look at my attempted fix?
Rusty.








