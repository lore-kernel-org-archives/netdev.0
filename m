From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/40][pull request] Intel Wired LAN Driver Update
Date: Tue,  7 Jun 2011 05:32:35 -0700
Message-ID: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54890 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab1FGMdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, igb, igbvf,
ixgbe, ixgbevf and some core functionality.

e1000e: several cleanups and fixes, as well as bump the version
igb: bump driver version
igbvf: bump driver version
ixgbe: Added Dell CEM support and bumped the driver version.
       Contains the last bits to cleanup the flow
       director filters in ixgbe.  Specifically what this set does
       is finish moving the filtering off of ntuple and over to
       network flow classifier rules.
ixgbevf: bump driver version
rtnetlink: Compute and store minimum ifinfo dump size

The following are changes since commit 8d13e670d3fb83f4668c9e37196c3bbf5b9f094c:
  macvlan: add VLAN filters to lowerdev
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (10):
  ixgbe: remove ntuple filtering
  ixgbe: fix flags relating to perfect filters to support coexistence
  ixgbe: update perfect filter framework to support retaining filters
  ixgbe: add basic support for setting and getting nfc controls
  ixgbe: add support for displaying ntuple filters via the nfc
    interface
  ixgbe: add support for nfc addition and removal of filters
  ethtool: remove support for ETHTOOL_GRXNTUPLE
  ixgbe: add support for modifying UDP RSS flow hash options
  ixgbe: fix ring assignment issues for SR-IOV and drop cases
  ixgbe: Update feature flags so that LRO and Ntuple are restricted

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

Don Skidmore (1):
  ixgbe: update driver version string

Emil Tantilov (4):
  ixgbe: add support for Dell CEM
  ixgbe: move setting RSC into a separate function
  ixgbe: move reset code into a separate function
  ixgbe: disable RSC when Rx checksum is off

Greg Rose (2):
  rtnetlink: Compute and store minimum ifinfo dump size
  ixgbevf: Update the driver string

John Fastabend (10):
  ixgbe: dcbnl reduce duplicated code and indentation
  ixgbe: consolidate packet buffer allocation
  ixgbe: consolidate MRQC and MTQC handling
  ixgbe: configure minimal packet buffers to support TC
  ixgbe: DCB use existing TX and RX queues
  ixgbe: DCB 82598 devices, tx_idx and rx_idx swapped
  ixgbe: setup redirection table for multiple packet buffers
  ixgbe: fix bit mask for DCB version
  ixgbe: DCB and perfect filters can coexist
  ixgbe: DCB, remove unneeded ixgbe_dcb_txq_to_tc() routine

Vasu Dev (3):
  ixgbe: setup per CPU PCI pool for FCoE DDP
  ixgbe: use per NUMA node lock for FCoE DDP
  ixgbe: alloc DDP PCI pool and ixgbe queues as per NUMA nodes

Williams, Mitch A (1):
  igbvf: update version number

 drivers/net/Kconfig                  |    1 -
 drivers/net/e1000e/e1000.h           |   42 ++-
 drivers/net/e1000e/es2lan.c          |    8 +
 drivers/net/e1000e/hw.h              |   21 +-
 drivers/net/e1000e/ich8lan.c         |  191 +++++++---
 drivers/net/e1000e/netdev.c          |  131 +++----
 drivers/net/e1000e/phy.c             |  352 +++++++++++------
 drivers/net/igb/igb_main.c           |    3 +-
 drivers/net/igbvf/netdev.c           |    2 +-
 drivers/net/ixgbe/ixgbe.h            |   33 ++-
 drivers/net/ixgbe/ixgbe_82598.c      |   43 ++
 drivers/net/ixgbe/ixgbe_82599.c      |  643 ++++++++++++++++--------------
 drivers/net/ixgbe/ixgbe_common.c     |  240 +++++++++++
 drivers/net/ixgbe/ixgbe_common.h     |    5 +
 drivers/net/ixgbe/ixgbe_dcb.c        |   10 +-
 drivers/net/ixgbe/ixgbe_dcb.h        |    7 -
 drivers/net/ixgbe/ixgbe_dcb_82598.c  |   43 +--
 drivers/net/ixgbe/ixgbe_dcb_82598.h  |    3 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c  |  119 +------
 drivers/net/ixgbe/ixgbe_dcb_82599.h  |   14 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c     |   55 +--
 drivers/net/ixgbe/ixgbe_ethtool.c    |  721 +++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_fcoe.c       |  155 ++++++--
 drivers/net/ixgbe/ixgbe_fcoe.h       |   14 +-
 drivers/net/ixgbe/ixgbe_main.c       |  497 +++++++++++++-----------
 drivers/net/ixgbe/ixgbe_type.h       |   97 ++++-
 drivers/net/ixgbe/ixgbe_x540.c       |    2 +
 drivers/net/ixgbevf/ixgbevf_main.c   |    2 +-
 include/linux/ethtool.h              |    8 +-
 include/linux/netdevice.h            |    3 -
 include/linux/netlink.h              |    6 +-
 include/net/rtnetlink.h              |    7 +-
 net/bridge/br_netlink.c              |   15 +-
 net/core/dev.c                       |    5 -
 net/core/ethtool.c                   |  299 --------------
 net/core/fib_rules.c                 |    6 +-
 net/core/neighbour.c                 |   11 +-
 net/core/rtnetlink.c                 |   60 +++-
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
 61 files changed, 2390 insertions(+), 1625 deletions(-)

-- 
1.7.5.2

