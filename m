From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 18:38:09 +0800
Message-ID: <20080328103809.GB23039@gondor.apana.org.au>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38932 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750774AbYC1KiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 06:38:17 -0400
Content-Disposition: inline
In-Reply-To: <47EC50BA.6080908@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 06:58:18PM -0700, Matheos Worku wrote:
>
> In general, while the TX serialization  improves performance in terms to 
> lock contention, wouldn't it reduce throughput since only one guy is 
> doing the actual TX at any given time.  Wondering if it would be 
> worthwhile to have an  enable/disable option specially for multi queue TX.

Unless you have a truly lockless driver where two CPUs can transmit
at the same time then regardless of what we do only one CPU can
transmit at a time.

Given that premise, we might as well let one CPU transmit as much
as possible since moving to another CPU after each packet is going
to bounce a lot more than just the spin lock and that is going to
be expensive.

Of course getting stuck in that loop forever when there is other
work to be done (such as running the watchdog :) is bad.  But
hopefully that's what this patch will fix.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
