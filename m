From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/2 v4] Open vSwitch zerocopy upcall
Date: Fri,  8 Nov 2013 11:47:16 +0100
Message-ID: <cover.1383906944.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:47616 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab3KHKr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 05:47:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respin of the zerocopy patches for the openvswitch upcall.

V4: - Daniel Borkmann pointed out that the style in skbuff.h has changed
      in net-next, adapted to no longer using extern in headers.
V3: - Removed unneeded alignment of nlmsg_len after padding 
V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
      buffer. This also takes care of the from->head_frag issue.
    - Attribute alignment for frag_list case
    - API documentation
    - performance data for CHECKSUM_PARTIAL tx case

Thomas Graf (2):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Use skb_zerocopy() for upcall

 include/linux/skbuff.h               |  3 ++
 net/core/skbuff.c                    | 85 ++++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 59 ++-----------------------
 net/openvswitch/datapath.c           | 52 +++++++++++++++++++---
 4 files changed, 137 insertions(+), 62 deletions(-)

-- 
1.8.3.1
