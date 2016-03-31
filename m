From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 0/4] net: fix and tighten rcu dereference checks
Date: Fri,  1 Apr 2016 01:29:38 +0200
Message-ID: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38636 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbcCaX3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:29:53 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 07C8021B46
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:29:52 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the first patch is really applicable for stable. It adds appropriate
socket locks so lockdep doesn't complain if tuntap's ioctls modify the
filters on the socket.

Rest of the patches tighten the rcu dereference socket lock checks.

Last patch fixes missing rcu_read_locks which were discovered by this
change. Certainly there are more to come.

Hannes Frederic Sowa (4):
  tun: add socket locking around sk_{attach,detach}_filter
  net: proper check if we hold the socket lock during dereference
  sock: use lockdep_sock_is_held were appropriate
  tcp: various missing rcu_read_lock around __sk_dst_get

 drivers/net/tun.c        | 12 ++++++++++++
 include/net/sock.h       | 10 ++++++++--
 include/net/tcp.h        |  5 ++++-
 net/core/filter.c        |  6 +++---
 net/core/sock.c          |  7 +++++--
 net/dccp/ipv4.c          |  2 +-
 net/dccp/ipv6.c          |  2 +-
 net/ipv4/af_inet.c       |  2 +-
 net/ipv4/cipso_ipv4.c    |  3 ++-
 net/ipv4/ip_sockglue.c   |  4 ++--
 net/ipv4/tcp_input.c     | 18 ++++++++++++++----
 net/ipv4/tcp_ipv4.c      |  8 +++-----
 net/ipv4/tcp_metrics.c   | 12 +++++-------
 net/ipv4/tcp_output.c    | 22 ++++++++++++++++++++--
 net/ipv6/ipv6_sockglue.c |  6 ++++--
 net/ipv6/tcp_ipv6.c      |  2 +-
 net/socket.c             |  2 +-
 17 files changed, 87 insertions(+), 36 deletions(-)

-- 
2.5.5
