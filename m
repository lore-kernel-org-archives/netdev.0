From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: VRFs and the scalability of namespaces
Date: Sat, 27 Sep 2014 16:09:25 +0200
Message-ID: <1411826965.2145011.172396149.1433CC1C@webmail.messagingengine.com>
References: <5425EAA6.7040302@gmail.com>
 <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35761 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752084AbaI0OJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 10:09:25 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 5EDF8205D0
	for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 10:09:25 -0400 (EDT)
In-Reply-To: <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Addendum:

On Sat, Sep 27, 2014, at 15:29, Hannes Frederic Sowa wrote:
> Did you already did an investigation how maybe the rule and table
> features could be exploited to suite your needs? Some time back I
> suggested something like "ip route table foo exec ....", keep an default
> routing lookup indicator in task_struct which gets implicitly propagated
> to rtnetlink routing table requests/modification for the requested
> table. Tables already can be specified via rtnetlink, so no change would
> be needed here.
>
> For sockets something like SO_BINDTOTABLE might work, maybe even we can
> by default use the task_struct information to also bind the sockets to
> the per-process table. We certainly need to preserve the routing
> information on the socket as we need those in icmp error handling (e.g.
> where to apply ipv4/ipv6 redirects too). Directing incoming packets to
> specific table also works via ip-rule-iif match.

Update and lookup rule ids must be separated, so a process might need to
get a tuple of references which table to update and which tables to
match in ip rules.

Also some data structures on matching might be change, e.g. an ->action
which takes an interface and returns the routing table id in O(1)
instead of walking the rules and executing the actions in order.

> The problem I see with rules is that some of those tables already work
> hand in hand, they already have a implicit semantics, e.g. local, main,
> default and unspec (this is even worse for IPv6, where addrconf already
> uses hardcoded tables). Working around this might be very tricky and
> even more problematic to do from user space.

We might also add an rule reference to net_device so we redirect the
route changes during address addition/deletion to a separate table,
otherwise user space has to move them non-atomically.

Bye,
Hannes
