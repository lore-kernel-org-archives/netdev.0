From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 0/7] Fix fallout from conversion of skb headers to 16bit offsets
Date: Wed, 29 May 2013 14:27:41 +0900
Message-ID: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46187 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3E2F1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many apologies for not having the foresight to spot these problems earlier.

These problems relate to comparisons between integer offsets and pointers
that occur when NET_SKBUFF_DATA_USES_OFFSET is not set

These are regressions caused by "net: Use 16bits for *_headers fields of
struct skbuff".

Simon Horman (7):
  isdn: Correct comparison of skb->tail and skb-transport_header
  cxgb3: Correct comparisons and calculations using skb->tail and
    skb-transport_header
  net: Correct comparisons and calculations using skb->tail and
    skb-transport_header
  ipv6: Correct comparisons and calculations using skb->tail and
    skb-transport_header
  ipv4: Correct comparisons and calculations using skb->tail and
    skb-transport_header
  sctp: Correct access to skb->{network,transport}_header
  net,ipv4,ipv6: Correct assignment of skb->network_header to skb->tail

 drivers/isdn/i4l/isdn_net.c              |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c |   11 +++++------
 include/linux/skbuff.h                   |    9 +++++++++
 include/net/inet_ecn.h                   |    6 ++++--
 net/core/dev.c                           |    4 ++--
 net/core/netpoll.c                       |    9 ++++++++-
 net/core/pktgen.c                        |   16 ++++++++++++++--
 net/ipv4/icmp.c                          |    3 ++-
 net/ipv4/igmp.c                          |    2 +-
 net/ipv4/ipmr.c                          |    8 +++++++-
 net/ipv4/tcp.c                           |    3 ++-
 net/ipv6/exthdrs_core.c                  |    2 +-
 net/ipv6/icmp.c                          |    2 +-
 net/ipv6/mcast.c                         |    5 +++--
 net/ipv6/mip6.c                          |    6 ++++--
 net/ipv6/ndisc.c                         |    9 +++++----
 net/ipv6/output_core.c                   |    3 ++-
 net/ipv6/raw.c                           |    3 ++-
 net/ipv6/route.c                         |    2 +-
 net/sctp/input.c                         |    2 +-
 net/sctp/ipv6.c                          |    2 +-
 21 files changed, 76 insertions(+), 33 deletions(-)

-- 
1.7.10.4
