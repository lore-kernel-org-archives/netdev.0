From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri, 11 Feb 2011 09:20:47 -0800
Message-ID: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11125 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757851Ab1BKRVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains e1000e cleanup patches, the addition of igb
PF support for i350 devices and several ixgbe cleanup patches.

v2 - drop "e1000e: do not wakeup Tx queue until ready" while Bruce takes a
second look at the patch.

The following are changes since commit 6431cbc25fa21635ee04eb0516ba6c51389fbfac:
  inet: Create a mechanism for upward inetpeer propagation into routes.

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Atita Shirwaikar (1):
  ixgbe: Adding 100MB FULL support in ethtool

Bruce Allan (3):
  e1000e: replace unbounded sprintf with snprintf
  e1000e: use correct pointer when memcpy'ing a 2-dimensional array
  e1000e: return appropriate errors for 'ethtool -r'

Carolyn Wyborny (1):
  igb: Enable PF side of SR-IOV support for i350 devices

Don Skidmore (3):
  ixgbe: fix namespace issue with ixgbe_dcb_txq_to_tc
  ixgbe: cleanup namespace complaint by removing little used function
  ixgbe: cleanup ixgbe_init_mbx_params_pf namespace issue

John Fastabend (7):
  ixgbe: DCB, only reprogram HW if the FCoE priority is changed
  ixgbe: DCB, remove round robin mode on 82598 devices
  ixgbe: DCB, abstract out dcb_config from DCB hardware configuration
  ixgbe: DCB, implement 802.1Qaz routines
  ixgbe: DCB, do not reset on CEE pg changes
  ixgbe: DCB, remove RESET bit it is no longer needed
  ixgbe: DCB, use hardware independent routines

 drivers/net/e1000e/ethtool.c        |   13 ++-
 drivers/net/e1000e/netdev.c         |    8 +-
 drivers/net/igb/e1000_82575.c       |   10 ++-
 drivers/net/igb/e1000_mbx.c         |   38 +++----
 drivers/net/igb/igb_main.c          |    9 +-
 drivers/net/ixgbe/ixgbe.h           |    5 +-
 drivers/net/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ixgbe/ixgbe_dcb.c       |  177 +++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_dcb.h       |   10 ++-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   94 ++++++++--------
 drivers/net/ixgbe/ixgbe_dcb_82598.h |   23 ++++-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  115 +++++++++++--------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |   24 ++++-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |  211 ++++++++++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_ethtool.c   |   34 ++++++-
 drivers/net/ixgbe/ixgbe_main.c      |   22 ++--
 drivers/net/ixgbe/ixgbe_mbx.c       |    2 +
 drivers/net/ixgbe/ixgbe_mbx.h       |    2 +
 include/linux/dcbnl.h               |    5 +
 19 files changed, 605 insertions(+), 201 deletions(-)

-- 
1.7.4

