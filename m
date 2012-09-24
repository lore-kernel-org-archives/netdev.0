From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH RFC 0/2] Multiple VLAN Registration Protocol (IEEE 802.1Q-2011)
Date: Mon, 24 Sep 2012 17:07:32 -0400
Message-ID: <1348520855-8810-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Philip Foulkes <philip.foulkes@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42138 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750856Ab2IXV3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 17:29:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Linux kernel currently implements the GARP VLAN Registration 
Protocol (GVRP) from IEEE 802.1Q-1998 (applicant-only participant). 
When the GVRP flag is set for a VLAN interface on a Linux host, the 
host advertises its membership in the VLAN to the attached bridge/
switch, so that it is not necessary to manually configure the bridge/
switch port to participate in the VLAN.

GVRP has been superseded by the Multiple VLAN Registration Protocol 
(MVRP) in IEEE 802.1Q-2011, which addresses scalability concerns about 
the earlier protocol.  The following patches add support for MVRP to 
the Linux kernel and iproute2 utility. They are based largely off of 
the existing implementation of GVRP, but have been modified for the 
new PDU structure and state machine.

Please let me know if you have any comments. This implementation was 
tested with two Juniper EX4200 switches and found to work as expected. 
If you have access to other switches that implement MVRP, I would of 
course welcome additional testing.

Signed-off-by: David Ward <david.ward@ll.mit.edu>

David Ward (2):
  net/802: Implement Multiple Registration Protocol (MRP)
  net/8021q: Implement Multiple VLAN Registration Protocol (MVRP)

 include/linux/if_ether.h  |    1 +
 include/linux/if_vlan.h   |    1 +
 include/linux/netdevice.h |    2 +
 include/net/mrp.h         |  142 ++++++++
 net/802/Kconfig           |    3 +
 net/802/Makefile          |    1 +
 net/802/mrp.c             |  872 +++++++++++++++++++++++++++++++++++++++++++++
 net/8021q/Kconfig         |   11 +
 net/8021q/Makefile        |    1 +
 net/8021q/vlan.c          |   27 ++-
 net/8021q/vlan.h          |   16 +
 net/8021q/vlan_dev.c      |   12 +-
 net/8021q/vlan_mvrp.c     |   72 ++++
 net/8021q/vlan_netlink.c  |    2 +-
 14 files changed, 1156 insertions(+), 7 deletions(-)
 create mode 100644 include/net/mrp.h
 create mode 100644 net/802/mrp.c
 create mode 100644 net/8021q/vlan_mvrp.c

-- 
1.7.4.1
