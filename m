From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13443] New: Scope 1 in multicast addresses in
 IPV6 should be node local
Date: Wed, 03 Jun 2009 21:37:23 -0700 (PDT)
Message-ID: <20090603.213723.03731994.davem@davemloft.net>
References: <bug-13443-10286@http.bugzilla.kernel.org/>
	<20090603144031.2945f24d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750858AbZFDEhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 00:37:23 -0400
In-Reply-To: <20090603144031.2945f24d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 3 Jun 2009 14:40:31 -0700

>> I think scope 1 in multicast addresses in IPV6 should be node local (according
>> to all the documentation + rfc I found on the web) and therefore pkt's with
>> such destination address should not go on the wire.
>> When I try to send a udp pkt with sock_dgram to such ipv6 address with scope 1
>> I see the pkt is going on the wire and I can catch it on the other side by
>> joining this multicast address.

It looks like we need an addr_type and device check in ip6_output().

But in my opinion this is a pretty bogus requirement.  It's so easy
for things like netfilter, the packet scheduler classifier, or
other entities to get the packet to be rewritten from loopback
to an externally visible interface.
