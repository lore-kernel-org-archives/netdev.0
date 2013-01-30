From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH v2 0/3] l2tp: fix ancillary data handling in ipv6 recv
Date: Wed, 30 Jan 2013 14:21:23 +0000
Message-ID: <1359555686-21588-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34801 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab3A3OVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 09:21:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmitting patchset to fix l2tp's handling of ancillary data for ipv6.

This patchset:

	* Renames the ipv6-specific datagram_send_ctl and datagram_recv_ctl
	  functions as ip6_datagram_*.  Since datagram_send_ctl is publicly
	  exported it should be named such that it's clearly IPv6-specific.

	* Export ip6_datagram_recv_ctl, so that modules may use it in their
	  receive paths.

	* Change l2tp_ip6 from using the IPv4-specific ip_cmsg_recv to use the
	  IPv6 version ip6_datagram_recv_ctl.

Patch 0001 includes some minor whitespace change in order to comply with
checkpatch.pl's style recommendations.

Tom Parkin (3):
  ipv6: rename datagram_send_ctl and datagram_recv_ctl
  ipv6: export ip6_datagram_recv_ctl
  l2tp: correctly handle ancillary data in the ip6 recv path

 include/net/transp_v6.h  |    4 ++--
 net/ipv6/datagram.c      |   10 ++++++----
 net/ipv6/ip6_flowlabel.c |    4 ++--
 net/ipv6/ipv6_sockglue.c |    6 +++---
 net/ipv6/raw.c           |    4 ++--
 net/ipv6/udp.c           |    4 ++--
 net/l2tp/l2tp_ip6.c      |    8 ++++----
 net/sunrpc/svcsock.c     |    2 +-
 8 files changed, 22 insertions(+), 20 deletions(-)

-- 
1.7.9.5
