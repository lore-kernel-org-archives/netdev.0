From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3 v5] Open vSwitch zerocopy upcall
Date: Mon, 11 Nov 2013 16:47:41 +0100
Message-ID: <cover.1384184208.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, dborkman@redhat.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37138 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3KKPsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:48:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respin of the zerocopy patches for the openvswitch upcall.

V5: - Removed padding requirement in user space
    - Added OVS_DP_F_UNALIGNED flag let user space signal ability to
      receive unaligned Netlink messages, fall back to linear copy
      otherwise.
V4: - Daniel Borkmann pointed out that the style in skbuff.h has changed
      in net-next, adapted to no longer using extern in headers.
V3: - Removed unneeded alignment of nlmsg_len after padding 
V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
      buffer. This also takes care of the from->head_frag issue.
    - Attribute alignment for frag_list case
    - API documentation
    - performance data for CHECKSUM_PARTIAL tx case

Thomas Graf (3):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Allow user space to announce ability to accept unaligned
    Netlink messages
  openvswitch: Use skb_zerocopy() for upcall

 include/linux/skbuff.h               |  3 ++
 include/uapi/linux/openvswitch.h     |  4 ++
 net/core/skbuff.c                    | 85 ++++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 59 ++-----------------------
 net/openvswitch/datapath.c           | 58 ++++++++++++++++--------
 net/openvswitch/datapath.h           |  2 +
 6 files changed, 139 insertions(+), 72 deletions(-)

-- 
1.8.3.1
