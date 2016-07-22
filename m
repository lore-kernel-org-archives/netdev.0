From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] 40GbE Intel Wired LAN Driver Updates 2016-07-22
Date: Fri, 22 Jul 2016 00:36:28 -0700
Message-ID: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37308 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbcGVHgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Heinrich Schuchardt found a possible null pointer being dereferenced in
i40e_debug_aq(), fixed the issue by doing the variable assignment after
we are sure the pointer is not null.

Avinash fixed an issue when link was down, we were not showing the
correct advertised link modes.

Mitch cleans up a useless initializer since the variable is assigned
right away.  Refactors the receive filter handling to properly track
filter adds and deletes so the driver will not lose filters during a
reset and up/down cycles.  Also added a tracking mechanism so that the
driver knows when to enter and leave promiscuous mode.

Catherine removes a device id which is not needed (or used).  Moves
a mutex lock since we need to lock the client list around the
i40e_client_release() call to prevent the release from interrupting
the client instances while they are being added.

Joshua adds Hyper-V specific VF device ids.

Amitoj Kaur Chawla cleans up a redundant memset() call before a memcpy().

Stefan Assmann adds the missing link advertise for some x710 NICs.

Tushar Dave fixes and issue found on SPARC, where a PF reset clears MAC
filters and if a platform-specific MAC address is used, the driver has
to explicitly write default MAC address to MAC filters otherwise all
incoming traffic destined to the default MAC address will be dropped
after reset.

The following are changes since commit d95a93a9b71677a43f967a1b7986decab84b7765:
  Merge branch 'macsec-gro'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Amitoj Kaur Chawla (1):
  i40e: Remove redundant memset

Avinash Dayanand (1):
  i40e: Fix to show correct Advertised Link Modes when link is down

Bimmy Pujari (1):
  i40e/i40evf-bump version to 1.6.11

Catherine Sullivan (2):
  i40e: Remove device ID 0x37D4
  i40e: Move the mutex lock in i40e_client_unregister

Heinrich Schuchardt (1):
  i40e: avoid null pointer dereference

Joshua Hay (1):
  i40evf: add hyperv dev ids

Mitch Williams (2):
  i40e/i40evf: remove useless initializer
  i40e: refactor Rx filter handling

Stefan Assmann (1):
  i40e: add missing link advertise setting

Tushar Dave (1):
  i40e: Explicitly write platform-specific mac address after PF reset

 drivers/net/ethernet/intel/i40e/i40e.h          |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c   |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c   |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c  |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_devids.h   |   1 -
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  |  48 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 601 +++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_devids.h |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   4 +-
 12 files changed, 350 insertions(+), 352 deletions(-)

-- 
2.5.5
