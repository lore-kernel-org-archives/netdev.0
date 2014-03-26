From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return
 -EINTR
Date: Wed, 26 Mar 2014 17:05:14 -0400 (EDT)
Message-ID: <20140326.170514.1793472148242469413.davem@davemloft.net>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbaCZVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:05:16 -0400
In-Reply-To: <87y4zw7ngi.fsf@sable.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Wed, 26 Mar 2014 19:46:05 +0000

> As I already wrote, this is a theoretical problem with no really
> satisfactory solution minus noting that both 'nonblocking sockets' and
> 'multithreaded kernels' are somewhat alien concepts when considering the
> system where EINTR originated (AFAIK).

I completely disagree.

EINTR always means that you asked for a blocking operation, and a
signal arrived meanwhile.

Once you invert the "blocking" part of that set of conditrions, EINTR
becomes an impossible event.

I don't have time to check BSD, but I'm very confident that these are
the rules codified in their socket syscall layer too.

I'm going to apply Eric's patch.
