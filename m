From: Florian Westphal <fw@strlen.de>
Subject: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm
Date: Mon, 12 May 2014 22:59:39 +0200
Message-ID: <1399928384-24143-1-git-send-email-fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56524 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753647AbaELVfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 17:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the Datacenter TCP (DCTCP) congestion
control algorithm.

Please see individual patches' changelog for the details. A summary
of DCTCP and test results can be found in patch 5.

Joint work with Daniel Borkmann and Glenn Judd.

Daniel Borkmann (2):
      net: tcp: add flag for ca to indicate that ECN is required
      net: tcp: add DCTCP congestion algorithm

Florian Westphal (3):
      net: tcp: assign tcp cong_ops when tcp sk is created
      net: tcp: split ack slow/fast events from cwnd_event
      net: tcp: more detailed ACK events, and events for CE marked packets

 Documentation/networking/dctcp.txt | 232 +++++++++++++++++++++++++++
 include/net/tcp.h                  |  70 ++++++---
 net/ipv4/Kconfig                   |  28 +++-
 net/ipv4/Makefile                  |   1 +
 net/ipv4/tcp.c                     |   2 +-
 net/ipv4/tcp_cong.c                |  24 ++-
 net/ipv4/tcp_dctcp.c               | 311 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c               |  30 +++-
 net/ipv4/tcp_ipv4.c                |   2 +-
 net/ipv4/tcp_minisocks.c           |   2 +-
 net/ipv4/tcp_output.c              |  14 +-
 net/ipv4/tcp_westwood.c            |  30 ++--
 net/ipv6/tcp_ipv6.c                |   2 +-
 13 files changed, 690 insertions(+), 58 deletions(-)
 create mode 100644 Documentation/networking/dctcp.txt
 create mode 100644 net/ipv4/tcp_dctcp.c
