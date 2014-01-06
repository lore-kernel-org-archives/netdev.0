From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Mon,  6 Jan 2014 04:30:21 -0800
Message-ID: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbaAFMaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Majority of this series contains patches from Greg and Mitch to fix
up or add functionality to the PF/VF driver interactions.  Notably,
a fix for SR-IOV VF port VLAN which resolved the problem of port VLAN
configurations not being persistent across VF driver loads and unloads
and enable/disable of the feature.  Also do not enable the default port
on the VEB, which is designed only to bridge the PF to an Open vSwitch
or bridge.  Another fix to resolve a possible memory corruption
condition where ARQ messages are written to random memory locations.
Fix a problem where the 'ip link show' command would display stale
link address information after the link address was set via the 'ip
link set' command.

Anjali provides several patches, one which saves information that can
be used while cleaning the Tx ring and useful in detecting Tx hangs.
Then provides a fixes to the admin queue shutdown function to ensure
we are shutting down the queue in the shutdown path and ensure ASQ is
alive before issuing the admin queue command.

Shannon provides a fix for get/update vsi params where the incorrect
struct was being used.

The following are changes since commit b912b2f8fc71df4c3ffa7a9fe2c2227e8bcdaa07:
  net/mlx4_core: Warn if device doesn't have enough PCI bandwidth
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (4):
  i40e: Record dma buffer info for dummy packets
  i40e: Admin queue shutdown fixes
  i40e: check asq alive before notify
  i40e: Do not allow AQ calls from ndo-ops

Greg Rose (4):
  i40e: Fix SR-IOV VF port VLAN
  i40e: Do not enable default port on the VEB
  i40e: Fix VF driver MAC address configuration
  i40e: Hide the Port VLAN VLAN ID

Jesse Brandeburg (1):
  i40e: fix whitespace

Mitch Williams (5):
  i40e: avoid unnecessary register read
  i40e: use struct assign instead of memcpy
  i40e: don't allocate zero size
  i40e: acknowledge VFLR when disabling SR-IOV
  i40e: support VFs on PFs other than 0

Shannon Nelson (1):
  i40e: use correct struct for get and update vsi params

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   3 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  75 ++++++++------
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  45 ++++----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 114 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +
 8 files changed, 169 insertions(+), 85 deletions(-)

-- 
1.8.3.1
