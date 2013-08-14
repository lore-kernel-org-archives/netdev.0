From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next 0/2] ipv4: per-datagram IP_TOS and IP_TTL via sendmsg()
Date: Wed, 14 Aug 2013 17:48:37 +0200
Message-ID: <cover.1376494030.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758427Ab3HNPsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 11:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no way to set the IP_TOS field on a per-packet basis in IPv4, while
IPv6 has such a mechanism. Therefore one has to fall back to the setsockopt()
in case of IPv4. 

Using the existing per-socket option is not convenient particularly in the
situations where multiple threads have to use the same socket data requiring
per-thread TOS values. In fact this would involve calling setsockopt() before
sendmsg() every time.

An old patch was submitted to the netdev mailing list to add support for
setting TOS on a per-packet basis, but was never integrated into the kernel.
The old patch can be found here:
http://marc.info/?l=linux-netdev&m=118388241201593 

This patch contains the changes from the original patch, updated for the
current kernel.

Francesco Fusco (2):
  ipv4: IP_TOS and IP_TTL can be specified as ancillary data
  ipv4: processing ancillary IP_TOS or IP_TTL

 include/net/inet_sock.h |  3 +++
 include/net/ip.h        |  3 +++
 net/ipv4/icmp.c         | 11 ++++++-----
 net/ipv4/ip_output.c    | 17 ++++++++++++++---
 net/ipv4/ip_sockglue.c  | 20 +++++++++++++++++++-
 net/ipv4/raw.c          |  3 +++
 net/ipv4/udp.c          |  3 +++
 7 files changed, 51 insertions(+), 9 deletions(-)

-- 
1.8.3.1
