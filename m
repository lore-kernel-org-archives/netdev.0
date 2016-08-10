From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 0/4] net_sched, flow_dissector, flower: Introduce vlan tag support
Date: Wed, 10 Aug 2016 16:32:19 +0300
Message-ID: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45345 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933454AbcHJT14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduce vlan tag support to the flower classifier and the flow
dissector. In addition to adding vlan priority to act vlan.

The first 2 patches are dealing with the flow dissector:
 - The first patch is a fix, vlan id value should be taken from skb->vlan_tci
   and not from skb->data.
 - The second patch adds support for vlan priority.

The third patch adds vlan tag support to the flower classifier, user space
patches will be sent later to complete it.
The last patch adds vlan priority to act vlan since only vlan id is currently supported.

Hadar Hen Zion (4):
  flow_dissector: Get vlan info from skb->vlan_tci instead of skb->data
  flow_dissector: Get vlan priority in addition to vlan id
  net_sched: flower: Add vlan support
  net_sched: act_vlan: Add priority option

 include/linux/if_vlan.h             |  1 +
 include/net/flow_dissector.h        | 11 ++++--
 include/net/tc_act/tc_vlan.h        |  1 +
 include/uapi/linux/pkt_cls.h        |  3 ++
 include/uapi/linux/tc_act/tc_vlan.h |  1 +
 net/core/flow_dissector.c           | 28 +++++++--------
 net/sched/act_vlan.c                | 13 +++++--
 net/sched/cls_flower.c              | 69 +++++++++++++++++++++++++++++++++++--
 8 files changed, 103 insertions(+), 24 deletions(-)

-- 
1.8.3.1
