From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tg3: Fix tx race condition
Date: Tue, 8 Aug 2006 12:51:18 +1000
Message-ID: <20060808025117.GA13077@gondor.apana.org.au>
References: <1155005186.5328.13.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15626 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751213AbWHHCv2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 22:51:28 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1155005186.5328.13.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 07:46:26PM -0700, Michael Chan wrote:
> Fix a subtle race condition between tg3_start_xmit() and tg3_tx()
> discovered by Herbert Xu <herbert@gondor.apana.org.au>:

Thanks for the patch Michael.
 
> 2. Eliminate the private tx_lock altogether and rely solely on
> netif_tx_lock.  This eliminates one spinlock in tg3_start_xmit()
> when the ring is full.

Why not get rid of the lock altogether? By making sure memory
barriers are present on the stop/wake paths the locks are not
needed anymore.

> 4. Make tx_cons and tx_prod volatile to guarantee that
> tg3_start_xmit() and tg3_tx() will see the latest ring indices.

Such uses of volatile are bad inside the kernel because they
don't actually provide hardware memory barriers and their effect
on the compiler are given by constructs such as mb() anyway.

So we should simply add memory barriers where needed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
