From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/2 v2] Open vSwitch zerocopy upcall
Date: Thu, 25 Jul 2013 14:43:43 +0200
Message-ID: <cover.1374756042.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, eric.dumazet@gmail.com
To: davem@davemloft.net, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37141 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab3GYMnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 08:43:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respin of the zerocopy patches for the openvswitch upcall.

V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
      buffer. This also takes care of the from->head_frag issue.
    - Attribute alignment for frag_list case
    - API documentation
    - performance data for CHECKSUM_PARTIAL tx case

Thomas Graf (2):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Use skb_zerocopy() to prepare skb for upcall

 include/linux/skbuff.h               |  3 ++
 net/core/skbuff.c                    | 85 ++++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 59 ++-----------------------
 net/openvswitch/datapath.c           | 47 +++++++++++++++++---
 4 files changed, 133 insertions(+), 61 deletions(-)

-- 
1.8.3.1
