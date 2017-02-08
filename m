From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 0/9] openvswitch: Conntrack integration improvements.
Date: Wed,  8 Feb 2017 11:32:01 -0800
Message-ID: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:56056 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751037AbdBHTeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:34:04 -0500
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id E4A2D4866C4
        for <netdev@vger.kernel.org>; Wed,  8 Feb 2017 20:33:27 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves the conntrack integration code in the openvswitch
module by fixing bugs (patches 1, 4, and 6), clarifying code (patches
2, 3, and 5), improving performance (patch 9), and adding new features
enabling better translation from firewall admission policy to network
configuration requested by user communities (patches 7 and 8).

Jarno Rajahalme (9):
  openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
  openvswitch: Unionize ovs_key_ct_label with a u32 array.
  openvswitch: Simplify labels length logic.
  openvswitch: Do not trigger events for unconfirmed connections.
  openvswitch: Refactor labels initialization.
  openvswitch: Inherit master's labels.
  openvswitch: Add original direction conntrack tuple to sw_flow_key.
  openvswitch: Add force commit.
  openvswitch: Pack struct sw_flow_key.

 include/uapi/linux/openvswitch.h |  33 ++++-
 net/openvswitch/actions.c        |   2 +
 net/openvswitch/conntrack.c      | 285 +++++++++++++++++++++++++++++++--------
 net/openvswitch/conntrack.h      |  14 +-
 net/openvswitch/flow.c           |  34 ++++-
 net/openvswitch/flow.h           |  55 ++++++--
 net/openvswitch/flow_netlink.c   |  92 ++++++++++---
 net/openvswitch/flow_netlink.h   |   7 +-
 8 files changed, 416 insertions(+), 106 deletions(-)

-- 
2.1.4
