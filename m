From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] tcp: correct memory barrier usage in
 tcp_check_space()
Date: Sat, 4 Feb 2017 23:57:25 +0800
Message-ID: <20170204155725.GA6244@gondor.apana.org.au>
References: <20170204095954.GA5916@gondor.apana.org.au>
 <1486221577.21871.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>, davem@davemloft.net,
        netdev@vger.kernel.org, oleg@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40961 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751237AbdBDP5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 10:57:49 -0500
Content-Disposition: inline
In-Reply-To: <1486221577.21871.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 07:19:37AM -0800, Eric Dumazet wrote:
>
> > The comment says that it's pairing with an mb in tcp_poll, but
> > tcp_poll doesn't touch QUEUE_SHRUNK at all.  So what exactly is
> > this barrier for?
> 
> Do not focus on QUEUE_SHRUNK flag, which is locally used by this thread
> only.
> 
> The confusion comes because 3c7151275c0c9a80c3375f9874b1c7129a105eea
> thought it could avoid the cost of smp_mb() by abusing the fact that
> sock_reset_flag(sk, SOCK_QUEUE_SHRUNK) was doing an atomic,
> but it was not.

Thanks for the explanation.  I see what it's protecting now.  And
this could indeed be responsible for the race that Oleg reported.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
