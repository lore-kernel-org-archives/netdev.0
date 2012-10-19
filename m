From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 15:13:48 -0400
Message-ID: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:42872 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756707Ab2JSTNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:13:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 of an attempt to pull in the relevant fixes for a problem in
v2.6.32 kernels where invalid cached routes are retained even after changes
to the routing table have been made.  A simple test case can be found at 
http://marc.info/?l=linux-netdev&m=135015076708950&w=2 .  Based on feedback 
from David Miller, additional changes have been pulled in, including fixes
for the same issue in IPv6.  Most of the patches required some rework owing
to the large differences in the networking stack between 2.6.32 and 3.6.

I have performed basic tests to confirm that the cases I was hitting are
now fixed, including a couple of tests with IPv4 and IPv6.  Comments?  
Thanks again to David for the pointers to the additional fixes required in
this area.

Benjamin LaHaise (6):
  ipv4: check_rt_genid in dst_check
  net: Document dst->obsolete better.
  ipv6: use DST_* macro to set obselete field
  netns: move net->ipv4.rt_genid to net->rt_genid
  ipv6: use net->rt_genid to check dst validity
  xfrm: invalidate dst on policy insertion/deletion

 include/net/dst.h                |   14 +++++++++++++-
 include/net/ip6_fib.h            |    4 +---
 include/net/net_namespace.h      |   12 ++++++++++++
 include/net/netns/ipv4.h         |    1 -
 net/core/dst.c                   |    4 ++--
 net/ipv4/route.c                 |   28 +++++++++++++++-------------
 net/ipv6/inet6_connection_sock.c |   24 +-----------------------
 net/ipv6/route.c                 |   35 ++++++++++++++++++++++++-----------
 net/sctp/output.c                |    2 +-
 net/xfrm/xfrm_policy.c           |   22 ++++++++++++----------
 security/selinux/include/xfrm.h  |    1 +
 11 files changed, 82 insertions(+), 65 deletions(-)


-- 
"Thought is the essence of where you are now."
