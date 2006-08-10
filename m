From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/06]: Increase number of possible routing tables
Date: Thu, 10 Aug 2006 21:29:57 +0200 (MEST)
Message-ID: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38618 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751240AbWHJT37
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:29:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are the updated patches (against net-2.6.19) to increase the number
of possible routing tables to 2^32. They basically consist of four parts:

- Use u32 for routing table IDs everywhere inside the kernel

- Introduce new netlink attributes to carry extended table IDs and add
  compatibility functions to use either rtm_table or the new attributes
  if given.

- Prepare IPv4/IPv6/DecNET for increasing RT_TABLE_MAX to 2^32 by using
  hash tables instead of a fixed size array of pointers (IPv4 and DecNET,
  IPv6 already contains that part) and replacing iterations over all
  possible table IDs by hash walking.

- Finally, increase RT_TABLE_MAX to 2^32

IPv4 and IPv6 are tested with and without CONFIG_MULTIPLE_TABLES, DecNET
is only compile tested.


 include/linux/fib_rules.h |    4 +
 include/linux/rtnetlink.h |   12 ++-
 include/net/dn_fib.h      |    7 -
 include/net/fib_rules.h   |    7 +
 include/net/ip6_route.h   |    7 +
 include/net/ip_fib.h      |   39 +++-------
 net/core/fib_rules.c      |    5 -
 net/decnet/dn_fib.c       |   62 +---------------
 net/decnet/dn_route.c     |    1 
 net/decnet/dn_rules.c     |    2 
 net/decnet/dn_table.c     |  136 ++++++++++++++++++++++++++----------
 net/ipv4/fib_frontend.c   |  117 ++++++++++++++++++++-----------
 net/ipv4/fib_hash.c       |   30 ++++----
 net/ipv4/fib_lookup.h     |    4 -
 net/ipv4/fib_rules.c      |    7 +
 net/ipv4/fib_semantics.c  |    5 -
 net/ipv4/fib_trie.c       |   32 ++++----
 net/ipv4/route.c          |    1 
 net/ipv6/fib6_rules.c     |    1 
 net/ipv6/ip6_fib.c        |  171 ++++++++++++++++++++++++++++++++++++++++------
 net/ipv6/route.c          |  141 ++-----------------------------------
 21 files changed, 430 insertions(+), 361 deletions(-)

Patrick McHardy:
      [NET]: Use u32 for routing table IDs
      [NET]: Introduce RTA_TABLE/FRA_TABLE attributes
      [IPV4]: Increase number of possible routing tables to 2^32
      [IPV6]: Increase number of possible routing tables to 2^32
      [DECNET]: Increase number of possible routing tables to 2^32
      [NET]: Increate RT_TABLE_MAX to 2^32
