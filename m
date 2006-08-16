From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 7009] New: possible recursive locking detected
Date: Wed, 16 Aug 2006 13:07:03 +1000
Message-ID: <E1GDBkF-0006NE-00@gondolin.me.apana.org.au>
References: <20060815095151.88d2e16c.akpm@osdl.org>
Cc: netdev@vger.kernel.org, arjan@linux.intel.com, mingo@elte.hu,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4101 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750865AbWHPDHK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 23:07:10 -0400
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20060815095151.88d2e16c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> ---------------------------------------------
> java/3069 is trying to acquire lock:
> (slock-AF_INET6){-+..}, at: [<ffffffff804aa9df>] sk_clone+0xcc/0x341
> 
> but task is already holding lock:
> (slock-AF_INET6){-+..}, at: [<ffffffff88169f10>] tcp_v6_rcv+0x2e9/0x799 [ipv6]
> 
> other info that might help us debug this:
> 1 lock held by java/3069:
> #0:  (slock-AF_INET6){-+..}, at: [<ffffffff88169f10>] tcp_v6_rcv+0x2e9/0x799 
> [ipv6]

This is a known defect in the lock validator where it complains about
the nested locking in the TCP accept path.  This is safe because the
second lock is on the newly created child TCP socket which does not
exist in any other context yet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
