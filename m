From: David Miller <davem@davemloft.net>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Tue, 06 Mar 2007 16:05:57 -0800 (PST)
Message-ID: <20070306.160557.111204912.davem@davemloft.net>
References: <E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
	<20070306.160202.102574506.davem@davemloft.net>
	<20070307000419.GA13170@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030756AbXCGAGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:06:05 -0500
In-Reply-To: <20070307000419.GA13170@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 7 Mar 2007 11:04:19 +1100

> On Tue, Mar 06, 2007 at 04:02:02PM -0800, David Miller wrote:
> >
> > Create a lot of intefaces, try to dump them :-)
> 
> Dumps should be done using 4K (NLMSG_GOODSIZE) skb's, where is the problem?

Actually, more accurately it's using PAGE_SIZE. :)

> > GLIBC can even hit this via it's ifaddrs.c code.
> 
> Do you have a simple test case that I can run?

I see, so the better fix would be to make glibc's
netlink_request() function start with a getpagesize()'d
buffer.

