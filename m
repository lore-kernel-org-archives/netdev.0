From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Wed, 27 May 2015 10:01:29 +0800
Message-ID: <20150527020129.GA20792@gondor.apana.org.au>
References: <20150527000342.GA16379@gondor.apana.org.au>
 <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150527013840.GA20585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60526 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbE0CBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 22:01:33 -0400
Content-Disposition: inline
In-Reply-To: <20150527013840.GA20585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 09:38:40AM +0800, Herbert Xu wrote:
> 
> Not really.  They're not identical.  For example, before your
> patch a packet greater than MSS with TSO disabled would call
> tcp_nagle_test, with your patch it will call tcp_tso_should_defer
> instead.
> 
> Maybe this is OK but it is far from obvious.

Funny enough it was you who originally introduced this change
in behaviour:

commit 8f26fb1c1ed81c33f5d87c5936f4d9d1b4118918
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 15 12:24:54 2013 -0700

    tcp: remove the sk_can_gso() check from tcp_set_skb_tso_segs()

Now you're trying to do it again :)

The problem is back at the very beginning, tso_segs > 1 was the
same as TSO enabled.  So we either need to restore this identity
or find a new way of indiciating that TSO is enabled.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
