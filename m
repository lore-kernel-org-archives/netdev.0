From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Tue, 20 Apr 2010 19:04:14 -0700 (PDT)
Message-ID: <20100420.190414.252166338.davem@davemloft.net>
References: <4BCE3D8D.3030500@candelatech.com>
	<1271808314.7895.614.camel@edumazet-laptop>
	<20100421003022.GA3107@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753432Ab0DUCEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 22:04:10 -0400
In-Reply-To: <20100421003022.GA3107@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 21 Apr 2010 04:30:22 +0400

> To return back to exponential bind() times you need to revert the whole
> original patch including magic 5 number, not only bsockets.

Indeed, if we keep that '5' thing there it's just going to still fail
similarly.

> But actual problem is not in this digit, but in a deeper logic.
> Previously we scanned the whole table, now we have 5 attempts to
> find out at least one bucket (without conflict) we will insert
> new socket into. Apparently for large number of addresses it is possible
> that all 5 times we will randomly select those buckets which conflicts.
> As dumb solution we can increase 'attempt' number to infinite one, or
> fallback to whole-table-search after several random attempts, which is a
> bit more clever I think.

If random number generator is not too terrible, just using infinite
limit would be roughly equivalent.
