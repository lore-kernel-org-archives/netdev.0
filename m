From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-02-03
Date: Fri,  3 Feb 2017 18:56:31 -0800
Message-ID: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24543 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753332AbdBDC4r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf only.

Jake fixes up the driver to not call i40e_vsi_kill_vlan() or
i40e_vsi_add_vlan() when the PVID is set or when the VID is less than 1.
Cleaned up a check which really is not needed since there is no real
reason why we cannot just call i40e_del_mac_all_vlan() directly.  Renamed
functions to better reflect their actual purpose and how they function
in a more clear manner.

Bimmy cleans up unused/deprecated macros.

Mitch cleans up unused device ids which were intended for use when
running Linux VF drivers under Hyper-V, but found to be not needed.
Then cleaned up a function that is no longer needed since the client
open and close functions were refactored.  Adds a sleep without timeout
until the reply from the PF driver has been received since the iWARP
client cannot continue until the operation has been completed.

Tushar Dave fixes an issue seen on SPARC where the use of the 'packed'
directive was causing kernel unaligned errors.

Alex does a refactor to pull some data off of the stack and store it
in the transmit buffer info section of the transmit ring.

Alan fixes a bug which was caused by passing a bad register value to the
firmware, by refactoring the macro INTRL_USEC_TO_REG into a static
inline function.  Also added feedback to the user as to the actual
interrupt rate limit being used when it differs from the requested limit.

The following are changes since commit 8fe809a992639b2013c0d8da2ba55cdea28a959a:
  net: add LINUX_MIB_PFMEMALLOCDROP counter
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: refactor macro INTRL_USEC_TO_REG
  i40e: add interrupt rate limit verbosity

Alexander Duyck (1):
  i40e: Quick refactor to start moving data off stack and into Tx buffer
    info

Bimmy Pujari (1):
  i40e: Deprecating unused macro

Jacob Keller (6):
  i40e: don't allow i40e_vsi_(add|kill)_vlan to operate when VID<1
  i40e: fold the i40e_is_vsi_in_vlan check into i40e_put_mac_in_vlan
  i40e: no need to check is_vsi_in_vlan before calling
    i40e_del_mac_all_vlan
  i40e: rename i40e_put_mac_in_vlan and i40e_del_mac_all_vlan
  i40e: avoid O(n^2) loop when deleting all filters
  i40e: when adding or removing MAC filters, correctly handle VLANs

Jayaprakash Shanmugam (1):
  i40e: Remove FPK HyperV VF device ID

Mitch Williams (2):
  i40evf: remove unused device ID
  i40e: remove unused function

Tushar Dave (1):
  i40e: remove unnecessary __packed

 drivers/net/ethernet/intel/i40e/i40e.h             | 25 ++------
 drivers/net/ethernet/intel/i40e/i40e_client.c      | 35 ------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 15 +++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 66 +++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 47 ++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 15 ++++-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  1 -
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 23 +++-----
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 47 ++++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  1 -
 14 files changed, 129 insertions(+), 153 deletions(-)

-- 
2.10.2
