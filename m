From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Sun, 14 Jun 2009 16:45:28 +1000
Message-ID: <20090614064528.GA29130@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906031247.05591.rusty@rustcorp.com.au> <20090608052247.GA19826@gondor.apana.org.au> <200906132200.38034.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49344 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751501AbZFNGpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 02:45:30 -0400
Content-Disposition: inline
In-Reply-To: <200906132200.38034.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 13, 2009 at 10:00:37PM +0930, Rusty Russell wrote:
> 
> But re your comment that the 67 drivers using TX_BUSY are doing it because of 
> driver bugs, that's hard to believe.  It either hardly ever happens (in which 
> case just drop the packet), or it happens (in which case we should handle it 
> correctly).

Most of them just do this:

start_xmit:

if (unlikely(queue is full)) {
	/* This should never happen. */
	return TX_BUSY;
}

transmit

if (queue is full)
	stop queue

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
