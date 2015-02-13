From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 0/3] Small fix for TCP PMTU
Date: Fri, 13 Feb 2015 16:16:42 +0800
Message-ID: <1423815405-32644-1-git-send-email-fan.du@intel.com>
Cc: netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52060 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbbBMIVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 03:21:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset perform some small fix for current TCP PMTU
as per RFC4821 with below changes:

Patch1/3: Set probe mss base to 1024 Bytes
Patch2/3: Do not double probe_size for each probing,
	  use a simple binary search to gain maximum performance.
Patch3/3: Create a probe timer to detect enlarged path MTU.

Fan Du (3):
  ipv4: Raise tcp PMTU probe mss base size
  ipv4: Use binary search to choose tcp PMTU probe_size
  ipv4: Create probe timer for tcp PMTU as per RFC4821

 include/net/inet_connection_sock.h |    5 +++++
 include/net/netns/ipv4.h           |    1 +
 include/net/tcp.h                  |    5 ++++-
 net/ipv4/sysctl_net_ipv4.c         |    7 +++++++
 net/ipv4/tcp.c                     |    2 ++
 net/ipv4/tcp_input.c               |    5 ++++-
 net/ipv4/tcp_ipv4.c                |    1 +
 net/ipv4/tcp_output.c              |   35 +++++++++++++++++++++++++++++++----
 net/ipv4/tcp_timer.c               |    2 +-
 9 files changed, 56 insertions(+), 7 deletions(-)
