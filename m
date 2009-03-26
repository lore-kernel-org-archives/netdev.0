From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TX time stamping
Date: Thu, 26 Mar 2009 22:48:35 +0800
Message-ID: <20090326144835.GA19592@gondor.apana.org.au>
References: <1236105081.4653.68.camel@pohly-MOBL> <20090319.140509.152824531.davem@davemloft.net> <20090320021050.GA7021@gondor.apana.org.au> <1237964924.26966.310.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759037AbZCZOsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 10:48:41 -0400
Content-Disposition: inline
In-Reply-To: <1237964924.26966.310.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 08:08:44AM +0100, Patrick Ohly wrote:
>
> I suggest to make it so that the sender gets the packet back once per
> interface, with different time stamps and information about the
> interface.

That could be awkward.  What if the second or subsequent instance
of the packet is held up indefinitely?

> > As to the problem of skb->sk, I don't think that's even needed
> > as we can simply use the skb shared area as the communication
> > medium.
> 
> Can you elaborate on that?

I was thinking of the sender keeping hold of the sent skb and
using its shared area to retrieve the time stamp(s).

> The drawback is the more costly socket lookup. For PTP this isn't an
> issue due to the low packet rate, so a very simple solution would be
> good enough. But for other use cases it might be problematic. I also
> have no idea how the locking for the socket lookup can be done safely.

Could you give the main usage scenarios for timestamps, including
what the user-space app does with the info?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
