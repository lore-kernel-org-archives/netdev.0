From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/4] batch calls to fib_flush and arp_ifdown
Date: Mon, 04 Jan 2016 18:35:15 -0600
Message-ID: <87oad0rhh8.fsf@x220.int.ebiederm.org>
References: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:32989 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbcAEAoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 19:44:07 -0500
In-Reply-To: <1451949056-15500-1-git-send-email-noureddine@arista.com> (Salam
	Noureddine's message of "Mon, 4 Jan 2016 15:10:52 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salam Noureddine <noureddine@arista.com> writes:

> fib_flush walks the whole fib in a net_namespace and is called for
> each net_device being closed or unregistered. This can be very expensive
> when dealing with 100k or more routes in the fib and removal of a lot
> of interfaces. These four patches deal with this issue by calling fib_flush
> just once for each net namespace and introduce a new function arp_ifdown_all
> that does a similar optimization for the neighbour table.

Two things would be very valuable with this patchset.

Some numbers on how much your changes have improved the code in the case
you care about.  I suspect the improvements are not subtle so this
should not be hard.

Can you please provide a justification for event_list.  Just skimming
through it appears that event_list because a duplicate of the list of
batched network devices that are passed to dev_close_many and friends.
If the list is actually a duplicate it appears foolish to create it.

Eric

> Salam Noureddine (4):
>   net: add event_list to struct net and provide utility functions
>   net: dev: add batching to net_device notifiers
>   net: core: introduce neigh_ifdown_all for all down interfaces
>   net: fib: avoid calling fib_flush for each device when doing batch
>     close     and unregister
>
>  include/linux/netdevice.h   |  2 ++
>  include/net/arp.h           |  1 +
>  include/net/neighbour.h     |  1 +
>  include/net/net_namespace.h | 22 ++++++++++++++++++++++
>  include/net/netns/ipv4.h    |  1 +
>  net/core/dev.c              | 39 ++++++++++++++++++++++++++++++++++++---
>  net/core/neighbour.c        | 38 +++++++++++++++++++++++++++++++-------
>  net/ipv4/arp.c              |  4 ++++
>  net/ipv4/fib_frontend.c     | 16 ++++++++++++++--
>  9 files changed, 112 insertions(+), 12 deletions(-)
