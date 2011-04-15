From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] possible bug in inet->opt handling
Date: Sat, 16 Apr 2011 01:24:26 +0800
Message-ID: <20110415172426.GA5782@gondor.apana.org.au>
References: <1302881994.3613.34.camel@edumazet-laptop> <20110415171715.GA5648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35057 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab1DORYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 13:24:33 -0400
Content-Disposition: inline
In-Reply-To: <20110415171715.GA5648@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 01:17:15AM +0800, Herbert Xu wrote:
> On Fri, Apr 15, 2011 at 05:39:54PM +0200, Eric Dumazet wrote:
> >
> > My plan is to add RCU protection on inet->opt, unless someone has better
> > idea ?
> 
> inet->opt is rarely non-NULL.  So perhaps just throw some locks
> around the memcpy.

Ah I missed your other point about inet->opt going away.  The
other option would be to always kmalloc/memcpy in udp_sendmsg
and have ip_setup_cork simply steal the reference from ipc.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
