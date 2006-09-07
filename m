From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: ipv6 lockdep
Date: Thu, 7 Sep 2006 10:21:25 +1000
Message-ID: <20060907002125.GA27917@gondor.apana.org.au>
References: <Pine.LNX.4.64.0609061059200.10137@acis.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:6927 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964858AbWIGAV5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 20:21:57 -0400
To: Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Matthew Galgoci <mgalgoci@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609061059200.10137@acis.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2006 at 03:06:12PM +0000, Matthew Galgoci wrote:
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.17-1.2614.fc6 #1
> ---------------------------------------------
> java/7112 is trying to acquire lock:
>  (slock-AF_INET6){-+..}, at: [<c05b34de>] sk_clone+0xd4/0x2d8
> but task is already holding lock:
>  (slock-AF_INET6){-+..}, at: [<e0ce94c9>] tcp_v6_rcv+0x327/0x736 [ipv6]
> other info that might help us debug this:
> 1 lock held by java/7112:
>  #0:  (slock-AF_INET6){-+..}, at: [<e0ce94c9>] tcp_v6_rcv+0x327/0x736 [ipv6]

This is a known problem with the validator.  The above is a legitimate
occurance during the construction of a child TCP socket (i.e., when it
is doing an accept(2) call).

Arjan, is there any progress on this issue?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
