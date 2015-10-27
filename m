From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 07:39:14 -0700 (PDT)
Message-ID: <20151027.073914.310976982324296607.davem@davemloft.net>
References: <562F7E16.2070906@oracle.com>
	<20151027.065924.796277086557445997.davem@davemloft.net>
	<562F868B.4040001@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbbJ0OWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:22:34 -0400
In-Reply-To: <562F868B.4040001@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Tue, 27 Oct 2015 14:13:31 +0000

> Ideally there'd be a single way of doing this that worked
> cross-platform, at the moment there isn't. And yes, even if such a
> mechanism was available now it would be some time before it could be
> assumed to be available everywhere.

You will never be able to assume it is available everywhere under
Linux.  Ever.

This is the fundamental issue that you seem to completely not
understand.

You cannot just assume 5 years from now or whatever that the close()
thing is there even if I added it to the tree right now.

Your intent is to somewhere down the road assume this, and therefore
distribute a broken piece of infrastructure that only works on some
Linux systems.

This is not acceptable.

The backwards compat code will need to be in your code forever.  There
is no way around it.  That is, again, unless you want your code to not
work on a non-trivial number of Linux systems out there.

Making this worse is that there isn't going to be a straightforward
nor reliable way to test for the presence of this at run time.

You _have_ a way to accomplish what you want to do today and it works
on every Linux system on the planet.

Given the constraints, and the fact that you're going to have to
account for this situation somehow in your code forever, I see very
little to no value in adding the close() thing.

So your cross-platform unified behavior goal is simply unobtainable.
So please deal with reality rather than wishful inpractical things.
