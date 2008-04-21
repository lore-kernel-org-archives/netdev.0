From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Mon, 21 Apr 2008 03:59:39 -0700 (PDT)
Message-ID: <20080421.035939.37324583.davem@davemloft.net>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
	<20080420.230356.238029889.davem@davemloft.net>
	<87y7777ahj.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: juhlenko@akamai.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754325AbYDUK7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 06:59:42 -0400
In-Reply-To: <87y7777ahj.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Apr 2008 12:44:56 +0200

> David Miller <davem@davemloft.net> writes:
> 
> > Moving the timestamp up to a higher level takes away some of the
> > frequent use cases of timestamps, which is to detect things like the
> > fact that it is taking a long time for packets to get from the
> > top-level packet receive down to the actual protocol processing.
> 
> Is that really a frequent use case? It sounds more like a specialized
> debugging situation. Most users are not network stack hackers :)

Ask a financial service industry shop what the implications of
inaccurate transaction timestamps can be.  It possible for it to be
measured in the millions if not billions of euros.

> But if you are willing to give away some of the guarantees of standard
> gettimeofday (like global non monotonicity between CPUs) then you
> could actually still use TSC even on those systems. And I don't
> think global non monotonicity is really needed for a packet
> time stamp ...

So if tcpdump gets resceduled on another cpu, or the multiqueue flow
hashing algorithm changes, the appearance of the ordering of packets
changes.

No thanks.

Nobody wants half-working timestamps.  That's why it's such an
enormous issue that x86 screwed this up so badly for such a long
period of time.
