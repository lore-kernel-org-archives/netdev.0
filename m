From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] 1GbE Intel Wired LAN Driver Updates 2017-08-08
Date: Wed,  9 Aug 2017 14:47:34 -0700
Message-ID: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752247AbdHIVry (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and igb/igbvf.

Gangfeng Huang fixes an issue with receive network flow classification,
where igb_nfc_filter_exit() was not being called in igb_down() which
would cause the filter tables to "fill up" if a user where to change
the adapter settings (such as speed) which requires a reset of the
adapter.

Cliff Spradlin fixes a timestamping issue, where igb was allowing requests
for hardware timestamping even if it was not configured for hardware
transmit timestamping.

Corinna Vinschen removes the error message that there was an "unexpected
SYS WRAP", when it is actually expected.  So remove the message to not
confuse users.

Greg Edwards provides several patches for the mailbox interface between
the PF and VF drivers.  Added a mailbox unlock method to be used to unlock
the PF/VF mailbox by the PF.  Added a lock around the VF mailbox ops to
prevent the VF from sending another message while the PF is still
processing the previous message.  Fixed a "scheduling while atomic" issue
by changing msleep() to mdelay().

Sasha adds support for the next LOM generations i219 (v8 & v9) which
will be available in the next Intel client platform IceLake.

John Linville adds support for a Broadcom PHY to the igb driver, since
there are designs out in the world which use the igb MAC and a third
party PHY.  This allows the driver to load and function as expected on
these designs.

The following are changes since commit 53b948356554376ec6f89016376825d48bf396c3:
  net: vrf: Add extack messages for newlink failures
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Cliff Spradlin (1):
  igb: protect TX timestamping from API misuse

Corinna Vinschen (1):
  igb: Remove incorrect "unexpected SYS WRAP" log message

Gangfeng Huang (1):
  igb: Fix error of RX network flow classification

Greg Edwards (6):
  igb: add argument names to mailbox op function declarations
  igb: expose mailbox unlock method
  igb: do not drop PF mailbox lock after read of VF message
  igbvf: add lock around mailbox ops
  igbvf: after mailbox write, wait for reply
  igbvf: convert msleep to mdelay in atomic context

Gustavo A R Silva (1):
  e1000e: add check on e1e_wphy() return value

John W Linville (1):
  igb: support BCM54616 PHY

Sasha Neftin (1):
  e1000e: Initial Support for IceLake

 drivers/net/ethernet/intel/e1000e/hw.h         |  4 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |  2 +
 drivers/net/ethernet/intel/e1000e/netdev.c     |  4 ++
 drivers/net/ethernet/intel/igb/e1000_82575.c   |  6 +++
 drivers/net/ethernet/intel/igb/e1000_defines.h |  1 +
 drivers/net/ethernet/intel/igb/e1000_hw.h      | 18 ++++----
 drivers/net/ethernet/intel/igb/e1000_mbx.c     | 57 +++++++++++++++++++++++---
 drivers/net/ethernet/intel/igb/e1000_mbx.h     | 14 ++++---
 drivers/net/ethernet/intel/igb/igb_main.c      | 23 +++++++----
 drivers/net/ethernet/intel/igbvf/ethtool.c     |  4 ++
 drivers/net/ethernet/intel/igbvf/mbx.c         |  4 ++
 drivers/net/ethernet/intel/igbvf/netdev.c      | 47 +++++++++++++++++++++
 drivers/net/ethernet/intel/igbvf/vf.c          | 12 ++++--
 drivers/net/ethernet/intel/igbvf/vf.h          |  1 +
 14 files changed, 166 insertions(+), 31 deletions(-)

-- 
2.13.3
