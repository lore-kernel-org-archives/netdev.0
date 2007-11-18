From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Fix TCP header misalignment
Date: Sun, 18 Nov 2007 13:36:02 -0800 (PST)
Message-ID: <20071118.133602.193701128.davem@davemloft.net>
References: <20071118121530.GA27963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752148AbXKRVgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 16:36:06 -0500
In-Reply-To: <20071118121530.GA27963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Nov 2007 20:15:30 +0800

> [TCP]: Fix TCP header misalignment
> 
> Indeed my previous change to alloc_pskb has made it possible
> for the TCP header to be misaligned iff the MTU is not a multiple
> of 4 (and less than a page).  So I suspect the optimised IPsec
> MTU calculation is giving you just such an MTU :)
> 
> This patch fixes it by changing alloc_pskb to make sure that
> the size is at least 32-bit aligned.  This does not cause the
> problem fixed by the previous patch because max_header is always
> 32-bit aligned which means that in the SG/NOTSO case this will
> be a no-op.
> 
> I thought about putting this in the callers but all the current
> callers are from TCP.  If and when we get a non-TCP caller we
> can always create a TCP wrapper for this function and move the
> alignment over there.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'm getting this without IPSEC FWIW.  I believe it occurs when I talk
to sites with sub-1500 MTUs.

I'll test your patch and let you know how it goes, thanks.
