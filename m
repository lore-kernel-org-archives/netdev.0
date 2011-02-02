From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v4 0/2] iproute2: support for device groups
Date: Wed,  2 Feb 2011 20:23:39 +0200
Message-ID: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:48694 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab1BBSXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 13:23:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds userspace support for network device groups.
There is support for setting device groups, listing only interfaces of a
specific group, and setting basic device parameters for all interfaces
in a group.

Changes since version 3:
 * drop devgroup keyword. There is a single keyword for specifying
   groups now.
 * store group names internally as a hash, similar to routing table
   names. This is more efficient for batch mode operations.

Changes since version 2:
 * groups now have names. The mapping between names and numbers (which
   are used by the kernel) is in /etc/iproute2/group.
 * the ip man page and usage display function have been updated to
   reflect the new functionality.

Changes since version 1:
 * a single attribute is used for both setting the group of a device and
   manipulating an entire group.

Vlad Dogaru (2):
  iproute2: support listing devices by group
  iproute2: support device group semantics

 etc/iproute2/group        |    2 +
 include/linux/if_link.h   |    1 +
 include/linux/netdevice.h |    2 +-
 include/rt_names.h        |    1 +
 include/utils.h           |    3 +-
 ip/ipaddress.c            |   14 ++++++++++++
 ip/iplink.c               |   42 ++++++++++++++++++++++++++++++++++---
 ip/link_veth.c            |    3 +-
 lib/rt_names.c            |   50 +++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8             |   30 +++++++++++++++++++++++---
 10 files changed, 137 insertions(+), 11 deletions(-)
 create mode 100644 etc/iproute2/group

