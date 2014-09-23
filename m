From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 00/29][pull request] Intel Wired LAN Driver Updates 2014-09-23
Date: Tue, 23 Sep 2014 04:16:28 -0700
Message-ID: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10551 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbaIWLRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the FM10000 Ethernet switch host
interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet switch
supporting both Ethernet ports and PCI Express host interfaces.  The fm10k
driver provides support for the host interface portion of the switch, both
PF and VF.

As the host interfaces are directly connected to the switch this results in
some significant differences versus a standard network driver.  For example
there is no PHY or MII on the device.  Since packets are delivered directly
from the switch to the host interface these are unnecessary.  Otherwise most
of the functionality is very similar to our other network drivers such as
ixgbe or igb.  For example we support all the standard network offloads,
jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.

v2: converted dev_consume_skb_any() to dev_kfree_skb_any()
    fix up PTP code based on feedback from the community
v3: converted the use of smb_mb__before_clear_bit() to smb_mb__before_atomic()
    added vmalloc header to patch 15
    added prefetch header to patch 16

The following are changes since commit b749fc9bff50013182edf2371d7f6c6796aed808:
  net: fec: fix code identation
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (29):
  fm10k: Add skeletal frame for Intel(R) FM10000 Ethernet Switch Host
    Interface Driver
  fm10k: Add register defines and basic structures
  fm10k: Add support for TLV message parsing and generation
  fm10k: Add support for basic interaction with hardware
  fm10k: Add support for mailbox
  fm10k: Implement PF <-> SM mailbox operations
  fm10k: Add support for PF
  fm10k: Add support for configuring PF interface
  fm10k: Add netdev
  fm10k: Add support for L2 filtering
  fm10k: Add support for ndo_open/stop
  fm10k: Add interrupt support
  fm10k: add support for Tx/Rx rings
  fm10k: Add service task to handle delayed events
  fm10k: Add Tx/Rx hardware ring bring-up/tear-down
  fm10k: Add transmit and receive fastpath and interrupt handlers
  fm10k: Add ethtool support
  fm10k: Add support for PCI power management and error handling
  fm10k: Add support for multiple queues
  fm10k: Add support for netdev offloads
  fm10k: Add support for MACVLAN acceleration
  fm10k: Add support for PF <-> VF mailbox
  fm10k: Add support for VF
  fm10k: Add support for SR-IOV to PF core files
  fm10k: Add support for SR-IOV to driver
  fm10k: Add support for IEEE DCBx
  fm10k: Add support for debugfs
  fm10k: Add support for ptp to hw specific files
  fm10k: Add support for PTP

 drivers/net/ethernet/intel/Kconfig               |   19 +
 drivers/net/ethernet/intel/Makefile              |    1 +
 drivers/net/ethernet/intel/fm10k/Makefile        |   33 +
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  534 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k_common.c  |  534 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k_common.h  |   65 +
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c   |  174 ++
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |  259 +++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 1069 +++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |  536 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 1979 ++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 2125 +++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     |  307 +++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 1431 ++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 2166 ++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 1880 +++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h      |  135 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |  463 +++++
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c     |  863 +++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h     |  186 ++
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |  770 ++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  578 ++++++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      |   78 +
 23 files changed, 16185 insertions(+)
 create mode 100644 drivers/net/ethernet/intel/fm10k/Makefile
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_common.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_common.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_iov.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_main.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pci.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pf.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_pf.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_type.h
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_vf.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_vf.h

-- 
1.9.3
