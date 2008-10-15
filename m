From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Wed, 15 Oct 2008 09:46:24 +0800
Message-ID: <20081015014624.GA3251@gondor.apana.org.au>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl> <E1KpkSl-00087W-GB@gondolin.me.apana.org.au> <20081014104621.3c2ce4d3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33874 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751840AbYJOBqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 21:46:36 -0400
Content-Disposition: inline
In-Reply-To: <20081014104621.3c2ce4d3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 10:46:21AM -0700, Stephen Hemminger wrote:
>
> There is no easy solution, I'll will have to go back rewrite this
> code, and will document the result. I expect the result will displease
> someone, but given the original code that is just going to happen.
> 
> Busted cases:
>                            correct           incorrect
> Original code: 127.2   =>  127.0.0.2         127.2.0.0
> inet_pton:     10.0    =>  10.0.0.0          fails invalid
> inet_aton:     10      =>  10.0.0.0          0.0.0.10
> 
> The problem was Alexey (or Jamal) invented their own abbreviation format
> and did not follow unix standard conventions.

How about just keeping Alexey's code? POSIX doesn't restrict
the IP address format command utilities should accept.  So to
me 127.2.0.0 is a perfectly acceptable interpretation of the
partial address 127.2.

This also has the benefit of not breaking any existing scripts
that already work.  The scripts which are broken will remain
broken which doesn't surprise anyone.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
