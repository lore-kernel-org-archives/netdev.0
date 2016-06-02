From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 0/7] sctp: Add GSO support
Date: Thu,  2 Jun 2016 15:05:37 -0300
Message-ID: <cover.1464888549.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188AbcFBSF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 14:05:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds sctp GSO support.

Performance tests indicates that increases throughput by 10% if using
bigger chunk sizes, specially if bigger than MTU. For small chunks, it
doesn't help much if not using heavy firewall rules.

For small chunks it will probably be of more use once we get something
like MSG_MORE as David Laight had suggested.

overall changes:
v1->v2:
Added support for receiving GSO frames on SCTP stack, as requested by
Dave Miller.

v2->v3:
Consider sctphdr size in skb_gso_transport_seglen()
rebased due to 5c7cdf339af5 ("gso: Remove arbitrary checks for
unsupported GSO")

Marcelo Ricardo Leitner (7):
  loopback: make use of NETIF_F_GSO_SOFTWARE
  skbuff: export skb_gro_receive
  sk_buff: allow segmenting based on frag sizes
  skbuff: introduce skb_gso_validate_mtu
  sctp: delay as much as possible skb_linearize
  sctp: Add GSO support
  sctp: improve debug message to also log curr pkt and new chunk size

 drivers/net/loopback.c          |   5 +-
 include/linux/netdev_features.h |   7 +-
 include/linux/netdevice.h       |   1 +
 include/linux/skbuff.h          |   8 +
 include/net/sctp/sctp.h         |   4 +
 include/net/sctp/structs.h      |   5 +
 net/core/ethtool.c              |   1 +
 net/core/skbuff.c               |  45 ++++-
 net/ipv4/ip_forward.c           |   2 +-
 net/ipv4/ip_output.c            |   2 +-
 net/ipv6/ip6_output.c           |   2 +-
 net/mpls/af_mpls.c              |   2 +-
 net/sctp/Makefile               |   3 +-
 net/sctp/input.c                |  57 ++++---
 net/sctp/inqueue.c              |  78 +++++++--
 net/sctp/offload.c              |  98 +++++++++++
 net/sctp/output.c               | 366 +++++++++++++++++++++++++++-------------
 net/sctp/protocol.c             |   3 +
 net/sctp/socket.c               |   2 +
 19 files changed, 524 insertions(+), 167 deletions(-)
 create mode 100644 net/sctp/offload.c

-- 
2.5.5
