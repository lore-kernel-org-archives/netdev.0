From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 05 Nov 2008 03:42:24 -0800 (PST)
Message-ID: <20081105.034224.167388197.davem@davemloft.net>
References: <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
	<20081027170314.GA25148@ioremap.net>
	<20081027.113904.211811887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755288AbYKELmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 06:42:49 -0500
In-Reply-To: <20081027.113904.211811887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 27 Oct 2008 11:39:04 -0700 (PDT)

> One idea immediately occurs to me.  Since we're effectively limited
> to a 64K TSO frame, and the MSS is some value smaller than that, we
> can probably get away with a reciprocol divide.  Even using a 16-bit
> inverse value would suffice, so we wouldn't need to use u64's like
> some other pieces of code do.  A u32 would be enough.

I couldn't get anywhere with this idea.

The problem is that 16-bits provides not enough precision for accurate
divisions by multiplication.

For example, for a divisor of 1500 and a shift of 16 neither 43 nor 44
provides an accurate calculation.

So we'd need to use a u64 and a shift of 32, and on 32-bit cpus that
could be expensive, but perhaps not as expensive as the divide.


