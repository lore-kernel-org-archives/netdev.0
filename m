From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Mon, 22 Jun 2009 15:34:17 +0800
Message-ID: <20090622073417.GA21698@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au> <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51318 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751002AbZFVHe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 03:34:27 -0400
Content-Disposition: inline
In-Reply-To: <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2009 at 11:16:03AM +0530, Krishna Kumar2 wrote:
>
> I was curious about "queueing it in the driver" part: why is this bad? Do
> you
> anticipate any performance problems, or does it break QoS, or something
> else I
> have missed?

Queueing it in the driver is bad because it is no different than
queueing it at the upper layer, which is what will happen when
you return TX_BUSY.

Because we've ripped out the qdisc requeueing logic (which is
horribly complex and only existed because of TX_BUSY), it means
that higher priority packets cannot preempt a packet that is queued
in this way.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
