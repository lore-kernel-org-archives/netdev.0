From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 0/7] Add basic VLAN support to bridges
Date: Wed, 19 Sep 2012 08:42:09 -0400
Message-ID: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab2ISMmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches provides an ability to add VLAN IDs to the bridge
ports.  This is similar to what can be found in most switches.  The bridge
port may have any number of VLANs added to it including vlan 0 for untagged
traffic.  When vlans are added to the port, only traffic tagged with particular
vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
entries and become part of the lookup.  This way we correctly identify the FDB
entry.

The default behavior ofthe bridge is unchanged if no vlans have been
configured.

Changes since v1:
 - Comments addressed regarding formatting and RCU usage
 - iocts have been removed and changed over the netlink interface.
 - Added support of user added ndb entries.
 - changed sysfs interface to export a bitmap.  Also added a write interface.
   I am not sure how much I like it, but it made my testing easier/faster.  I
   might change the write interface to take text instead of binary.

Vlad Yasevich (7):
  bridge: Add vlan check to forwarding path
  bridge: Add vlan to unicast fdb entries
  bridge: Add vlan id to multicast groups
  bridge: Add netlink interface to configure vlans on bridge ports
  bridge: Add vlan support to static neighbors
  bridge: Add sysfs interface to display VLANS
  bridge:  Add the ability to show dump the vlan map from a bridge port

 include/linux/if_bridge.h |    3 +-
 include/linux/if_link.h   |   23 ++++++
 include/linux/neighbour.h |    2 +-
 net/bridge/br_device.c    |    2 +-
 net/bridge/br_fdb.c       |   77 +++++++++++--------
 net/bridge/br_forward.c   |   15 ++++-
 net/bridge/br_if.c        |   74 +++++++++++++++++
 net/bridge/br_input.c     |   19 ++++-
 net/bridge/br_multicast.c |   64 +++++++++++-----
 net/bridge/br_netlink.c   |  190 ++++++++++++++++++++++++++++++++++++++------
 net/bridge/br_private.h   |   29 +++++++-
 net/bridge/br_sysfs_if.c  |   70 +++++++++++++++++
 12 files changed, 481 insertions(+), 87 deletions(-)

-- 
1.7.7.6
