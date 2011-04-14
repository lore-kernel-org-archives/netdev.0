From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/26][pull request] Intel Wired LAN Driver Update
Date: Wed, 13 Apr 2011 18:01:56 -0700
Message-ID: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64021 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab1DNBC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, e1000e, igb and ixgbe.

- e1000 change is to convert to the new set_phys_id interface for
ethtool.

- e1000e has two conversion, one to use usleep_range and the other
to the new VLAN model.  There is also a fix for a debug statement as
well as a fix for ASPM.

- igb has a documentation update, comment fix, and the introduction
of thermal sensor checking.

- ixgbe contains the majority of the changes, with several cleanups
and fixes.  As well as a conversion to use usleep_range().

The following are changes since commit 8b5933c380fc66a6311739f9b36a812383f82141:
  net: ethtool support to configure number of channels
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master  

Bruce Allan (3):
  e1000e: convert short duration msleep() to usleep_range()
  e1000e: PCIe link speed in GT/s, not GB/s
  e1000e: If ASPM L0s needs to be disabled, do it prior to enabling
    device

Don Skidmore (1):
  ixgbe: cleanup short msleep's (<20ms) to use usleep_range

Emil Tantilov (10):
  ixgbe: fix return value checks
  ixgbe: correct function number for some 82598 parts
  ixgbe: fix namespacecheck issue
  ixgbe: refactor common start_hw code for 82599 and x540
  ixgbe: move disabling of relaxed ordering in start_hw()
  ixgbe: fix 82599 KR downshift coexistence with LESM FW module
  ixgbe: fix semaphores in eeprom routines for x540
  ixgbe: add support for new HW
  ixgbe: explicitly disable 100H for x540
  ixgbe: make device_caps() generic

Flavio Leitner (1):
  e1000e: fix stats locking in e1000_watchdog_task

Greg Rose (1):
  igb: Add anti-spoofing feature documentation

Jeff Kirsher (2):
  e1000e: convert to new VLAN model
  ixgbe: update version string for Dell CEM use

John Fastabend (3):
  ixgbe: DCB, further cleanups to app configuration
  ixgbe: DCB, misallocated packet buffer size with X540 device
  ixgbe: DCB, X540 devices do not respond to pause frames

Stefan Assmann (2):
  igb: fix typo in igb_validate_nvm_checksum_82580
  igb: introduce igb_thermal_sensor_event for sensor checking

stephen hemminger (1):
  e1000: convert to set_phys_id

 Documentation/networking/igb.txt    |   13 ++
 drivers/net/e1000/e1000.h           |    3 -
 drivers/net/e1000/e1000_ethtool.c   |   50 +++------
 drivers/net/e1000e/82571.c          |   20 ++--
 drivers/net/e1000e/e1000.h          |    6 +-
 drivers/net/e1000e/es2lan.c         |    4 +-
 drivers/net/e1000e/ethtool.c        |   46 ++++++--
 drivers/net/e1000e/ich8lan.c        |   12 +-
 drivers/net/e1000e/lib.c            |   10 +-
 drivers/net/e1000e/netdev.c         |  211 ++++++++++++++++++++---------------
 drivers/net/e1000e/phy.c            |    4 +-
 drivers/net/igb/e1000_82575.c       |    3 +-
 drivers/net/igb/igb_main.c          |   67 ++++++------
 drivers/net/ixgbe/ixgbe_82598.c     |   60 ++++++++++-
 drivers/net/ixgbe/ixgbe_82599.c     |  104 ++++++++++++------
 drivers/net/ixgbe/ixgbe_common.c    |  112 ++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   77 ++++++++-----
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    2 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |  109 ++++--------------
 drivers/net/ixgbe/ixgbe_ethtool.c   |   14 +-
 drivers/net/ixgbe/ixgbe_main.c      |   22 ++--
 drivers/net/ixgbe/ixgbe_phy.c       |    7 +-
 drivers/net/ixgbe/ixgbe_type.h      |   12 ++
 drivers/net/ixgbe/ixgbe_x540.c      |  192 +++++++++++++++++++++++---------
 25 files changed, 734 insertions(+), 430 deletions(-)

-- 
1.7.4.2

