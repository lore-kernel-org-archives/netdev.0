From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Sat, 09 May 2009 13:40:02 -0700 (PDT)
Message-ID: <20090509.134002.258408495.davem@davemloft.net>
References: <20090508.144859.152310605.davem@davemloft.net>
	<4A057387.4080308@cosmosbay.com>
	<20090509.133454.111098477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50155
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753843AbZEIUkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:40:06 -0400
In-Reply-To: <20090509.133454.111098477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 09 May 2009 13:34:54 -0700 (PDT)

> Consider the case where we always send some message on CPU A and
> then process the ACK on CPU B.  We'll always be cancelling the
> timer on a foreign cpu.

I should also mention that TCP has a peculiar optimization of timers
that is likely being thwarted by your workload.  It never deletes
timers under normal operation, it simply lets them still expire
and the handler notices that there is "nothing to do" and returns.

But when the connection does shut down, we have to purge all of
these timers.

That could be another part of why you see timers in your profile.
