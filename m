From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] xfrm_state locking problem in xfrm_input.c
Date: Tue, 12 May 2009 13:48:13 +1000
Message-ID: <20090512034813.GA25841@gondor.apana.org.au>
References: <20090511184739.6e497f29@penta.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Yury Polyanskiy <ypolyans@Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38829 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758798AbZELDsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 23:48:19 -0400
Content-Disposition: inline
In-Reply-To: <20090511184739.6e497f29@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2009 at 06:47:39PM -0400, Yury Polyanskiy wrote:
> xfrm_input() code uses spin_lock() where it must be using
> spin_lock_bh() instead. The corresponding code in xfrm_output.c
> correctly uses spin_lock_bh(). 
> 
> Note that if the locally generated packet is sent to a local ip,
> dev_queue_xmit() calls loopback_xmit() and the xfrm_input() will be
> called with softirqs enabled.

dev_queue_xmit always disables BH before calling the device xmit
function.  So how can this happen?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
