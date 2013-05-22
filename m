From: Simon Horman <horms@verge.net.au>
Subject: [PATCH next-next v4 0/2] MPLS: Add limited GSO support
Date: Wed, 22 May 2013 15:57:14 +0900
Message-ID: <1369205836-9407-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40739 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab3EVG5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 02:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where a non-MPLS packet is received and an MPLS stack is
added it may well be the case that the original skb is GSO but the
NIC used for transmit does not support GSO of MPLS packets.

The aim of this short series is to provide GSO in software for MPLS packets
whose skbs are GSO.

Simon Horman (2):
  net: Use 16bits for inner_*_headers fields of struct skbuff
  MPLS: Add limited GSO support

 include/linux/netdev_features.h |   4 +-
 include/linux/netdevice.h       |   2 +
 include/linux/skbuff.h          |  67 +++++-------------------
 net/Kconfig                     |   1 +
 net/Makefile                    |   1 +
 net/core/dev.c                  |   4 ++
 net/core/ethtool.c              |   1 +
 net/ipv4/af_inet.c              |   1 +
 net/ipv4/tcp.c                  |   1 +
 net/ipv4/udp.c                  |   2 +-
 net/ipv6/ip6_offload.c          |   1 +
 net/ipv6/udp_offload.c          |   3 +-
 net/mpls/Kconfig                |   9 ++++
 net/mpls/Makefile               |   4 ++
 net/mpls/mpls_gso.c             | 109 ++++++++++++++++++++++++++++++++++++++++
 15 files changed, 152 insertions(+), 58 deletions(-)
 create mode 100644 net/mpls/Kconfig
 create mode 100644 net/mpls/Makefile
 create mode 100644 net/mpls/mpls_gso.c

-- 
1.8.2.1
