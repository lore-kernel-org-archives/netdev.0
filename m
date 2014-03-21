From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 08:13:03 +0800
Message-ID: <20140321001303.GB20397@gondor.apana.org.au>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49651 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964953AbaCUANL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:13:11 -0400
Content-Disposition: inline
In-Reply-To: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 11:49:01AM -0700, Eric Dumazet wrote:
> csum_replace2() uses about 29 cycles, while a plain ip_send_check() is
> way faster (16 cycles)
> 
> csum_partial() is not really meant for doing checksums over 8 bytes !
> 
> Any idea how to make the thing really fast as intended ?
> 
> I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> is insane...
> 
> Following patch might be the fastest thing ?

Your patch makes sense to me.  However does it actually help
your 1% in the GRO profile?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
