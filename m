From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH  v2 0/6] ipv6: Do route updating for redirect in ndisc layer
Date: Fri, 13 Sep 2013 10:57:04 +0800
Message-ID: <52327F00.4040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:33522 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab3IMC6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 22:58:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

the ip6_redirect() could be replaced with
ip6_redirect_no_header(), we could always use ip6_redirect()
for route updating in ndisc layer and use the data of the
redirected header option just for finding the socket to be
notified and then notify user in protocols' err_handler.

---
 Changes for v2:
 1.handle the update of the NDISC_REDIRECT error code directly in
   icmpv6_err_convert.
 2.squash some patchs into one patch.
 3.modify the subject of those patchs.

Duan Jiong (6):
  ipv6: del the statements for updating route in (dccp|tcp|sctp)_v6_err
  ipv6: just match on ICMPV6_PKT_TOOBIG in those err_handle
  ipv6: del statements for dealing with NDISC_REDIRECT
  ip6tnl: move route updating for redirect to ndisc layer
  ipv6: modify the err to 0 when dealing with NDISC_REDIRECT
  ipv6: Do route updating for redirect in ndisc layer

 include/net/ip6_route.h |  3 ---
 net/dccp/ipv6.c         | 10 +++-------
 net/ipv6/ah6.c          |  9 ++-------
 net/ipv6/esp6.c         |  9 ++-------
 net/ipv6/icmp.c         |  5 +++--
 net/ipv6/ip6_tunnel.c   |  5 -----
 net/ipv6/ipcomp6.c      |  9 ++-------
 net/ipv6/ndisc.c        |  6 ++----
 net/ipv6/raw.c          |  3 +--
 net/ipv6/route.c        | 29 ++---------------------------
 net/ipv6/tcp_ipv6.c     | 12 ++++--------
 net/ipv6/udp.c          |  2 --
 net/sctp/input.c        | 12 ------------
 net/sctp/ipv6.c         |  6 +++---
 14 files changed, 24 insertions(+), 96 deletions(-)

-- 
1.8.3.1
