From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Wed, 27 May 2015 09:38:41 +0800
Message-ID: <20150527013840.GA20585@gondor.apana.org.au>
References: <20150527000342.GA16379@gondor.apana.org.au>
 <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49574 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbbE0Biq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 21:38:46 -0400
Content-Disposition: inline
In-Reply-To: <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 05:36:34PM -0700, Eric Dumazet wrote:
> 
> tldr:  "TSO with max_segs==1"  <is the same than> "no TSO/GSO"

Not really.  They're not identical.  For example, before your
patch a packet greater than MSS with TSO disabled would call
tcp_nagle_test, with your patch it will call tcp_tso_should_defer
instead.

Maybe this is OK but it is far from obvious.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
