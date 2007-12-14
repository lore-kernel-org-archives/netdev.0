From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 16:30:37 +0800
Message-ID: <20071214083037.GA15602@gondor.apana.org.au>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org> <E1J35d6-00041l-00@gondolin.me.apana.org.au> <20071214002209.ac748206.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4505 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752089AbXLNIao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 03:30:44 -0500
Content-Disposition: inline
In-Reply-To: <20071214002209.ac748206.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 12:22:09AM -0800, Andrew Morton wrote:
>
> I don't see how it could warn about that.  Nor should it - one might want
> to check that rtnl_lock is held inside preempt_disable() or spin_lock or
> whatever.
> 
> It might make sense to warn if ASSERT_RTNL is called in in_interrupt()
> contexts though.

Well the paths where ASSERT_RTNL is used should never be in an
atomic context.  In the past it has been quite useful in pointing
out bogus locking practices.

There is currently one path where it's known to warn because of
this and it (promiscuous mode) is on my todo list.

Oh and it only warns when you have mutex debugging enabled.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
