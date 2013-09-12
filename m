From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 00/11] ipv6: Do route updating for redirect in ndisc layer
Date: Thu, 12 Sep 2013 18:41:50 +0800
Message-ID: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:39642 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751545Ab3ILKmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:42:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the ip6_redirect() could be replaced with
ip6_redirect_no_header(), we could always use ip6_redirect()
for route updating in ndisc layer and use the data of the
redirected header option just for finding the socket to be
notified and then notify user in protocols' err_handler.

---

 include/net/ip6_route.h |  3 ---
 net/dccp/ipv6.c         | 10 +++-------
 net/ipv6/ah6.c          |  9 ++-------
 net/ipv6/esp6.c         |  9 ++-------
 net/ipv6/icmp.c         |  2 --
 net/ipv6/ip6_tunnel.c   |  5 -----
 net/ipv6/ipcomp6.c      |  9 ++-------
 net/ipv6/ndisc.c        |  6 ++----
 net/ipv6/raw.c          |  2 +-
 net/ipv6/route.c        | 29 ++---------------------------
 net/ipv6/tcp_ipv6.c     | 12 ++++--------
 net/ipv6/udp.c          |  4 ++--
 net/sctp/input.c        | 12 ------------
 net/sctp/ipv6.c         |  6 +++---
 14 files changed, 23 insertions(+), 95 deletions(-)

-- 
1.8.3.1
