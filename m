From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Wed, 3 Jun 2009 09:45:32 +1000
Message-ID: <20090602234532.GA5417@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <20090602090552.GA26611@gondor.apana.org.au> <200906022325.57961.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51974 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751036AbZFBXpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 19:45:33 -0400
Content-Disposition: inline
In-Reply-To: <200906022325.57961.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2009 at 11:25:57PM +0930, Rusty Russell wrote:
>
> Or, we could just "return NETDEV_TX_BUSY;".  I like that :)

No you should fix it so that you check the queue status after
transmitting a packet so we never get into this state in the
first place.  NETDEV_TX_BUSY is just passing the problem to
someone else, which is not nice at all.

For example, anyone running tcpdump will now see the packet
twice.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
