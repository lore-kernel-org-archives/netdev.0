From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/3] sock: lockdep tightening
Date: Tue,  5 Apr 2016 17:10:13 +0200
Message-ID: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Cc: daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57252 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758293AbcDEPKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:10:23 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 5103F216CA
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 11:10:22 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch is from Eric Dumazet and improves lockdep accuracy for
socket locks. After that, second patch introduces lockdep_sock_is_held
and uses it. Final patch reverts and reworks the lockdep fix from Daniel
in the filter code, as we now have tighter lockdep support.

Hannes Frederic Sowa (3):
  sock: fix lockdep annotation in release_sock
  net: introduce lockdep_is_held and update various places to use it
  tun: use socket locks for sk_{attach,detatch}_filter

 drivers/net/tun.c        | 14 +++++++++-----
 include/linux/filter.h   |  4 ----
 include/net/sock.h       | 19 ++++++++++++++++---
 net/core/filter.c        | 35 +++++++++++++----------------------
 net/core/sock.c          |  5 -----
 net/dccp/ipv4.c          |  2 +-
 net/dccp/ipv6.c          |  2 +-
 net/ipv4/af_inet.c       |  2 +-
 net/ipv4/cipso_ipv4.c    |  3 ++-
 net/ipv4/ip_sockglue.c   |  4 ++--
 net/ipv4/tcp_ipv4.c      |  8 +++-----
 net/ipv6/ipv6_sockglue.c |  6 ++++--
 net/ipv6/tcp_ipv6.c      |  2 +-
 net/socket.c             |  2 +-
 14 files changed, 54 insertions(+), 54 deletions(-)

-- 
2.5.5
