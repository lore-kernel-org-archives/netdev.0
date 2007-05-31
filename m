From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Fri, 1 Jun 2007 07:49:47 +1000
Message-ID: <20070531214947.GA9428@gondor.apana.org.au>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <465E0149.6030307@intel.com> <20070531005147.GA30628@gondor.apana.org.au> <465E5442.7010503@intel.com> <20070531050616.GA32391@gondor.apana.org.au> <465EE1A7.6050901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Chapman <doug.chapman@hp.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2013 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751148AbXEaVtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 17:49:52 -0400
Content-Disposition: inline
In-Reply-To: <465EE1A7.6050901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 31, 2007 at 07:54:31AM -0700, Kok, Auke wrote:
> 
> so how about calling netif_poll_disable() before we register the net_device?

Yes that should work.  Let's move the other two netif_ calls while we're
at it.
 
> well no, if we make the watchdog (this is something I've already 
> implemented locally and -mm has it for instance) run as delayed work we can 
> just schedule a watchdog run instead of firing an interrupt.

OK.  The only thing I'm worried about is if we're uncovering some
underlying problem with the platform with respect to memory barriers
then we should get to the bottom of it first before making this problem
disappear.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
