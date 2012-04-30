From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 00/10 net-next] l2tp: misc fixes and add L2TPv3 IP encap over IPv6
Date: Mon, 30 Apr 2012 08:48:45 +0100
Message-ID: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53471 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426Ab2D3Hs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:48:58 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 1D9F4A62075
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 08:48:56 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes several L2TP fixes / cleanups and adds
L2TPv3 IP encapsulation support for IPv6, building on the L2TP UDP
IPv6 support recently added by Ben LaHaise.

  1. l2tp: fix locking of 64-bit counters for smp
  2. l2tp: Use ip4_datagram_connect() in l2tp_ip_connect()
  3. l2tp: remove unused stats from l2tp_ip socket
  4. pppox: Replace __attribute__((packed)) in if_pppox.h
  5. l2tp: pppol2tp_connect() handles ipv6 sockaddr variants
  6. l2tp: show IPv6 addresses in l2tp debugfs file
  7. l2tp: netlink api for l2tpv3 ipv6 unmanaged tunnels
  8. ipv6: export ipv6 functions for use by other protocols
  9. l2tp: introduce L2TPv3 IP encapsulation support for IPv6
 10. l2tp: let iproute2 create L2TPv3 IP tunnels using IPv6

Patches 1-4 are fixes / cleanups.
Patches 5-6 improve on the L2TP UDP IPv6 changes recently added.
Patches 7-10 add functionality.

A patch for iproute2 to add support for unmanaged L2TPv3 ethernet
tunnels over IPv6 will be submitted separately.

Chris Elston (4):
  l2tp: show IPv6 addresses in l2tp debugfs file
  l2tp: netlink api for l2tpv3 ipv6 unmanaged tunnels
  ipv6: Export ipv6 functions for use by other protocols
  l2tp: introduce L2TPv3 IP encapsulation support for IPv6

James Chapman (6):
  l2tp: fix locking of 64-bit counters for smp
  l2tp: Use ip4_datagram_connect() in l2tp_ip_connect()
  l2tp: remove unused stats from l2tp_ip socket
  pppox: Replace __attribute__((packed)) in if_pppox.h
  l2tp: pppol2tp_connect() handles ipv6 sockaddr variants
  l2tp: let iproute2 create L2TPv3 IP tunnels using IPv6

 include/linux/if_pppox.h |   12 +-
 include/linux/l2tp.h     |   19 ++
 net/ipv6/datagram.c      |    4 +
 net/ipv6/exthdrs.c       |    1 +
 net/ipv6/ip6_flowlabel.c |    1 +
 net/ipv6/ip6_output.c    |    3 +
 net/l2tp/Makefile        |    3 +
 net/l2tp/l2tp_core.c     |  215 ++++++++++---
 net/l2tp/l2tp_core.h     |    5 +
 net/l2tp/l2tp_debugfs.c  |    8 +
 net/l2tp/l2tp_ip.c       |   86 +-----
 net/l2tp/l2tp_ip6.c      |  792 ++++++++++++++++++++++++++++++++++++++++++++++
 net/l2tp/l2tp_netlink.c  |  110 ++++++--
 net/l2tp/l2tp_ppp.c      |   36 ++-
 14 files changed, 1133 insertions(+), 162 deletions(-)
 create mode 100644 net/l2tp/l2tp_ip6.c
