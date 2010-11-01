From: David Miller <davem@davemloft.net>
Subject: Re: Routing over multiple interfaces
Date: Mon, 01 Nov 2010 14:16:38 -0700 (PDT)
Message-ID: <20101101.141638.116372747.davem@davemloft.net>
References: <1288645922.5977.41.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uweber@astaro.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab0KAVQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:16:15 -0400
In-Reply-To: <1288645922.5977.41.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 01 Nov 2010 17:12:02 -0400

> But when I do a large upload, I find that the kernel is only ever using
> a *single* link at a time, rather than both. How can I make it use
> *both* links? It's fine to confine each flow to a single link if it
> doesn't saturate that link... but once the queue is full, it should
> overflow onto the other device.

Once a TCP socket gets a routing cache entry, that's what it uses
for the rest of the life of the connection.

The multi-pathing decision happens at the time the routing
cache entry is created.

What you want is multi-path routing support in the routing cache.

We used to have that, but the guy who implemented it (after bugging
me to integrate it for 4 months straight, non-stop) just did a code
dump and then disappeared and fixed none of the serious fundamental
problems which existed in his code.

After a year of no action, I simply tore out all of his code.

More recently Ulrich Weber gave a presentation at netfilter workshop
on some uplink load balancing work he is doing, you might have
a look at his talk and get in contact with him:

http://people.astaro.com/uweber/uplink_balancing.pdf
