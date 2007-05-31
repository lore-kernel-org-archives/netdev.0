From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 10:51:47 +1000
Message-ID: <20070531005147.GA30628@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <465E0149.6030307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Chapman <doug.chapman@hp.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3953 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752522AbXEaAwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 20:52:03 -0400
Content-Disposition: inline
In-Reply-To: <465E0149.6030307@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 30, 2007 at 03:57:13PM -0700, Kok, Auke wrote:
> 
> Hmm, we're making a mess of it.

Indeed :)

> Herbert, wouldn't it just have been a lot easier to do just add a 
> netif_poll_disable in e1000_probe, so that any and all other poll 
> enable/disables are symmetric ? Something like this?

I wish if it were as simple as that.  As soon as register_netdev
returns somebody else can invoke e1000_open so disabling poll
here can be undesirable.  In fact the existing netif_stop_queue
and netif_carrier_off calls are also bad for the same reason.

I'll keep looking to see if there's some other problem that we
haven't uncovered yet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
