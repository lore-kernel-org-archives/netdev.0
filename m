From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH RFC v2 0/2] Multiple VLAN Registration Protocol (IEEE 802.1Q-2011)
Date: Thu, 7 Feb 2013 22:50:54 -0500
Message-ID: <1360295457-5245-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:40045 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759778Ab3BHEVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 23:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: Use skb_header_pointer() as suggested by Eric Duzamet.

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

 include/linux/netdevice.h     |    2 +
 include/net/mrp.h             |  142 +++++++
 include/uapi/linux/if_ether.h |    1 +
 include/uapi/linux/if_vlan.h  |    1 +
 net/802/Kconfig               |    3 +
 net/802/Makefile              |    1 +
 net/802/mrp.c                 |  889 +++++++++++++++++++++++++++++++++++++++++
 net/8021q/Kconfig             |   11 +
 net/8021q/Makefile            |    1 +
 net/8021q/vlan.c              |   27 +-
 net/8021q/vlan.h              |   16 +
 net/8021q/vlan_dev.c          |   12 +-
 net/8021q/vlan_mvrp.c         |   72 ++++
 net/8021q/vlan_netlink.c      |    2 +-
 14 files changed, 1173 insertions(+), 7 deletions(-)
 create mode 100644 include/net/mrp.h
 create mode 100644 net/802/mrp.c
 create mode 100644 net/8021q/vlan_mvrp.c
