From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 0/6] openvswitch: make vlan handling consistent
Date: Fri,  7 Oct 2016 18:07:35 +0200
Message-ID: <cover.1475855896.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754163AbcJGQHx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 12:07:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always keep the first vlan tag "accelerated", i.e. in skb->vlan_tci.

Unfortunately, with all the changes since v2, this patchset no longer has
the nice deletions > insertions diffstat. I still think it's worth it, as it
makes things more consistent overall.

Patch 3 is valid on its own. Patch 6 is needed in one form or other; with
the changes in this set, it's a simple deletion. Otherwise we'd need more
elaborate checks.

Jiri Benc (6):
  openvswitch: make skb modifiable in ovs_flow_key_extract*
  openvswitch: normalize vlan rx path
  openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev
  openvswitch: keep vlan tag accelerated on internal device
  openvswitch: remove unreachable code in vlan parsing
  openvswitch: fix vlan subtraction from packet length

 net/openvswitch/datapath.c           |  9 ++--
 net/openvswitch/flow.c               | 83 ++++++++++++++++++++++++------------
 net/openvswitch/flow.h               | 14 +++---
 net/openvswitch/vport-internal_dev.c |  9 +++-
 net/openvswitch/vport.c              | 18 +++-----
 5 files changed, 83 insertions(+), 50 deletions(-)

-- 
1.8.3.1
