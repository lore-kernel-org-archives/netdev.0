From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v3 0/2] ipv4: per-datagram IP_TOS and IP_TTL via sendmsg()
Date: Tue, 24 Sep 2013 15:43:07 +0200
Message-ID: <cover.1379944641.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab3IXNnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 09:43:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no way to set the IP_TOS field on a per-packet basis in IPv4, while
IPv6 has such a mechanism. Therefore one has to fall back to the setsockopt()
in case of IPv4. 

Using the existing per-socket option is not convenient particularly in the
situations where multiple threads have to use the same socket data requiring
per-thread TOS values. In fact this would involve calling setsockopt() before
sendmsg() every time.


Francesco Fusco (2):
  ipv4: IP_TOS and IP_TTL can be specified as ancillary data
  ipv4: processing ancillary IP_TOS or IP_TTL

 include/net/inet_sock.h |  3 +++
 include/net/ip.h        | 14 ++++++++++++++
 include/net/route.h     |  1 +
 net/ipv4/icmp.c         |  5 +++++
 net/ipv4/ip_output.c    | 13 ++++++++++---
 net/ipv4/ip_sockglue.c  | 20 +++++++++++++++++++-
 net/ipv4/ping.c         |  4 +++-
 net/ipv4/raw.c          |  4 +++-
 net/ipv4/udp.c          |  4 +++-
 9 files changed, 61 insertions(+), 7 deletions(-)

-- 
1.8.3.1
