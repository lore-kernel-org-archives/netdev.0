From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [RFC net-next 00/12] remove code duplication in tcp_v[46]_conn_request
Date: Mon, 23 Jun 2014 21:42:37 +0300
Message-ID: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42040 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753495AbaFWSnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 14:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes code duplication in tcp_v4_conn_request and
tcp_v6_conn_request by adding a few new methods in
tcp_request_sock_ops.

Since this can potentially have performance impact I will later come
back with some benchmarks results for before and after -- I am
thinking that connections per second tests should cover it.

In the meanwhile, any feedback on the approach is kindly appreciated.

The first 3 patches are cleanups and fixes found during the code merge
process, which shows that having a single tcp_conn_request function is
useful to avoid future issues.

Octavian Purdila (12):
  tcp: cookie_v4_init_sequence: skb should be const
  tcp: tcp_v[46]_conn_request: fix snt_synack initialization
  net: remove inet6_reqsk_alloc
  tcp: add init_req method to tcp_request_sock_ops
  tcp: add init_cookie_seq method to tcp_request_sock_ops
  tcp: add route_req method to tcp_request_sock_ops
  tcp: move around a few calls in tcp_v6_conn_request
  tcp: add init_seq method to tcp_request_sock_ops
  tcp: add send_synack method to tcp_request_sock_ops
  tcp: unify tcp_v4_rtx_synack and tcp_v6_rtx_synack
  tcp: add mss_clamp to tcp_request_sock_ops
  tcp: add tcp_conn_request

 include/linux/ipv6.h    |  10 ---
 include/linux/tcp.h     |   3 -
 include/net/inet_sock.h |   6 +-
 include/net/tcp.h       |  52 +++++++++----
 net/dccp/ipv6.c         |   2 +-
 net/ipv4/syncookies.c   |   3 +-
 net/ipv4/tcp_input.c    | 148 +++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c     | 188 +++++++++++---------------------------------
 net/ipv4/tcp_output.c   |  15 ++++
 net/ipv6/syncookies.c   |   2 +-
 net/ipv6/tcp_ipv6.c     | 202 +++++++++++++-----------------------------------
 11 files changed, 303 insertions(+), 328 deletions(-)

-- 
1.8.3.2
