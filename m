From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/2] Neighbour table prep for MPLS
Date: Tue, 03 Mar 2015 17:09:35 -0600
Message-ID: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40812 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbbCCXNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:13:09 -0500
In-Reply-To: <20150303.153310.624302583835136622.davem@davemloft.net> (David
	Miller's message of "Tue, 03 Mar 2015 15:33:10 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for using the IPv4 and IPv6 neighbour tables in my mpls
code this patchset factors out ___neigh_lookup_noref from
__ipv4_neigh_lookup_noref, __ipv6_lookup_noref and neigh_lookup.
Allowing the lookup logic to be shared between the different
implementations.  At what appears to be no cost. (Aka the same assembly
is generated for ip6_finish_output2 and ip_finish_output2).

After that I add a simple function that takes an address family and an
address consults the neighbour table and sends the packet to the
appropriate location.  The address family argument decoupls callers
of neigh_xmit from the addresses families the packets are sent over.
(Aka The ipv6 module can be loaded after mpls and a previously
configured ipv6 next hop will start working).

The refactoring in ___neigh_lookup_noref may be a bit overkill but it
feels like the right thing to do.  Especially since the same code is
generated.

Eric W. Biederman (2):
      neigh: Factor out ___neigh_lookup_noref
      neigh: Add helper function neigh_xmit

 include/net/arp.h       | 19 ++++-------------
 include/net/ndisc.h     | 19 +----------------
 include/net/neighbour.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/neighbour.c    | 54 ++++++++++++++++++++++++++++++++++--------------
 net/decnet/dn_neigh.c   |  6 ++++++
 net/ipv4/arp.c          |  9 +++++++-
 net/ipv6/ndisc.c        |  7 +++++++
 7 files changed, 120 insertions(+), 49 deletions(-)
