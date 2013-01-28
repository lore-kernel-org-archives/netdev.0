From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 0/2] l2tp: fix ancilliary data handling in ip6 recv
Date: Mon, 28 Jan 2013 10:48:52 +0000
Message-ID: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49840 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab3A1KtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 05:49:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip6 was using the IPv4 handler functions for ancilliary data, which meant
that socket options such as e.g. IPV6_RECVPKTINFO are not correctly passed to
userspace.

This patchset:

	*  exports the IPv6 recv handler function datagram_recv_ctl so that
	   modules may access it
	*  updates l2tp_ip6 to use datagram_recv_ctl rather than ip_cmsg_recv

Tom Parkin (2):
  ipv6: export symbol datagram_recv_ctl in datagram.c
  l2tp: correctly handle ancilliary data for ip6 recv

 net/ipv6/datagram.c |    1 +
 net/l2tp/l2tp_ip6.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.7.9.5
