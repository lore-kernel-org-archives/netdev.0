From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 23 Aug 2012 15:29:50 -0400
Message-ID: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab2HWT36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:29:58 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7NJTv60017916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 15:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches provides an ability to add VLAN IDs to the bridge
ports.  This is similar to what can be found in most switches.  The bridge
port may have any number of VLANs added to it including vlan 0 for untagged
traffic.  When vlans are added to the port, only traffic tagged with particular
vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
entries and become part of the lookup.  This way we correctly identify the FDB
entry.

There are still pieces missing.  I don't yet support adding a static fdb entry
with a particular vlan.  There is no netlink support for carrying a vlan id.

I'd like to hear thoughts of whether this is usufull and something we should
persue.

The default behavior ofthe bridge is unchanged if no vlans have been
configured.

Vlad Yasevich (5):
  bridge: Add vlan check to forwarding path
  bridge: Add vlan to unicast fdb entries
  bridge: Add vlan id to multicast groups
  bridge: Add private ioctls to configure vlans on bridge ports
  bridge: Add sysfs interface to display VLANS

 include/linux/if_bridge.h |    4 ++
 net/bridge/br_device.c    |    2 +-
 net/bridge/br_fdb.c       |   71 ++++++++++++++++++-------------
 net/bridge/br_forward.c   |   17 +++++++-
 net/bridge/br_if.c        |  103 +++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_input.c     |   18 +++++++-
 net/bridge/br_ioctl.c     |   31 +++++++++++++
 net/bridge/br_multicast.c |   64 +++++++++++++++++++---------
 net/bridge/br_private.h   |   14 +++++-
 net/bridge/br_sysfs_if.c  |   28 ++++++++++++
 10 files changed, 296 insertions(+), 56 deletions(-)

-- 
1.7.7.6
