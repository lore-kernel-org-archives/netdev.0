From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 1GbE Intel Wired LAN Driver Updates 2016-05-13
Date: Fri, 13 May 2016 16:43:41 -0700
Message-ID: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13874 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbcEMXn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igb and igbvf.

Steve Shih fixes an issue for disabling auto-negotiation and forcing
speed and duplex settings for non-copper media.

Brian Walsh cleanups some inconsistency in the use of return variables
names to avoid confusion.

Jake cleans up the drivers to use the BIT() macro when it can, which will
future proof the drivers for GCC 6 when it gets released.  Cleaned up
dead code which was never being used.  Also fixed e1000e, where it was
incorrectly restting the SYSTIM registers every time the ioctl was being
run.

Denys Vlasenko fixes an oversight where incvalue variable holds a 32
bit value so we should declare it as such, instead of 64 bits.  Also
fixed an overflow check, where two reads are the same, then it is not
an overflow.

Nathan Sullivan fixes the PTP timestamps for transmit and receive
latency based on the current link speed.

Alexander Duyck adds support for partial GSO segmentation in the case
of tunnels for igb and igbvf.

The following are changes since commit ed7cbbce544856b20e5811de373cf92e92499771:
  udp: Resolve NULL pointer dereference over flow-based vxlan device
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (1):
  igb/igbvf: Add support for GSO partial

Brian Walsh (1):
  e1000e: Cleanup consistency in ret_val variable usage

Denys Vlasenko (3):
  e1000e: e1000e_cyclecounter_read(): incvalue is 32 bits, not 64
  e1000e: e1000e_cyclecounter_read(): fix er32(SYSTIML) overflow check
  e1000e: e1000e_cyclecounter_read(): do overflow check only if needed

Jacob Keller (7):
  igb: use BIT() macro or unsigned prefix
  igb: make igb_update_pf_vlvf static
  igbvf: remove unused variable and dead code
  igbvf: use BIT() macro instead of shifts
  e1000e: use BIT() macro for bit defines
  e1000e: mark shifted values as unsigned
  e1000e: don't modify SYSTIM registers during SIOCSHWTSTAMP ioctl

Nathan Sullivan (1):
  igb: adjust PTP timestamps for Tx/Rx latency

Steve Shih (1):
  e1000e: fix ethtool autoneg off for non-copper

 drivers/net/ethernet/intel/e1000e/80003es2lan.c |  12 +-
 drivers/net/ethernet/intel/e1000e/82571.c       |  30 ++--
 drivers/net/ethernet/intel/e1000e/e1000.h       | 109 ++++++-------
 drivers/net/ethernet/intel/e1000e/ethtool.c     |  57 ++++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  44 +++---
 drivers/net/ethernet/intel/e1000e/ich8lan.h     |   8 +-
 drivers/net/ethernet/intel/e1000e/mac.c         |   2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      | 149 +++++++++++-------
 drivers/net/ethernet/intel/e1000e/nvm.c         |   2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         |   4 +-
 drivers/net/ethernet/intel/e1000e/phy.h         |  10 +-
 drivers/net/ethernet/intel/e1000e/ptp.c         |   2 +
 drivers/net/ethernet/intel/igb/e1000_82575.c    |   8 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h    |  30 ++--
 drivers/net/ethernet/intel/igb/e1000_defines.h  | 108 ++++++-------
 drivers/net/ethernet/intel/igb/e1000_mac.c      |  10 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c      |   4 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c      |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h      |   6 +-
 drivers/net/ethernet/intel/igb/igb.h            |  40 +++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c    |  18 +--
 drivers/net/ethernet/intel/igb/igb_main.c       | 187 ++++++++++++++--------
 drivers/net/ethernet/intel/igb/igb_ptp.c        |  42 ++++-
 drivers/net/ethernet/intel/igbvf/defines.h      |   2 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c      |   3 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h        |   4 +-
 drivers/net/ethernet/intel/igbvf/netdev.c       | 196 ++++++++++++++----------
 drivers/net/ethernet/intel/igbvf/vf.c           |   2 +-
 28 files changed, 635 insertions(+), 456 deletions(-)

-- 
2.5.5
