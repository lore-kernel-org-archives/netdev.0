From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH v2 net-next 0/4] batch calls to fib_flush and arp_ifdown
Date: Thu,  4 Feb 2016 15:35:52 -0800
Message-ID: <1454628956-4803-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:49836 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757340AbcBDXnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 18:43:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added changes suggested by Julian Anastasov in version 2.

fib_flush walks the whole fib in a net_namespace and is called for
each net_device being closed or unregistered. This can be very expensive
when dealing with 100k or more routes in the fib and removal of a lot
of interfaces. These four patches deal with this issue by calling fib_flush
just once for each net namespace and introduce a new function arp_ifdown_all
that does a similar optimization for the neighbour table.

The benchmark tests were run on linux-3.18.

Salam Noureddine (4):
  net: add event_list to struct net and provide utility functions
  net: dev: add batching to net_device notifiers
  net: core: introduce neigh_ifdown_all for all down interfaces
  net: fib: avoid calling fib_flush for each device when doing batch
    close     and unregister

 include/linux/netdevice.h   |  2 ++
 include/net/arp.h           |  1 +
 include/net/neighbour.h     |  1 +
 include/net/net_namespace.h | 22 +++++++++++++++++++++
 include/net/netns/ipv4.h    |  1 +
 net/core/dev.c              | 48 ++++++++++++++++++++++++++++++++++++++++-----
 net/core/neighbour.c        | 38 ++++++++++++++++++++++++++++-------
 net/core/net_namespace.c    |  1 +
 net/ipv4/arp.c              |  4 ++++
 net/ipv4/fib_frontend.c     | 16 +++++++++++++--
 10 files changed, 120 insertions(+), 14 deletions(-)

-- 
1.8.1.4
