From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v2 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu,  9 Jun 2011 20:47:44 -0700
Message-ID: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56870 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914Ab1FJDr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 23:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a (smaller) subset of the previous 40 patch
submission.  This subset only contains updates to e1000e, igb, igbvf
and rtnetlink.

e1000e: several cleanups and fixes, as well as bump the version
igb/igbvf/ixgbevf: bump driver version
rtnetlink: Compute and store minimum ifinfo dump size

-v2: fixed infiniband compile issue with the rtnetlink patch
  
The following are changes since commit e357964ee66723d0ced63ac1dbd1db4a6a1d417e:
  bonding: delete unused arp_mon_pt
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Bruce Allan (8):
  e1000e: disable far-end loopback mode on ESB2
  e1000e: 82579 intermittently disabled during S0->Sx
  e1000e: log when swflag is cleared unexpectedly on ICH/PCH devices
  e1000e: do not schedule the Tx queue until ready
  e1000e: access multiple PHY registers on same page at the same time
  e1000e: Clear host wakeup bit on 82577/8 without touching PHY page
    800
  e1000e: remove redundant reverse dependency on CRC32
  e1000e: update driver version

Carolyn Wyborny (1):
  igb: Change version to remove number after -k in kernel versions.

Greg Rose (2):
  rtnetlink: Compute and store minimum ifinfo dump size
  ixgbevf: Update the driver string

Williams, Mitch A (1):
  igbvf: update version number

 drivers/infiniband/core/netlink.c    |    2 +-
 drivers/net/Kconfig                  |    1 -
 drivers/net/e1000e/e1000.h           |   42 +++--
 drivers/net/e1000e/es2lan.c          |    8 +
 drivers/net/e1000e/hw.h              |   21 ++-
 drivers/net/e1000e/ich8lan.c         |  191 ++++++++++++++-----
 drivers/net/e1000e/netdev.c          |  131 +++++--------
 drivers/net/e1000e/phy.c             |  352 ++++++++++++++++++++++------------
 drivers/net/igb/igb_main.c           |    3 +-
 drivers/net/igbvf/netdev.c           |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c   |    2 +-
 include/linux/netlink.h              |    6 +-
 include/net/rtnetlink.h              |    7 +-
 net/bridge/br_netlink.c              |   15 +-
 net/core/fib_rules.c                 |    6 +-
 net/core/neighbour.c                 |   11 +-
 net/core/rtnetlink.c                 |   60 +++++-
 net/dcb/dcbnl.c                      |    4 +-
 net/decnet/dn_dev.c                  |    6 +-
 net/decnet/dn_fib.c                  |    4 +-
 net/decnet/dn_route.c                |    5 +-
 net/ipv4/devinet.c                   |    6 +-
 net/ipv4/fib_frontend.c              |    6 +-
 net/ipv4/inet_diag.c                 |    2 +-
 net/ipv4/ipmr.c                      |    3 +-
 net/ipv4/route.c                     |    2 +-
 net/ipv6/addrconf.c                  |   16 +-
 net/ipv6/addrlabel.c                 |    9 +-
 net/ipv6/ip6_fib.c                   |    3 +-
 net/ipv6/ip6mr.c                     |    3 +-
 net/ipv6/route.c                     |    6 +-
 net/netfilter/ipset/ip_set_core.c    |    2 +-
 net/netfilter/nf_conntrack_netlink.c |    4 +-
 net/netlink/af_netlink.c             |   17 +-
 net/netlink/genetlink.c              |    2 +-
 net/phonet/pn_netlink.c              |   13 +-
 net/sched/act_api.c                  |    7 +-
 net/sched/cls_api.c                  |    6 +-
 net/sched/sch_api.c                  |   12 +-
 net/xfrm/xfrm_user.c                 |    3 +-
 40 files changed, 644 insertions(+), 357 deletions(-)

-- 
1.7.5.2

