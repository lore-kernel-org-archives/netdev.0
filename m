From: David Miller <davem@davemloft.net>
Subject: Re: Deadlock with icmpv6fuzz
Date: Tue, 24 Feb 2009 23:44:01 -0800 (PST)
Message-ID: <20090224.234401.257258567.davem@davemloft.net>
References: <20090206.030716.136181382.davem@davemloft.net>
	<20090209050354.GA3548@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752505AbZBYHoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:44:20 -0500
In-Reply-To: <20090209050354.GA3548@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 16:03:54 +1100

> David Miller <davem@davemloft.net> wrote:
> >
> > But some apps might start breaking since this would now
> > charge the socket and we could hit the limits whereas
> > before we wouldn't.
> 
> Yes we should definitely test this carefully.
> 
> However, I think it is the right thing to do since we shouldn't
> leave holes where the user can allocate kernel memory that is
> uncapped.
> 
> In fact, a number of spots in IPv6 already use sock_kmalloc
> for these objects anyway (e.g., ipv6_dup_options in exthdrs.c)
> so there is no fundamental reason why this limit can't be imposed.

Actually it turns out we can't do that here.  This flow label object
is global, rather than specifically associated with a given socket.

See net/ipv6/ip6_flowlabel.c:fl_{create,intern}() and how those
are used.
