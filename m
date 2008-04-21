From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Mon, 21 Apr 2008 12:44:56 +0200
Message-ID: <87y7777ahj.fsf@basil.nowhere.org>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
	<20080420.230356.238029889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: juhlenko@akamai.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:64721 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662AbYDUKp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 06:45:59 -0400
In-Reply-To: <20080420.230356.238029889.davem@davemloft.net> (David Miller's message of "Sun, 20 Apr 2008 23:03:56 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Moving the timestamp up to a higher level takes away some of the
> frequent use cases of timestamps, which is to detect things like the
> fact that it is taking a long time for packets to get from the
> top-level packet receive down to the actual protocol processing.

Is that really a frequent use case? It sounds more like a specialized
debugging situation. Most users are not network stack hackers :)

How about a sysctl to trigger between the two behaviours?
My guess would be that Jason's semantics are better for most systems.

> In fact, people are desiring timestamps which are _closer_ to when the
> device actually receives the frame rather than further away.

The other alternative was always to support loser time stamps especially
for networking. The reason people often complain about the time stamping
at all is when they use x86 systems with no globally reliable TSC which
has to fall back to slower southbridge timers and then they hurt.

But if you are willing to give away some of the guarantees of standard
gettimeofday (like global non monotonicity between CPUs) then you
could actually still use TSC even on those systems. And I don't
think global non monotonicity is really needed for a packet
time stamp ...

-Andi
