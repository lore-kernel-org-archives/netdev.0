From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: net: allow to propagate errors through
	->ndo_hard_start_xmit()
Date: Mon, 9 Nov 2009 14:50:00 -0500
Message-ID: <20091109195000.GA10325@gondor.apana.org.au>
References: <4AF87070.6020007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44849 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752173AbZKITt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 14:49:58 -0500
Content-Disposition: inline
In-Reply-To: <4AF87070.6020007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2009 at 08:41:36PM +0100, Patrick McHardy wrote:
> 
> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
>   skbs is optimal. When the driver returns an error, it is assumed
>   the current segment has been freed. The patch then frees the
>   entire GSO skb, including all remaining segments. Alternatively
>   it could try to transmit the remaining segments later.

Well driver errors (not queueing errors) should never happen.
And if they do then they're likely to persist.  So freeing the
rest should be sufficient, unless of course if doing it some
other way is simpler :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
