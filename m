From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Sun, 15 Nov 2015 09:20:32 +0800
Message-ID: <20151115012032.GA21282@gondor.apana.org.au>
References: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58590 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbbKOBUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 20:20:36 -0500
Content-Disposition: inline
In-Reply-To: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Some functions access TCP sockets without holding a lock and
> might output non consistent data, depending on compiler and or
> architecture.
> 
> tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...

For the information gathering ones such as tcp_diag_get_info I'm
wondering whether we really need these memory barriers.  After all,
if it's truly lockless then surely the TCP socket state can change
again after you load the state the first time, in which case the
barrier becomes completely meaningless.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
