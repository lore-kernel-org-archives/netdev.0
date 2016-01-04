From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next 0/4] batch calls to fib_flush and arp_ifdown
Date: Mon,  4 Jan 2016 15:10:52 -0800
Message-ID: <1451949056-15500-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:44718 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753601AbcADXSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:18:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_flush walks the whole fib in a net_namespace and is called for
each net_device being closed or unregistered. This can be very expensive
when dealing with 100k or more routes in the fib and removal of a lot
of interfaces. These four patches deal with this issue by calling fib_flush
just once for each net namespace and introduce a new function arp_ifdown_all
that does a similar optimization for the neighbour table.

Salam Noureddine (4):
  net: add event_list to struct net and provide utility functions
  net: dev: add batching to net_device notifiers
  net: core: introduce neigh_ifdown_all for all down interfaces
  net: fib: avoid calling fib_flush for each device when doing batch
    close     and unregister

 include/linux/netdevice.h   |  2 ++
 include/net/arp.h           |  1 +
 include/net/neighbour.h     |  1 +
 include/net/net_namespace.h | 22 ++++++++++++++++++++++
 include/net/netns/ipv4.h    |  1 +
 net/core/dev.c              | 39 ++++++++++++++++++++++++++++++++++++---
 net/core/neighbour.c        | 38 +++++++++++++++++++++++++++++++-------
 net/ipv4/arp.c              |  4 ++++
 net/ipv4/fib_frontend.c     | 16 ++++++++++++++--
 9 files changed, 112 insertions(+), 12 deletions(-)

-- 
1.8.1.4
