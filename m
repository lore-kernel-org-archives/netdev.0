From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Fri, 06 Apr 2012 12:43:44 -0400 (EDT)
Message-ID: <20120406.124344.564538802640968013.davem@davemloft.net>
References: <20120404165559.5223ab95@s6510.linuxnetplumber.net>
	<20120404.202109.2046106039992811660.davem@davemloft.net>
	<4F7F10FC.3020308@enea.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	balferreira@googlemail.com, arvid.brodin@xdin.com
To: arvid.brodin@enea.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868Ab2DFQoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 12:44:12 -0400
In-Reply-To: <4F7F10FC.3020308@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@enea.com>
Date: Fri, 6 Apr 2012 17:51:24 +0200

> Just out of curiosity, what's the mechanism behind this inline
> assignment that turns the memcpy into an unaligned access? If gcc is 
> "smart" enough to detect a bunch of char * accesses and turn them 
> into unaligned 32-bit accesses, isn't that a bug in gcc?

It's not doing it with "char *", it's doing it with other types like
the type of the ICMP header in this case.

memcpy is expanded by the compiler internally into __builtin_memcpy()
which if it sees the length is reasonably short will inline the
copy.  And subsequently it uses the alignment of the types involved
to determine what kinds of loads and stores it can use in that
inline memcpy().

So the result is that just because in your case with your compiler
it doesn't get expanded inline and fault, it doesn't mean it won't
for someone else.

You're just lucky, and you really haven't fixed the bug.
