From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 15:29:43 +0200
Message-ID: <200708151529.46780.arnd@arndb.de>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <200708150001.58217.arnd@arndb.de> <20070814224354.GE8243@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:49785 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765163AbXHOOv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 10:51:59 -0400
In-Reply-To: <20070814224354.GE8243@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 15 August 2007, Paul E. McKenney wrote:

> ACCESS_ONCE() is indeed intended to be used when actually loading or
> storing the variable.  That said, I must admit that it is not clear to me
> why you would want to add an extra order() rather than ACCESS_ONCE()ing
> one or both of the adjacent accesses to that same variable.
> 
> So, what am I missing?

You're probably right, the only case I can construct is something like

	if (ACCESS_ONCE(x)) {
		...
		ACCESS_ONCE(x)++;
	}

which would be slightly less efficient than

	if (x)
		x++;
	order(x);

because in the first case, you need to do two ordered accesses
but only one in the second case. However, I can't think of a case
where this actually makes a noticable difference in real life.

	Arnd <><
