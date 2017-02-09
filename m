From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v4 net-next 00/10] openvswitch: Conntrack integration improvements.
Date: Thu,  9 Feb 2017 11:21:51 -0800
Message-ID: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, davem@davemloft.net, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:33252 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754105AbdBITW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:22:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves the conntrack integration code in the openvswitch
module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
7), clarifying code (patches 4, 5, and 6), improving performance
(patch 10), and adding new features enabling better translation from
firewall admission policy to network configuration requested by user
communities (patches 8 and 9).

Please note that v3 of the series was Acked by Pravin, but I posted a
v4 addressing the remaining english language and coding style issues
posted by Joe on v2.

v4: Address remaining language and coding style issues from Joe.
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
 net/openvswitch/conntrack.c      | 296 ++++++++++++++++++++++++++++++---------
 net/openvswitch/conntrack.h      |  14 +-
 net/openvswitch/flow.c           |  34 ++++-
 net/openvswitch/flow.h           |  55 ++++++--
 net/openvswitch/flow_netlink.c   |  92 +++++++++---
 net/openvswitch/flow_netlink.h   |   7 +-
 8 files changed, 420 insertions(+), 113 deletions(-)

-- 
2.1.4
