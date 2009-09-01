From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.31 ARP related problems with multiple macvlan NICs
Date: Tue, 01 Sep 2009 06:20:20 -0700
Message-ID: <m163c2ztrf.fsf@fess.ebiederm.org>
References: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48413 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622AbZIANUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 09:20:24 -0400
In-Reply-To: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com> (Or Gerlitz's message of "Tue\, 1 Sep 2009 14\:30\:28 +0300 \(IDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> writes:

> Using multiple (e.g 2) macvlan devices set over the same uplink NIC
> and 2.6.31-rc7 I can get only one of the macvlan devices to respond on
> arp request where the same scheme works fine on 2.6.29.1 and 2.6.30.
>
> The only devices for which the system responds on ARP request is the
> first match in the routing table, e.g mv0 below. Next are the commands
> I am using to set the environment that reproduces the problem.
>
> Looking on net/ipv4/arp.c I do someting that may be related which
> was commited for 2.6.30 and reverted for -stable and .31 so the
> fact that this test actually works with 2.6.29.1/2.6.30 makes me
> think that the problem I see is not directly connected to the "ipv4: arp
> announce, arp_proxy and windows ip conflict verification" commit/revert.
>
> The problem is also not directly related to macvlan, I think, e.g
> I have the same issue when having multiple veth pairs connected
> to a bridge, only ping to/through the first routing hit works.

I just tested.  If the two macvlans are in separate network namespaces
all is well, so definitely not macvlan.

As you have observed there are no real changes to arp.c

Interesting I can reproduce this to machines on the same network
segment but not to machines on different network segments.

Weird.


Eric
