From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 06 Feb 2009 01:05:59 -0800 (PST)
Message-ID: <20090206.010559.157790037.davem@davemloft.net>
References: <20090205234318.GA1929@gondor.apana.org.au>
	<20090206.005034.193709323.davem@davemloft.net>
	<20090206085406.GA6540@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbZBFJGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:06:03 -0500
In-Reply-To: <20090206085406.GA6540@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 6 Feb 2009 19:54:06 +1100

> This should eliminate the backtrace as reported, but it'll just
> show up somewhere else.  In particular, the control message (see
> sys_sendmsg) itself is copied to kernel memory via kmalloc and
> it's limited to INT_MAX :)

Can you be more specific, do you mean this is happening
via datagram_send_ctl()?

If we limit how big these txoption blobs can be, at all
sites where we parse instances the user gives us, I can't
see any such problems.
