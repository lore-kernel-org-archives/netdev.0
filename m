From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Wed, 30 Jul 2008 18:10:47 -0700 (PDT)
Message-ID: <20080730.181047.39922732.davem@davemloft.net>
References: <20080730235004.GC21999@xi.wantstofly.org>
	<20080730.165621.211366535.davem@davemloft.net>
	<20080731004123.GB22826@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	herbert@gondor.apana.org.au
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753434AbYGaBKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 21:10:47 -0400
In-Reply-To: <20080731004123.GB22826@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 31 Jul 2008 02:41:23 +0200

> The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
> sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test from:
 ...
> I.e. dramatic CPU time improvements, and some overall speedup as well.
> 
> I wonder if something like this can be done in a less hacky fashion --
> the hard part I guess is deciding when to keep coalescing (to reduce
> CPU overhead) vs. when to push out what has been coalesced so far (in
> order to keep the pipe filled), and I'm not sure I have good ideas
> about how to make that decision.

Interesting, I'll take a closer look at this.

Actually your patch is less of a surprise, because one of the issues I
had to surmount constantly when rewriting the TSO output path was the
implicit conflict between TSO deferral (to accumulate segments) and
the nagle logic.

Anyways, thanks, I'll think about this patch and your data and see
where we can go with that part.

In the mean time could you possibly cook up a cleaned up "use software
GSO for SG+CSUM capable devices" patch?  I think I want to apply it,
especially since all of the things Herbert and I have suspected is
completely confirmed by your data and tests.

