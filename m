From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 0/5] net_sched, flow_dissector, flower: Introduce vlan tag support
Date: Wed, 17 Aug 2016 13:36:09 +0300
Message-ID: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34271 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752054AbcHQKh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:37:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduce vlan tag support to the flower classifier and the flow
dissector. In addition to adding vlan priority to act vlan.

The first 2 patches are dealing with flow-dissector:
 - The first patch is a fix, in case the vlan was already stripped from the
   skb, take it from skb->vlan_tci.
 - The second patch adds support for vlan priority.

The next 2 patches are dealing with flower:
 - The first patch is a fix, sets flow dissector 'used_keys' according to the
   mask value of each key.
 - The secound patch adds vlan tag support to the flower classifier, user space
   patches will be sent later to complete it.

The last patch adds vlan priority to act vlan since only vlan id is currently supported.

Changes from V1:
 - A new patch was added to this series "net_sched: flower: Avoid dissection of unmasked keys"
 - Adding u16 padding to struct flow_dissector_key_vlan
 - change flow_label field in struct flow_dissector_key_tags form 20 bits field to u32
 - Remove 'if (v->tcfv_push_prio)' check from tcf_vlan_dump function
 - Add support to un-stripped vlan skb and skb with multipale vlans in __skb_flow_dissect


Hadar Hen Zion (5):
  flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci
  flow_dissector: Get vlan priority in addition to vlan id
  net_sched: flower: Avoid dissection of unmasked keys
  net_sched: flower: Add vlan support
  net_sched: act_vlan: Add priority option

 include/linux/if_vlan.h             |  1 +
 include/net/flow_dissector.h        | 12 +++--
 include/net/tc_act/tc_vlan.h        |  1 +
 include/uapi/linux/pkt_cls.h        |  3 ++
 include/uapi/linux/tc_act/tc_vlan.h |  1 +
 net/core/flow_dissector.c           | 51 ++++++++++++++-----
 net/sched/act_vlan.c                | 13 ++++-
 net/sched/cls_flower.c              | 98 ++++++++++++++++++++++++++++++-------
 8 files changed, 144 insertions(+), 36 deletions(-)

-- 
1.8.3.1
