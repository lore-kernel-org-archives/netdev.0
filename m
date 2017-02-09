From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v3 net-next 00/10] openvswitch: Conntrack integration improvements.
Date: Wed,  8 Feb 2017 17:30:27 -0800
Message-ID: <1486603837-7202-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:40949 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752476AbdBIBbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:31:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves the conntrack integration code in the openvswitch
module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
7), clarifying code (patches 4, 5, and 6), improving performance
(patch 10), and adding new features enabling better translation from
firewall admission policy to network configuration requested by user
communities (patches 8 and 9).

v3: Rebase to the current net-next, add the comment only changing
    patch 1 and reshuffle some of the patches as requested by Joe.

Jarno Rajahalme (10):
  openvswitch: Fix comments for skb->_nfct
  openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
  openvswitch: Do not trigger events for unconfirmed connections.
  openvswitch: Unionize ovs_key_ct_label with a u32 array.
  openvswitch: Simplify labels length logic.
  openvswitch: Refactor labels initialization.
  openvswitch: Inherit master's labels.
  openvswitch: Add original direction conntrack tuple to sw_flow_key.
  openvswitch: Add force commit.
  openvswitch: Pack struct sw_flow_key.

 include/uapi/linux/openvswitch.h |  33 ++++-
 net/openvswitch/actions.c        |   2 +
 net/openvswitch/conntrack.c      | 298 ++++++++++++++++++++++++++++++---------
 net/openvswitch/conntrack.h      |  14 +-
 net/openvswitch/flow.c           |  34 ++++-
 net/openvswitch/flow.h           |  55 ++++++--
 net/openvswitch/flow_netlink.c   |  92 +++++++++---
 net/openvswitch/flow_netlink.h   |   7 +-
 8 files changed, 422 insertions(+), 113 deletions(-)

-- 
2.1.4
