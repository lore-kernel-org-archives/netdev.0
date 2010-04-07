From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 15682] New: XFRM is not updating RTAX_ADVMSS
	metric
Date: Wed, 7 Apr 2010 21:54:46 +0800
Message-ID: <20100407135446.GA13394@gondor.apana.org.au>
References: <bug-15682-10286@https.bugzilla.kernel.org/> <20100405125055.cdc1e279.akpm@linux-foundation.org> <1270561240.7198.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, eduardo.panisset@gmail.com,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59685 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753355Ab0DGNzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:55:09 -0400
Content-Disposition: inline
In-Reply-To: <1270561240.7198.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 06, 2010 at 09:40:40AM -0400, jamal wrote:
> 
> Herbert would give better answers. I dont think what Eduardo is 
> doing is correct. You cant just start factoring in tcp headers
> at the xfrm level - and besides, the mtu calculation
> already takes care tunnel headers - so tcp should be able to 
> compute correct MSS. 

I think Eduardo is basically right.

Unfortunately, we've kind of stuffed up in how we handle ADVMSS.
In particular, we don't update it at all when we get a normal
non-IPsec PTMU message.

As a result, if we now start updating it it may actually break
existing users.

We do provide a locked bit for the user to use, however, because
the fact that we have never updated ADVMSS on the fly before,
people out there may not be aware of the locked bit.

Dave, what do you think about us starting to update ADVMSS on
the fly, just like the MTU?

The only risk is that existing users who are forcing ADVMSS to
a value higher than what it would otherwise be would now get a
lower value, if they're not using the "lock" keyword.

This shouldn't be fatal as it would only result in smaller packets
which should still work, and they can always start using the
"lock" keyword to get back the old behaviour.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
