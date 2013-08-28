From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  00/10][pull request] Intel Wired LAN Driver Updates
Date: Wed, 28 Aug 2013 03:33:38 -0700
Message-ID: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19818 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184Ab3H1Kdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 06:33:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe.

Jacob provides a fix for 82599 devices where it can potentially keep link
lights up when the adapter has gone down.

Mark provides a fix to resolve the possible use of uninitialized memory
by checking the return value on EEPROM reads.

Don provides 2 patches, one to fix a issue where we were traversing the
Tx ring with the value of IXGBE_NUM_RX_QUEUES which currently happens
to have the correct value but this is misleading.  A change later, could
easily make this no longer correct so when traversing the Tx ring, use
netdev->num_tx_queues.  His second patch does some minor clean ups of log
messages.

Emil provides the remaining ixgbe patches.  First he fixes the link test
where forcing the laser before the link check can lead to inconsistent
results because it does not guarantee that the link will be negotiated
correctly.  Then he initializes the message buffer array to 0 in order
to avoid using random numbers from the memory as a MAC address for the
VF.  Emil also fixes the read loop for the I2C data to account for the
offset for SFP+ modules.  Lastly, Emil provides several patches to add
support for QSFP modules where 1Gbps support is added as well as support
for older QSFP active direct attach cables which pre-date SFF-8436 v3.6.

The following are changes since commit 5b2941b18dc5f60a5c14a5c15693f9c58b0dd922:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (2):
  ixgbe: fix incorrect limit value in ring transverse
  ixgbe: cleanup some log messages

Emil Tantilov (6):
  ixgbe: fix link test when connected to 1Gbps link partner
  ixgbe: zero out mailbox buffer on init
  ixgbe: fix SFF data dumps of SFP+ modules from an offset
  ixgbe: add 1Gbps support for QSFP+
  ixgbe: include QSFP PHY types in ixgbe_is_sfp()
  ixgbe: add support for older QSFP active DA cables

Jacob Keller (1):
  ixgbe: disable link when adapter goes down

Mark Rustad (1):
  ixgbe: Check return value on eeprom reads

 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   | 93 ++++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 67 ++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 40 ++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 13 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     | 98 +++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h     |  5 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c   |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  2 +
 9 files changed, 238 insertions(+), 90 deletions(-)

-- 
1.8.3.1
