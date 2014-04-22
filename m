From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates
Date: Tue, 22 Apr 2014 05:39:15 -0700
Message-ID: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4229 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbaDVMje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Greg provides two patches for i40e, the first adds the netdev ops to support
the addition of static FDB entries in the physical function (PF) MAC/VLAN
filter table so that the virtual functions (VFs) can communicate with
bridged virtual Ethernet ports such as those provided by the virtio
driver.  The second is to fix an issue where the assignment of a port
VLAN after it is already up and running requires the VF driver to be
reloaded, so print a message warning the host administrator about the
need to reload the VF driver.  In addition, knock the VF offline so that
it does not continue to receive traffic not on the port VLAN assigned to
it.

Jesse provides a patch for i40e and i40evf to unhide and enable the
PREFENA field in the receive host memory cache (RX-HMC) for best
performance.

Mitch provides a i40e patch to implement the net device op for Tx
bandwidth setting.

Catherine removes a firmware workaround that is no longer needed with
the latest firmware for i40e.  She also provides some minor cleanups
as well bumps the driver versions.

Anjali provides a fix for i40e displaying IPv4 flow director filters
which needed additional information to be communicated up above in
order for it to be displayed correctly.

Shannon adds tracking of the NVM busy state so that the driver won't
allow a new NVM update command until a completion event is received
from the current update.  Updates the admin queue API to reflect
recent changes in the firmware.  Also rearranges the "if netdev" logic
to prepare for handling non-netdev VSIs.  Lastly rework the fdir
setup and tear down to use the newly created i40e_vsi_open() and
i40e_vsi_close(), which also fixes a memory leak of the FDIR queue
buffer info structs across a reset.

The following are changes since commit 5a9d19ab76f98b7cdc97ba9724be01deba791bc0:
  Merge branch 'ndo_set_config'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (1):
  i40e: Fix an issue with displaying IPv4 FD filters

Catherine Sullivan (5):
  i40e/i40evf: Bump build versions
  i40e: Remove a FW workaround
  i40e: Cleanup if/else statements
  i40e: Tweak for-loop in i40e_ethtool.c
  i40e/i40evf: Bump build versions

Greg Rose (2):
  i40e: Add bridge FDB add/del/dump ops
  i40e: Reset the VF upon conflicting VLAN configuration

Jesse Brandeburg (1):
  i40e/i40evf: unhide and enable to one prefena field

Mitch Williams (1):
  i40e: Enable VF Tx bandwidth setting

Shannon Nelson (6):
  i40e/i40evf: add tracking to NVM busy state
  i40e/i40evf: update AdminQ API
  i40e: prep vsi_open logic for non-netdev cases
  i40e: abstract the close path for better netdev vsis
  i40e: use generic vsi_open to unquiesce vsi
  i40e: rework fdir setup and teardown

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  23 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  41 +---
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  29 +++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |   1 +
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 261 +++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  93 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  22 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   1 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  41 +---
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 16 files changed, 369 insertions(+), 166 deletions(-)

-- 
1.9.0
