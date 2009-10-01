From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 01 Oct 2009 12:32:52 -0700 (PDT)
Message-ID: <20091001.123252.114903468.davem@davemloft.net>
References: <200910011604.42916.mb@bu3sch.de>
	<1254422548.3959.24.camel@johannes.local>
	<200910012110.34216.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, oliver@hartkopp.net, kalle.valo@iki.fi,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752952AbZJATcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:32:32 -0400
In-Reply-To: <200910012110.34216.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Buesch <mb@bu3sch.de>
Date: Thu, 1 Oct 2009 21:10:32 +0200

> For the benefit of a much bigger critical section? I don't get it
> why this would be any better.

Think about what you are saying when you introduce things
like this into your code:

	if (in_interrupt())
		foo();
	else
		bar();

That thing there means you don't know anything about how you'll need
to do locking properly, because you have no idea about even the
context in which your code is executed.

Sure, you can lock for the most stringent case, but that's silly and
wasteful.
