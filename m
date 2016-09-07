From: Eric Garver <e@erig.me>
Subject: [PATCH net-next v22 0/3] openvswitch: add 802.1ad support
Date: Wed,  7 Sep 2016 12:56:56 -0400
Message-ID: <1473267419-6825-1-git-send-email-e@erig.me>
Cc: dev@openvswitch.org, Thomas F Herbert <thomasfherbert@gmail.com>,
        Xiao Liang <shaw.leon@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757444AbcIGQ5B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 12:57:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds 802.1ad support to openvswitch. It is a continuation of the
work originally started by Thomas F Herbert - hence the large rev number.

The extra VLAN is implemented by using an additional level of the
OVS_KEY_ATTR_ENCAP netlink attribute.
In OVS flow speak, this looks like

   eth_type(0x88a8),vlan(vid=100),encap(eth_type(0x8100), vlan(vid=200),
                                        encap(eth_type(0x0800), ...))

The userspace counterpart has also seen recent activity on the ovs-dev mailing
lists. There are some new 802.1ad OVS tests being added - also on the ovs-dev
list. This patch series has been tested using the most recent version of
userspace (v3) and tests (v2).

v22 changes:
  - merge patch 4 into patch 3
  - fix checkpatch.pl errors
    - Still some 80 char warnings for long string literals
  - refresh pointer after pskb_may_pull()
  - refactor vlan nlattr parsing to remove some double checks
  - introduce ovs_nla_put_vlan()
  - move triple VLAN check to after ethertype serialization
  - WARN_ON_ONCE() on triple VLAN and unexpected encap values

v21 changes:
  - Fix (and simplify) netlink attribute parsing
  - re-add handling of truncated VLAN tags
  - fix if/else dangling assignment in {push,pop}_vlan()
  - simplify parse_vlan()


Eric Garver (2):
  vlan: Check for vlan ethernet types for 8021.q or 802.1ad
  openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink
    attributes

Thomas F Herbert (1):
  openvswitch: 802.1ad uapi changes.

 include/linux/if_vlan.h          |  33 +++--
 include/uapi/linux/openvswitch.h |  17 ++-
 net/openvswitch/actions.c        |  16 +-
 net/openvswitch/flow.c           |  65 +++++---
 net/openvswitch/flow.h           |   8 +-
 net/openvswitch/flow_netlink.c   | 310 ++++++++++++++++++++++++++-------------
 net/openvswitch/vport.c          |   7 +-
 7 files changed, 314 insertions(+), 142 deletions(-)

-- 
2.5.5
